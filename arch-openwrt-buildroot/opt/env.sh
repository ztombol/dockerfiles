#
# This script sets up the environment. Sourced from every command script,
# scripts that can be given as CMD to the container, e.g. `start.sh' and
# `config.sh'.
#

export DATA_DIR='/data'                  # Data directory.
export BUILDROOT_DIR="$DATA_DIR/openwrt" # Buildroot directory (DL source here).
