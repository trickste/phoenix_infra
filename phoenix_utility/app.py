import subprocess
import sys
import re
import json
import os
from datetime import datetime
import boto3
from botocore.exceptions import ClientError

# ========= CONFIG =========
BACKEND_DIR = "../terraform/resources/terraform_backend"
NETWORK_DIR = "../terraform/resources/network_architecture/dev"
APP_DIR = "../terraform/resources/application_architecture/dev"
VALIDATION_DIR = "../terraform/resources/validation_architecture/dev"
PACKER_DIR = "../packer"
BUCKET_NAME = "nfi-aws-dev-terraform-state-backend"
RUN_STATE_FILE = ".phoenix_run_state.json" 
ASG_NAME = "nfi_aws_phoenix_dev_asg"
VALIDATION_LAMBDA_NAME = "nfi_aws_phoenix_dev_validation_lambda"
# ===========================

def save_run_state(state: dict, path: str = RUN_STATE_FILE):
    state = dict(state)
    state["_saved_at"] = datetime.utcnow().isoformat() + "Z"
    with open(path, "w") as f:
        json.dump(state, f, indent=2)
    print(f"\nSaved run state to {path}")


def load_run_state(path: str = RUN_STATE_FILE) -> dict:
    with open(path, "r") as f:
        return json.load(f)


def delete_run_state(path: str = RUN_STATE_FILE):
    try:
        os.remove(path)
        print(f"\nDeleted run state file: {path}")
    except FileNotFoundError:
        pass

def run_state_exists(path: str = RUN_STATE_FILE) -> bool:
    return os.path.exists(path)

def run(cmd, cwd=None):
    print(f"\nRunning: {cmd}")
    result = subprocess.run(
        cmd,
        shell=True,
        cwd=cwd,
        text=True,
        capture_output=True
    )

    print(result.stdout)

    if result.returncode != 0:
        print(result.stderr)
        sys.exit(1)

    return result.stdout

def validate_lambda(region):
    print("\n=== INVOKING VALIDATION LAMBDA ===")

    lambda_client = boto3.client("lambda", region_name=region)

    try:
        response = lambda_client.invoke(
            FunctionName=VALIDATION_LAMBDA_NAME,
            InvocationType="RequestResponse",
            Payload=b"{}"
        )

        payload = response["Payload"].read().decode("utf-8")

        print("\nLambda Response:")
        print(payload)

    except ClientError as e:
        print(f"Lambda invocation failed: {e}")
        sys.exit(1)


def get_target_group_arn(region):
    autoscaling = boto3.client("autoscaling", region_name=region)

    try:
        response = autoscaling.describe_auto_scaling_groups(
            AutoScalingGroupNames=[ASG_NAME]
        )

        groups = response.get("AutoScalingGroups", [])
        if not groups:
            return None

        target_groups = groups[0].get("TargetGroupARNs", [])
        if not target_groups:
            return None

        return target_groups[0]

    except ClientError as e:
        print(f"Failed to fetch target group ARN: {e}")
        sys.exit(1)


def get_asg_instances(region):
    autoscaling = boto3.client("autoscaling", region_name=region)
    elbv2 = boto3.client("elbv2", region_name=region)

    try:
        response = autoscaling.describe_auto_scaling_groups(
            AutoScalingGroupNames=[ASG_NAME]
        )

        groups = response.get("AutoScalingGroups", [])
        if not groups:
            return []

        group = groups[0]
        instances = group.get("Instances", [])

        # Get Target Group ARN
        target_group_arn = group.get("TargetGroupARNs", [])
        target_health_map = {}

        if target_group_arn:
            tg_arn = target_group_arn[0]

            tg_response = elbv2.describe_target_health(
                TargetGroupArn=tg_arn
            )

            for target in tg_response["TargetHealthDescriptions"]:
                instance_id = target["Target"]["Id"]
                state = target["TargetHealth"]["State"]
                reason = target["TargetHealth"].get("Reason", "")
                description = target["TargetHealth"].get("Description", "")

                target_health_map[instance_id] = {
                    "state": state,
                    "reason": reason,
                    "description": description
                }

        result = []

        for instance in instances:
            instance_id = instance["InstanceId"]

            tg_info = target_health_map.get(instance_id, {})

            result.append((
                instance_id,
                instance["LifecycleState"],
                tg_info.get("state", "N/A"),
                tg_info.get("reason", ""),
                tg_info.get("description", "")
            ))

        return result

    except ClientError as e:
        print(f"Failed to fetch ASG instances: {e}")
        sys.exit(1)


