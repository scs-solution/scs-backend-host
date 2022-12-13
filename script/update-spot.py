import json
import sys
import requests

instanceId = sys.argv[1]
newInstanceId = sys.argv[2]
requestId = sys.argv[3]  # SpotInstanceRequestId
updateKey = sys.argv[4]

updateDto = {
    'instanceId': instanceId,
    'newInstanceId': newInstanceId,
    'requestId': requestId,
    'updateKey': updateKey
}

headers = {'Content-Type': 'application/json; charset=utf-8'}
requests.put('http://127.0.0.1:3000/api/v1/instance/spot',
             headers=headers, data=json.dumps(updateDto))
