#!/bin/bash
# set -x  # Enables debug mode 

# Get the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define paths using the absolute script directory
VENVDIR="${SCRIPT_DIR}/../kubespray-venv"
KUBESPRAYDIR="${SCRIPT_DIR}/../kubespray"
INVENTORY_DIR="${SCRIPT_DIR}/../inventories/dev"

python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip install -U -r requirements.txt


# Change to inventory directory
cd $INVENTORY_DIR

#uncomment if you don't want to check host keys and add them manually
#export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_ROLES_PATH=$KUBESPRAYDIR/roles

# Run ansible-playbook with full paths
${VENVDIR}/bin/ansible-playbook -i $INVENTORY_DIR $KUBESPRAYDIR/cluster.yml --private-key=${INVENTORY_DIR}/.ssh/id_rsa -b -u ubuntu -e ignore_assert_errors=yes -vvv