def list_instances(region):
    print("\n=== LISTING INSTANCE STATUS ===")

    instances = get_asg_instances(region)

    if not instances:
        print("No instances found.")
        return

    print("\nInstanceId | Lifecycle | TG State | Reason | Description")
    print("-" * 120)

    for (
        instance_id,
        lifecycle,
        tg_state,
        reason,
        description
    ) in instances:
        print(
            f"{instance_id} | {lifecycle} | {tg_state} | {reason} | {description}"
        )


def delete_instance(region):
    print("\n=== DELETE INSTANCE FROM ASG ===")

    autoscaling = boto3.client("autoscaling", region_name=region)

    instances = get_asg_instances(region)

    if not instances:
        print("No instances available.")
        return

    print("\nAvailable Instances:")
    for idx, (
        instance_id,
        lifecycle,
        tg_state,
        reason,
        description
    ) in enumerate(instances):
        print(f"{idx + 1}. {instance_id} | {lifecycle} | {tg_state}")


    choice = input("\nSelect instance number to terminate: ")

    try:
        selected_instance = instances[int(choice) - 1][0]
    except:
        print("Invalid selection.")
        return

    print(f"\nTerminating instance: {selected_instance}")

    try:
        autoscaling.terminate_instance_in_auto_scaling_group(
            InstanceId=selected_instance,
            ShouldDecrementDesiredCapacity=False
        )

        print("Termination requested.")
        print("ASG will replace the instance automatically.")

    except ClientError as e:
        print(f"Termination failed: {e}")
        sys.exit(1)


# ----------------------------
# Step 1 – Backend
# ----------------------------
def setup_backend():
    print("\n=== SETUP BACKEND ===")

    result = subprocess.run(
        f"aws s3api head-bucket --bucket {BUCKET_NAME}",
        shell=True
    )

    if result.returncode == 0:
        print("Backend bucket already exists. Skipping.")
        return False

    run("terraform fmt -check -recursive", cwd=BACKEND_DIR)
    run("terraform init", cwd=BACKEND_DIR)
    run("terraform plan", cwd=BACKEND_DIR)
    run("terraform apply -auto-approve", cwd=BACKEND_DIR)
    return True


# ----------------------------
# Step 2 – Network
# ----------------------------
def setup_network(
        vpc_id=None, 
        region=None, 
        public_subnet_cidrs=None, 
        protected_subnet_cidrs=None, 
        ami_sg_id=None):
    print("\n=== SETUP NETWORK ===")

    vars = []
    if vpc_id:
        
        vars.append(f" -var 'vpc_id={vpc_id}' -var 'create_vpc=false'")

        if region:
            vars.append(f" -var 'region={region}' ")
        
        if ami_sg_id:
            vars.append(f" -var 'ami_sg_id={ami_sg_id}' ")

        if not public_subnet_cidrs or not protected_subnet_cidrs:
            print("Public and protected subnet CIDRs are mandatory when using existing VPC.")
            sys.exit(1)

        vars.append(f"-var 'public_subnets_cidrs={json.dumps(public_subnet_cidrs)}'")
        vars.append(f"-var 'protected_subnets_cidrs={json.dumps(protected_subnet_cidrs)}'")

    

    run("terraform fmt -check -recursive", cwd=NETWORK_DIR)
    run("terraform init", cwd=NETWORK_DIR)
    run("terraform plan " + " ".join(vars), cwd=NETWORK_DIR)
    # apply_network = input("\nPress Y to apply the network changes...")
    # if apply_network.lower() == "y":
    #     run("terraform apply -auto-approve " + " ".join(vars), cwd=NETWORK_DIR)
    # else:
    #     print("Network changes not applied.")
    #     sys.exit(1)
    run("terraform apply -auto-approve " + " ".join(vars), cwd=NETWORK_DIR)
    output = run("terraform output -json", cwd=NETWORK_DIR)

    data = json.loads(output)

    vpc_id = data["vpc_id"]["value"]
    public_subnet_ids = data["public_subnet_ids"]["value"]
    protected_subnet_ids = data["protected_subnet_ids"]["value"]
    sg_id = data["nfi_ami_security_group_id"]["value"]

    return vpc_id, public_subnet_ids, protected_subnet_ids, sg_id, True

