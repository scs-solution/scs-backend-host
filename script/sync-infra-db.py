import json
import sys
import requests

infraName = sys.argv[1]
tfstateFile = sys.argv[2]
updateKey = sys.argv[3]

instances = []

with open(tfstateFile, 'r', encoding='utf-8') as f:
    data = json.load(f)

    for res in data['resources']:
        if res['type'] is 'aws_spot_instance_request':
            instances.append({
                'name': res['name'],
                'instanceId': res['instances']['attributes']['spot_instance_id'],
                'privateIp': res['instances']['attributes']['private_ip'],
                'publicIp': res['instances']['attributes']['public_ip'],
            })

updateDto = {
    'instances': instances,
    'infraName': infraName,
    'updateKey': updateKey
}

headers = {'Content-Type': 'application/json; charset=utf-8'}
requests.put('http://127.0.0.1:3000/api/v1/infra',
             headers=headers, data=json.dumps(updateDto))
