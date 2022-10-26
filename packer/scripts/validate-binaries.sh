#!/usr/bin/env bash

# validate if req exist
DEFAULT_UTILS=(docker helm kubectl kind opa openssl policy git python3 curl npm jq)
for i in "${DEFAULT_UTILS[@]}"
do
    if ! command -v $i &> /dev/null
    then
        echo "$i could not be found"
        exit 1
    else
        echo "$i validated"
    fi
done
