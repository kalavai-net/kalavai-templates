"""
Helper script to port jinja templates to helm chart templates
"""

import yaml
import json


TEMPLATE = "vllm"
INPUT_VALUES_FILE = f"charts/{TEMPLATE}/values.yaml"
INPUT_METADATA_FILE = f"charts/{TEMPLATE}/metadata.json"
OUTPUT_SCHEMA_FILE = f"charts/{TEMPLATE}/values.schema.json"
OUTPUT_VALUES_FILE = f"charts/{TEMPLATE}/values.yaml"
OUTPUT_CHART_FILE = f"charts/{TEMPLATE}/Chart.yaml"


def get_type(value):
    if isinstance(value, bool) or value in ["True", "False"]:
        return "boolean"
    if isinstance(value, str):
        return "string"
    
    return "integer"
    

if __name__ == "__main__":
    values = {
        "system": {
            "jobPriority": "user-spot-priority",
            "nodeSelectors": None,
            "nodeSelectorsOps": "OR"
        }
    }
    schema = {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "type": "object"
    }
    properties = {}
    required = []
    # parse values from YAML
    with open(INPUT_VALUES_FILE, "r") as f:
        data = yaml.safe_load(f)
    with open(INPUT_METADATA_FILE, "r") as f:
        metadata = yaml.safe_load(f)
    
    
    for property in data:
        words = property["name"].split("_")
        camel_name = words[0] + "".join([word.capitalize() for word in words[1:]])
        values[camel_name] = property["default"] if property["default"] != "" else None
        if values[camel_name] in ["True", "False"]:
            values[camel_name] = bool(values[camel_name])
        prop_type = get_type(property["default"])
        properties[camel_name] = {
            "description": property["description"],
            "type": prop_type if values[camel_name] is not None else [prop_type, "null"]
        }
        if property["required"]:
            required.append(camel_name)
    
    # Add job id
    properties["jobId"] = {
        "type": "string",
        "description": "Id to tag spawned objects."
    }
    
    # global system properties
    properties["system"] = {
        "properties": {
            "priorityClassName": {
                "type": "string",
                "description": "PriorityClassName to use for the deployment"
            },
            "nodeSelectors": {
                "type": ["object", "null"],
                "description": "target specific devices. Expected format -> key: value pairs, where 'value' is a list of elements"
            },
            "nodeSelectorsOps": {
                "type": "string",
                "enum": ["OR", "AND"],
                "description": "Logical operation to use to apply to nodeSelectors. Accepted values: 'OR', 'AND'"
            }
        }
    }
    schema["properties"] = properties
    schema["required"] = required + ["system"]

    with open(OUTPUT_SCHEMA_FILE, "w") as f:
        json.dump(schema, f, indent=3)

    with open(OUTPUT_VALUES_FILE, "w") as f:
        yaml.safe_dump(values, f)
    
    with open(OUTPUT_CHART_FILE, "w") as f:
        yaml.safe_dump({
            "apiVersion": "v2",
            "name": metadata["name"].lower().replace(" ", "-"),
            "version": "0.0.1",
            "kubeVersion": ">= 1.25.0",
            "description": metadata["description"],
            # dependencies: # A list of the chart requirements (optional)
            #   - name: The name of the chart (nginx)
            #     version: The version of the chart ("1.2.3")
            #     repository: (optional) The repository URL ("https://example.com/charts") or alias ("@repo-name")
            "maintainers": [
                {
                    "name": "Carlos Fernandez Musoles",
                    "email": "carlos@kalavai.net",
                    "url": "https://kalavai.net"
                }
            ],
            "sources": [metadata["docs"]],
            "icon": metadata["icon"],
            "appVersion": "0.0.1"
        }, f)