# ----------------------------
# Step 3 – Packer
# ----------------------------
def build_ami(vpc_id, subnet_id, sg_id, ami_id=None):
    print("\n=== BUILD AMI ===")

    if ami_id:
        print(f"Using existing AMI: {ami_id}")
        return ami_id
    
    run("packer init .", cwd=PACKER_DIR)
    packer_vars = (
    f"-var vpc_id={vpc_id} "
    f"-var subnet_id={subnet_id} "
    f"-var packer_sg_id={sg_id}"
)
    run(f"packer validate {packer_vars} .", cwd=PACKER_DIR)


    output = run(f"packer build {packer_vars} .", cwd=PACKER_DIR)

    amis = re.findall(r'ami-[a-zA-Z0-9]+', output)
    ami = amis[-1]

    print(f"AMI Created: {ami}")
    return ami


# ----------------------------
# Step 4 – Application
# ----------------------------
def setup_application(
        vpc_id=None,
        subnet_ids=None, 
        ami_id=None,
        region=None,
        min_size=None,
        max_size=None,
        desired_capacity=None,
        cpu_threshold=None
    ):
    print("\n=== SETUP APPLICATION ===")

    vars = ""
    subnet_ids_hcl = json.dumps(subnet_ids)

    if vpc_id and subnet_ids:
        vars += f" -var 'vpc_id={vpc_id}' -var 'subnet_ids={subnet_ids_hcl}'"
    
    if ami_id:
        vars += f" -var 'ami_id={ami_id}'"

    if region:
        vars += f" -var 'region={region}'"
    
    if min_size:
        vars += f" -var 'min_size={min_size}' "

    if max_size:    
        vars += f" -var 'max_size={max_size}' "

    if desired_capacity:
        vars += f" -var 'desired_capacity={desired_capacity}' "

    if cpu_threshold:
        vars += f" -var 'cpu_target_tracking_threshold_target_value={cpu_threshold}' "
    run("terraform fmt -check -recursive", cwd=APP_DIR)
    run("terraform init", cwd=APP_DIR)
    run(
        f"terraform plan "
        f"{vars}",
        cwd=APP_DIR
    )
    run(
        f"terraform apply -auto-approve "
        f"{vars}",
        cwd=APP_DIR
    )

# ----------------------------
# Step 5 – Validation Architecture
# ----------------------------
def setup_validation(
        vpc_id=None,
        protected_subnet_ids=None,
        region=None
    ):
    print("\n=== SETUP VALIDATION ARCHITECTURE ===")

    vars = ""

    if vpc_id and protected_subnet_ids:
        subnet_ids_hcl = json.dumps(protected_subnet_ids)
        vars += f" -var 'vpc_id={vpc_id}' -var 'protected_subnet_ids={subnet_ids_hcl}'"

    if region:
        vars += f" -var 'region={region}'"

    run("terraform fmt -check -recursive", cwd=VALIDATION_DIR)
    run("terraform init", cwd=VALIDATION_DIR)
    run(f"terraform plan {vars}", cwd=VALIDATION_DIR)
    run(f"terraform apply -auto-approve {vars}", cwd=VALIDATION_DIR)

