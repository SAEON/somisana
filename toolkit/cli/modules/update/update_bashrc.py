import subprocess
import os


def update_bashrc(args):
    version = args.version if args.version else "latest"
    script_path = os.path.abspath("install.sh")
    subprocess.call(["bash", script_path, version])
    print("Updated CLI to version", version)
    print(
        "Please run 'docker pull ghcr.io/saeon/somisana_toolkit_stable:{version}' to update the CLI"
    )
