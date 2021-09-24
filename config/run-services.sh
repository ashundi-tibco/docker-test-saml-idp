#!/bin/bash

# ========================================================================================
# Container initialization script.
#========================================

# ensure that initialization script is mounted

if [[ -d "/mounted/script/" && -f "/mounted/script/mock_ta.py" ]]; then
    cp /mounted/script/* config

    apache2ctl start

    echo "Started apache2ctl..."

    cd config/

    python3 mock_ta.py
else
    echo "Error: Expected files do not exist."
fi

################################################################################
# This image first starts the apache server and then executes
# mock_ta.py which in turn generates authsources.php having list of users
# from users.csv
################################################################################
