#!/usr/bin/env python3
import json

def extract_model_ids(json_file):
    """Extract the 'id' field from all data elements in the JSON file."""
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
        
        # Extract IDs from all data elements
        model_ids = [item['id'] for item in data['data']]
        
        return model_ids
    
    except FileNotFoundError:
        print(f"Error: File {json_file} not found")
        return []
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        return []
    except KeyError as e:
        print(f"Error: Missing key {e} in JSON structure")
        return []

if __name__ == "__main__":
    json_file = "models.json"
    
    # Extract model IDs
    ids = extract_model_ids(json_file)
    
    if ids:
        print("Model IDs:")
        print("[")
        for i, model_id in enumerate(ids):
            if i == len(ids) - 1:
                print(f'  "{model_id}"')
            else:
                print(f'  "{model_id}",')
        print("]")
        print(f"\nTotal models: {len(ids)}")
    else:
        print("No model IDs found or error occurred.")
