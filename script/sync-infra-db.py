import json
import sys
import requests

infraName = sys.argv[1]
tfstateFile = sys.argv[2]
updateKey = sys.argv[3]

instances = []

with open(tfstateFile, 'r', encoding='utf-8') as f:
    data = json.load(f)

    eip_instance_table = {}

    for res in data['resources']:
        if res['type'] == 'aws_eip':
            eip_instance_table[res['instances'][0]['attributes']
                               ['instance']] = res['instances'][0]['attributes']

    for res in data['resources']:
        if res['type'] == 'aws_spot_instance_request':
            instanceId = res['instances'][0]['attributes']['spot_instance_id']
            instances.append({
                'name': res['name'],
                'instanceId': instanceId,
                'privateIp': res['instances'][0]['attributes']['private_ip'],
                'publicIp': eip_instance_table[instanceId]['public_ip'],
                'eipId': eip_instance_table[instanceId]['id'],
            })

updateDto = {
    'instances': instances,
    'infraName': infraName,
    'updateKey': updateKey
}

headers = {'Content-Type': 'application/json; charset=utf-8'}
requests.put('http://127.0.0.1:3000/api/v1/infra',
             headers=headers, data=json.dumps(updateDto))
