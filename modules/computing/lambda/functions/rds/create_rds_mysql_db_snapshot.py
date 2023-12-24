import botocore  
import datetime  
import re  
import logging
import boto3
import os
 
region = 'us-east-1'  
instance = "mysqldb"

def lambda_handler(event, context):  
     source = boto3.client('rds', region_name=region)
     try:
         timestamp = str(datetime.datetime.now().strftime('%Y-%m-%d-%H-%-M-%S'))
         snapshot = "{0}-{1}-{2}".format(instance, "snapshot" ,timestamp)
         response = source.create_db_snapshot(DBSnapshotIdentifier=snapshot, DBInstanceIdentifier=instance)
         print(response)
     except botocore.exceptions.ClientError as e:
         raise Exception("Could not create snapshot: %s" % e)
