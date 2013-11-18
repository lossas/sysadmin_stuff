#!/usr/bin/python
# -*- coding: utf-8 -*-

import requests
import sys
import json
import argparse

def pars_args():

    parser = argparse.ArgumentParser()
    parser.add_argument("--revision_id", type=str, help="revision of the deployment", required=True)
    parser.add_argument("--deployed_by", type=str, help="by whom was made the deployment", required=True)
    parser.add_argument("--deployed_to", type=str, help="where should be deployed", required=True)
    parser.add_argument("--repository", type=str, help="deployment repository", required=True)
    args = parser.parse_args()
    #print args.revision_id
    
    headers = {
            'content-type': 'application/json',
            'x-stackdriver-apikey': '5E432P7P50PBNEZFP7XHIW1OPLLS1GOF'
    }
    
    deploy_event = {
            'revision_id': args.revision_id,
            'deployed_by': args.deployed_by,
            'deployed_to': args.deployed_to,
            'repository': args.repository
    }
    
    var=json.dumps(deploy_event)
    resp = requests.post(
            'https://event-gateway.stackdriver.com/v1/deployevent',
            data=var,
            headers=headers
    )
    
if __name__ == "__main__":
	pars_args()