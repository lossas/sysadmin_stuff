#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
import json
import time
import sys
import MySQLdb
from pprint import pprint
    

# the sql query returns the amount of inserts on the database during the last day
def inserts_on_tables(table_name):
    
    con = MySQLdb.connect('hostname', 'username', 'password', 'database')

    sql_query = "Select COUNT(couchbase_id) from " + table_name + " where createdInSQL <= now() and createdInSQL >= now() - INTERVAL 1 DAY"
    con.query(sql_query)
    result = con.use_result()
    res=result.fetch_row()[0]
    
    #pprint (res[0])   
    print "inserts: %s" % res
    
    data_point = {
        'name': table_name,
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
        'x-stackdriver-apikey': 'xxxxxx'           # use the api-key
        }
    resp = requests.post(
        'https://custom-gateway.stackdriver.com/v1/custom',
        data=json.dumps(gateway_msg),
        headers=headers)
    assert resp.ok, 'Failed to submit custom metric mygec_ins ' + res[0]
    
if __name__ == '__main__':
    
    mygec_tables = ['abc', 'foo', 'bar']            # use the tables you need
    
    for mt in mygec_tables:
        inserts_on_tables(mt)
