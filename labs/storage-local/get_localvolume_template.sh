#!/bin/bash

THIS_SCRIPT=$(realpath "$0")
SCRIPT_DIR=$(dirname "$THIS_SCRIPT")
OUTPUT_FILE="$SCRIPT_DIR/resources/localvolume.yml"

CSV_NAME=$(oc get csv -o name | head -n1)

if oc get "$CSV_NAME" \
     -o jsonpath='{.metadata.annotations.alm-examples}' | \
     "$SCRIPT_DIR"/json2yaml.py > "$OUTPUT_FILE"
then
    echo "Created $OUTPUT_FILE"
else
    echo "Failed to create $OUTPUT_FILE"
fi

