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
            "resource-type": data_items[1],
            "account-id": data_items[2],
            "tgw-id": data_items[3],
            "tgw-attachment-id": data_items[4],
            "tgw-src-vpc-account-id": data_items[5],
            "tgw-dst-vpc-account-id": data_items[6],
            "tgw-src-vpc-id": data_items[7],
            "tgw-dst-vpc-id": data_items[8],
            "tgw-src-subnet-id": data_items[9],
            "tgw-dst-subnet-id": data_items[10],
            "tgw-src-eni": data_items[11],
            "tgw-dst-eni": data_items[12],
            "tgw-src-az-id": data_items[13],
            "tgw-dst-az-id": data_items[14],
            "tgw-pair-attachment-id": data_items[15],
            "srcaddr": data_items[16],
            "dstaddr": data_items[17],
            "srcport": data_items[18],
            "dstport": data_items[19],
            "protocol": data_items[20],
            "packets": data_items[21],
            "bytes": data_items[22],
            "start": datetime.utcfromtimestamp(int(data_items[23])).isoformat() + 'Z',
            "end": datetime.utcfromtimestamp(int(data_items[24])).isoformat() + 'Z',
            "log-status": data_items[25],
            "type": data_items[26],
            "packets-lost-no-route": data_items[27],
            "packets-lost-blackhole": data_items[28],
            "packets-lost-mtu-exceeded": data_items[29],
            "packets-lost-ttl-expired": data_items[30],
            "tcp-flags": data_items[31],
            "region": data_items[32],
            "flow-direction": data_items[33],
            "pkt-src-aws-service": data_items[34],
            "pkt-dst-aws-service": data_items[35].split("\"")[0],
            "timestamp": datetime.utcfromtimestamp(int(data_items[23])).isoformat() + 'Z'  # UTC 타임스탬프 추가            
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
