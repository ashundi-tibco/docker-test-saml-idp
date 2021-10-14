#!/bin/bash

################################################################################
# This image expects to be mounted with /mounted/script/ and /mounted/data/
# folders containing optionally the init.sh script as well as the mandatory
# /mounted/script/mock_ta.py
################################################################################

set -x

# ensure that initialization script is mounted

if [[ -d "/mounted/script/" && -d /mounted/data/ && -f "/mounted/script/mock_ta.py" ]]; then

    cp /mounted/script/* config

    mkdir -p data/

    cp /mounted/data/* data

    if [[ -f /mounted/script/init.sh ]]; then
        source /mounted/script/init.sh
    fi

    apache2ctl start

    echo "Started apache2ctl..."

    cd config/

    python3 mock_ta.py
else
    echo "Error: Expected files do not exist."
fi
