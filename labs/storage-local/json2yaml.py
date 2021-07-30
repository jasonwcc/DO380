#!/usr/bin/env python3
'''
Simple JSON-to-YAML converter.

Reads JSON string input from STDIN, and outputs
YAML to STDOUT.

'''
import sys
import json

# 3rd Party; pip install PyYAML 
import yaml


# Read the string from STDIN
json_string = sys.stdin.read()

# Convert the JSON string to a Python object
python_data_object = json.loads(json_string)

# Convert the python object to YAML string
yaml_string = yaml.safe_dump_all(python_data_object,
                                 default_flow_style=False)

# Print the YAML string to STDOUT
print(yaml_string)
