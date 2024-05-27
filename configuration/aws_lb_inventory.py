#!/usr/bin/env python3
import boto3
import json

client = boto3.client('elbv2')

def get_all_load_balancers():
    return client.describe_load_balancers()

def create_inventory(load_balancers):
    inventory = {}
    for lb in load_balancers['LoadBalancers']:
        dns_name = lb['DNSName']
        tags_response = client.describe_tags(ResourceArns=[lb['LoadBalancerArn']])
        for tag_desc in tags_response['TagDescriptions']:
            for tag in tag_desc['Tags']:
                if tag['Key'] == 'Name':
                    name = tag['Value']
                    if name not in inventory:
                        inventory[name] = []
                    inventory[name].append(dns_name)
    return inventory

def main():
    load_balancers = get_all_load_balancers()
    inventory = create_inventory(load_balancers)
    print(json.dumps(inventory, indent=4))

if __name__ == "__main__":
    main()

# ansible-inventory -i aws_lb_inventory.py --graph