# ----------------------------
# Destroy Flow
# ----------------------------
def destroy_all(region):
    print("\n=== DESTROY VALIDATION ===")
    run("terraform destroy -auto-approve", cwd=VALIDATION_DIR)

    print("\n=== DESTROY APPLICATION ===")
    run("terraform destroy -auto-approve", cwd=APP_DIR)

    print("\n=== DESTROY AMIS ===")
    cleanup_amis(region)

    print("\n=== DESTROY NETWORK ===")
    run("terraform destroy -auto-approve", cwd=NETWORK_DIR)

def build_network_destroy_vars(state: dict) -> str:

    parts = []
    if state.get("vpc_id"):
        parts.append(f"-var 'vpc_id={state['vpc_id']}' -var 'create_vpc=false'")
    if state.get("region"):
        parts.append(f"-var 'region={state['region']}'")
    if state.get("ami_sg_id"):
        parts.append(f"-var 'ami_sg_id={state['ami_sg_id']}'")

    if state.get("public_subnet_ids"):
        parts.append(f"-var 'public_subnet_ids={json.dumps(state['public_subnet_ids'])}'")
    if state.get("protected_subnet_ids"):
        parts.append(f"-var 'protected_subnet_ids={json.dumps(state['protected_subnet_ids'])}'")

    if state.get("public_subnets_cidrs"):
        parts.append(f"-var 'public_subnets_cidrs={json.dumps(state['public_subnets_cidrs'])}'")
    if state.get("protected_subnets_cidrs"):
        parts.append(f"-var 'protected_subnets_cidrs={json.dumps(state['protected_subnets_cidrs'])}'")

    return " ".join(parts)

def cleanup_amis(region, ami_id=None):
    print("\n=== CLEANUP AMIS ===")

    ec2 = boto3.client("ec2", region_name=region)

    try:
        # Case 1: Specific AMI provided
        if ami_id:
            image_ids = [ami_id]
        else:
            # Case 2: Cleanup all Phoenix AMIs
            images = ec2.describe_images(
                Owners=["self"],
                Filters=[
                    {"Name": "name", "Values": ["nfi_phoenix_dev_*"]}
                ]
            )["Images"]

            image_ids = [img["ImageId"] for img in images]

        if not image_ids:
            print("No AMIs found to delete.")
            return

        for image_id in image_ids:
            print(f"\nProcessing AMI: {image_id}")

            images = ec2.describe_images(ImageIds=[image_id])["Images"]
            if not images:
                print("AMI not found. Skipping.")
                continue

            print(f"Deregistering AMI: {image_id}")
            ec2.deregister_image(ImageId=image_id)

            # Delete associated snapshots
            for mapping in images[0].get("BlockDeviceMappings", []):
                ebs = mapping.get("Ebs")
                if ebs and "SnapshotId" in ebs:
                    snapshot_id = ebs["SnapshotId"]
                    print(f"Deleting snapshot: {snapshot_id}")
                    ec2.delete_snapshot(SnapshotId=snapshot_id)

            print("AMI and snapshots deleted.")

    except ClientError as e:
        print(f"AMI cleanup failed: {e}")
        sys.exit(1)


def build_app_destroy_vars(state: dict) -> str:
    parts = []
    if state.get("vpc_id") and state.get("protected_subnet_ids"):
        parts.append(f"-var 'vpc_id={state['vpc_id']}' -var 'subnet_ids={json.dumps(state['protected_subnet_ids'])}'")

    if state.get("ami_id"):
        parts.append(f"-var 'ami_id={state['ami_id']}'")
    if state.get("region"):
        parts.append(f"-var 'region={state['region']}'")
    if state.get("min_size") is not None:
        parts.append(f"-var 'min_size={state['min_size']}'")
    if state.get("max_size") is not None:
        parts.append(f"-var 'max_size={state['max_size']}'")
    if state.get("desired_capacity") is not None:
        parts.append(f"-var 'desired_capacity={state['desired_capacity']}'")
    if state.get("cpu_threshold") is not None:
        parts.append(f"-var 'cpu_target_tracking_threshold_target_value={state['cpu_threshold']}'")

    return " ".join(parts)

