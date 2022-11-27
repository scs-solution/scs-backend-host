import json
import sys
import requests

instanceId = sys.argv[1]
amiId = sys.argv[2]
updateKey = sys.argv[3]

updateDto = {
    'instanceId': instanceId,
    'amiId': amiId,
    'updateKey': updateKey
}

headers = {'Content-Type': 'application/json; charset=utf-8'}
requests.put('http://127.0.0.1:3000/api/v1/instance/ami',
             headers=headers, data=json.dumps(updateDto))
