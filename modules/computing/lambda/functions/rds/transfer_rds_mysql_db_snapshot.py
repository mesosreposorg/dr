import boto3  
import botocore  
import datetime  
import re
import json
import os
    
source_region = "us-east-1"
dest_region = "us-west-2"
instance = "mysqldb"
iam = boto3.client('iam')  

def byTimestamp(snap):  
  if 'SnapshotCreateTime' in snap:
    return datetime.datetime.isoformat(snap['SnapshotCreateTime'])
  else:
    return datetime.datetime.isoformat(datetime.datetime.now())

def lambda_handler(event, context):  
    print("Received event: " + json.dumps(event, indent=2))
    #account_ids = []
    
    account = boto3.client('sts').get_caller_identity().get('Account')
    #account = account_ids[0]
    

    source = boto3.client('rds', region_name=source_region)

    source_instances = source.describe_db_instances(DBInstanceIdentifier= instance)
    source_snaps = source.describe_db_snapshots(DBInstanceIdentifier=instance)['DBSnapshots']
    snapshot_details = sorted(source_snaps, key=byTimestamp, reverse=True)
    for i in snapshot_details:
        if i['Status'] == 'available':
            source_snap_arn = 'arn:aws:rds:%s:%s:snapshot:%s' % (source_region, account, i['DBSnapshotIdentifier'])
            target_snap_id = (re.sub('rds:', '', i['DBSnapshotIdentifier']))
            print('Will Copy %s to %s' % (source_snap_arn, target_snap_id))
            target = boto3.client('rds', region_name=dest_region)

            try:
                response = target.copy_db_snapshot(
                SourceDBSnapshotIdentifier=source_snap_arn,
                TargetDBSnapshotIdentifier=target_snap_id,
                CopyTags = True)
                print(response)
            except botocore.exceptions.ClientError as e:
                raise Exception("Could not issue copy command: %s" % e)
            copied_snaps = target.describe_db_snapshots(SnapshotType='manual', DBInstanceIdentifier=instance)['DBSnapshots']
            break