def build_validation_destroy_vars(state: dict) -> str:
    parts = []

    if state.get("vpc_id") and state.get("protected_subnet_ids"):
        parts.append(
            f"-var 'vpc_id={state['vpc_id']}' "
            f"-var 'protected_subnet_ids={json.dumps(state['protected_subnet_ids'])}'"
        )
    if state.get("region"):
        parts.append(f"-var 'region={state['region']}'")

    return " ".join(parts)

def destroy_partial_from_state(path: str = RUN_STATE_FILE):
    print("\n=== PARTIAL DESTROY (USING RUN STATE) ===")
    state = load_run_state(path)

    # Destroy validation first
    val_vars = build_validation_destroy_vars(state)
    print("\n=== DESTROY VALIDATION ===")
    run(f"terraform destroy -auto-approve {val_vars}", cwd=VALIDATION_DIR)

    # Destroy app infra
    app_vars = build_app_destroy_vars(state)
    print("\n=== DESTROY APPLICATION ===")
    run(f"terraform destroy -auto-approve {app_vars}", cwd=APP_DIR)

    # Deregister AMI if created in this run
    if state.get("ami_id"):
        cleanup_amis(state.get("region"), state.get("ami_id"))
    else:
        print("\n=== SKIP AMI DEREGISTRATION === (no AMI recorded in state)")

    # Destroy network only if we actually applied it in partial mode
    if state.get("network_applied") is True:
        net_vars = build_network_destroy_vars(state)
        print("\n=== DESTROY NETWORK ===")
        run(f"terraform destroy -auto-approve {net_vars}", cwd=NETWORK_DIR)
    else:
        print("\n=== SKIP NETWORK DESTROY === (network was not applied in this run)")

    delete_run_state(path)
    print("\nPartial destroy complete.")

