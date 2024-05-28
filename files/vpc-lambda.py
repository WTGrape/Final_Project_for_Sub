import json
import base64
from datetime import datetime

def lambda_handler(event, context):
    output_records = []

    for record in event['records']:
        # Firehose에 전달된 데이터는 base64로 인코딩되어 있으므로 디코딩하여 사용합니다.
        payload = base64.b64decode(record['data']).decode('utf-8')
        
        # 라인을 공백을 기준으로 분리하여 필요한 정보를 추출합니다.
        data_items = payload.split()
        

        # 데이터 추출 및 변환
        transformed_data = {
            "version": data_items[0][-1:],
            "account_id": data_items[1],
            "interface_id": data_items[2],
            "srcaddr": data_items[3],
            "dstaddr": data_items[4],
            "srcport": data_items[5],
            "dstport": data_items[6],
            "protocol": data_items[7],
            "packets": data_items[8],
            "bytes": data_items[9],
            "start": datetime.utcfromtimestamp(int(data_items[10])).isoformat() + 'Z',
            "end": datetime.utcfromtimestamp(int(data_items[11])).isoformat() + 'Z',
            "action": data_items[12],
            "log_status": data_items[13].split("\"")[0],
            "primary_timestamp": datetime.utcfromtimestamp(int(data_items[10])).isoformat() + 'Z'  # UTC 타임스탬프 추가
        }
    
        # 변환된 데이터를 JSON 형식으로 인코딩합니다.
        output_data = json.dumps(transformed_data)
    
        # Firehose에 전달할 레코드 형식으로 변환합니다.
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(output_data.encode('utf-8')).decode('utf-8')
        }
        
        # 변환된 레코드를 결과 리스트에 추가합니다.
        output_records.append(output_record)

    return {'records': output_records}
