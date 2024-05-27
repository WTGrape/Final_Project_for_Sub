import json
from datetime import datetime
import base64

def lambda_handler(event, context):
    output = []

    for record in event['records']:
        payload = base64.b64decode(record['data']).decode('utf-8')
        j = json.loads(payload)

        # Do custom processing on the payload here
        # print(payload)
        ts = j['timestamp']
        ts /= 1000

        timestamp = datetime.utcfromtimestamp(ts).strftime('%Y-%m-%dT%H:%M:%S.%f+0000')

        j['timestamp'] = timestamp

        # j['action'] = 'BLOCK'

        payload = json.dumps(j)

        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(payload.encode('utf-8')).decode('utf-8')
        }
        output.append(output_record)

    print('Successfully processed {} records.'.format(len(event['records'])))

    return {'records': output}