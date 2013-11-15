#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
import json
import time
import sys
import MySQLdb
from pprint import pprint

# the sql-quey that is being used returns the updated records during the last day    
def updates_on_tables(table_name):
    
    con = MySQLdb.connect('hostname', 'username', 'password', 'db_name')

    sql_query = "Select COUNT(couchbase_id) from " + table_name + " where modifiedInSQL <= now() and modifiedInSQL >= now() - INTERVAL 1 DAY"
    con.query(sql_query)
    result = con.use_result()
    res=result.fetch_row()[0]
    
    #pprint (res[0])   
    print "updates: %s" % res
    
    data_point = {
        'name': 'updates_on_'+table_name,
        'value': res[0],
        'collected_at': int(time.time()),
        }
    gateway_msg = {
        'timestamp': int(time.time()),
        'proto_version': 1,
        'data': data_point,
        }
    headers = {
        'content-type': 'application/json',
        'x-stackdriver-apikey': 'xxxxxx'            # use your api-key
        }
    resp = requests.post(
        'https://custom-gateway.stackdriver.com/v1/custom',
        data=json.dumps(gateway_msg),
        headers=headers)
    assert resp.ok, 'Failed to submit custom metric' + res[0]
    
if __name__ == '__main__':
    
    list_tables = ['abc', 'foo', 'bar'] 	    #  use the name of the tables from wich you monitor the records 
    
    for mt in mygec_tables:
        updates_on_tables(mt)
