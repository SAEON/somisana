#!/bin/bash

# Web CLI
export "PATH=$PATH:$(pwd)/web/bin"
chmod +x $(pwd)/web/bin/s

# Toolkit CLI
export "PATH=$PATH:$(pwd)/toolkit/bin"
alias som="somisana"
chmod +x $(pwd)/toolkit/bin/somisana