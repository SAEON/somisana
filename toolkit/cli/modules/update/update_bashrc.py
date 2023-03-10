import subprocess
import os


def update_bashrc(args):
    version = args.version if args.version else ""
    script_path = os.path.abspath("install.sh")
    subprocess.call(["bash", script_path, version])
    print("Updated CLI to version", version)