# ----------------------------
# Main
# ----------------------------
if __name__ == "__main__":

    if len(sys.argv) < 3:
        print("""
Usage:

Automated:
  python phoenix.py automated <region>

Partial:
  python phoenix.py partial <region> \
    --vpc-id <vpc_id> \
    --public-subnet-cidrs <cidr1> <cidr2> \
    --protected-subnet-cidrs <cidr3> \
    --ami-sg-id <sg_id>

Destroy:
  python phoenix.py destroy <region>
        """)
        sys.exit(1)

    mode = sys.argv[1]
    region = sys.argv[2]

    # -------- Automated --------
    if mode == "automated":
        if run_state_exists():
            print("\n Previous partial state detected. Cleaning it before automated run.")
            delete_run_state()
            
        setup_backend()

        vpc_id, public_subnet_ids, protected_subnet_ids, sg_id, network_applied = setup_network(region=region)
        print("Nishant is testing")
        print("--------------------------------")
        print(f"\nVPC ID: {vpc_id} || Public Subnets: {public_subnet_ids} || Protected Subnets: {protected_subnet_ids} || AMI SG: {sg_id}")
        print(public_subnet_ids[0])
        print("--------------------------------")
        ami_id = build_ami(vpc_id, public_subnet_ids[0], sg_id)

        setup_application(region=region)

        # Validation Architecture
        setup_validation()

        print("\n Automated setup complete.")


    # -------- Partial --------
    elif mode == "partial":

        args = sys.argv[3:]

        if "--vpc-id" not in args:
            print("Missing required arguments.")
            sys.exit(1)

        vpc_id = args[args.index("--vpc-id") + 1]

        public_subnet_ids = []
        protected_subnet_ids = []
        public_subnet_cidrs = []
        protected_subnet_cidrs = []
        ami_sg_id = None
        min_size = None
        max_size = None
        desired_capacity = None
        cpu_threshold = None

        if "--ami-sg-id" in args:
            ami_sg_id = args[args.index("--ami-sg-id") + 1]

        if "--min-size" in args:
            min_size = int(args[args.index("--min-size") + 1])

        if "--max-size" in args:
            max_size = int(args[args.index("--max-size") + 1])

        if "--desired-capacity" in args:
            desired_capacity = int(args[args.index("--desired-capacity") + 1])

        if "--cpu-threshold" in args:
            cpu_threshold = int(args[args.index("--cpu-threshold") + 1])

        if "--public-subnet-cidrs" in args:
            i = args.index("--public-subnet-cidrs") + 1
            while i < len(args) and not args[i].startswith("--"):
                public_subnet_cidrs.append(args[i])
                i += 1

        if "--protected-subnet-cidrs" in args:
            i = args.index("--protected-subnet-cidrs") + 1
            while i < len(args) and not args[i].startswith("--"):
                protected_subnet_cidrs.append(args[i])
                i += 1

        print("\n=== PARTIAL MODE ===")
        print(f"Region: {region}")
        print(f"VPC: {vpc_id}")

        if not public_subnet_cidrs or not protected_subnet_cidrs:
            print("When providing --vpc-id, you must provide both --public-subnet-cidrs and --protected-subnet-cidrs.")
            sys.exit(1)

        backend_applied = setup_backend()

        vpc_id, public_subnet_ids, protected_subnet_ids, sg_id, network_applied = setup_network(
            region=region,
            vpc_id=vpc_id if vpc_id else None,
            public_subnet_cidrs=public_subnet_cidrs if public_subnet_cidrs else None,
            protected_subnet_cidrs=protected_subnet_cidrs if protected_subnet_cidrs else None,
            ami_sg_id=ami_sg_id if ami_sg_id else None
        )

        if public_subnet_ids:
            subnet_for_ami = public_subnet_ids[0]
        else:
            print("Cannot build AMI without public subnet IDs.")
            sys.exit(1)

        ami_id = build_ami(vpc_id, subnet_for_ami, sg_id)

        setup_application(
            vpc_id,
            protected_subnet_ids,
            ami_id=ami_id,
            region=region,
            min_size=min_size,
            max_size=max_size,
            desired_capacity=desired_capacity,
            cpu_threshold=cpu_threshold
        )

        setup_validation(
            vpc_id=vpc_id,
            protected_subnet_ids=protected_subnet_ids,
            region=region
        )

        save_run_state({
            "mode": "partial",
            "region": region,
            "vpc_id": vpc_id,
            "ami_sg_id": ami_sg_id,
            "ami_id": ami_id,
            "public_subnet_ids": public_subnet_ids,
            "protected_subnet_ids": protected_subnet_ids,
            "public_subnets_cidrs": public_subnet_cidrs,
            "protected_subnets_cidrs": protected_subnet_cidrs,
            "min_size": min_size,
            "max_size": max_size,
            "desired_capacity": desired_capacity,
            "cpu_threshold": cpu_threshold,
            "backend_applied": backend_applied,
            "network_applied": network_applied
        })


        print("\n Partial setup complete.")


    # -------- Destroy --------
    elif mode == "destroy":
    # If partial state exists, use it
        if run_state_exists():
            destroy_partial_from_state()
        else:
            destroy_all(region)
        print("\nDestroy complete.")
    elif mode == "validation":
        if len(sys.argv) < 4:
            print("""
    Validation Usage:

    python phoenix.py validation <region> lambda
    python phoenix.py validation <region> list
    python phoenix.py validation <region> delete
            """)
            sys.exit(1)

        action = sys.argv[3]

        if action == "lambda":
            validate_lambda(region)

        elif action == "list":
            list_instances(region)

        elif action == "delete":
            delete_instance(region)

        else:
            print("Invalid validation action.")
    else:
        print("Invalid mode.")
