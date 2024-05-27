import json
import base64
import gzip
import boto3
from datetime import datetime

def lambda_handler(event, context):
    # 변환된 기록들을 담을 리스트
    transformed_records = []

    for record in event['records']:
        # Firehose로부터 전달된 이벤트에서 로그 메시지 추출
        # AWS Lambda에서 Firehose 이벤트 처리 시 base64 디코딩이 필요합니다.
        payload = base64.b64decode(record['data'])
        
        # gzip으로 압축된 데이터를 압축 해제
        decompressed_payload = gzip.decompress(payload).decode('utf-8')
        
        # 로그 메시지 추출
        log_event = json.loads(decompressed_payload)
        log_message = log_event['logEvents'][0]['message']  # 첫 번째 로그 이벤트를 사용합니다.

        # prefix와 timestamp 추가
        prefixed_log = f"prod-db-log: {log_message}"
        timestamp = datetime.utcnow().isoformat() + 'Z'

        # JSON 형식으로 변환
        json_log = {
            'log_message': prefixed_log,
            'timestamp': timestamp
        }

        # Firehose에 반환할 형식으로 변환
        transformed_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(json.dumps(json_log).encode('utf-8')).decode('utf-8')
        }

        transformed_records.append(transformed_record)

    return {'records': transformed_records}