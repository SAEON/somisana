import os
import platform
from os.path import join

homedir = os.path.expanduser("~")

CACHDIR = os.environ.get("CACHDIR") or (
    join(homedir, "Library", "Caches", "somisana")
    if platform.system() == "Darwin"
    else join(
        os.environ.get("LOCALAPPDATA") or join(homedir, "AppData", "Local"),
        "somisana-cache",
    )
    if platform.system() == "Windows"
    else join(os.environ.get("XDG_CACHE_HOME") or join(homedir, ".cache"), "somisana")
)
