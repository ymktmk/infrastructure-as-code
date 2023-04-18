import json
import pymysql

host = "terraform-20230418141619130100000001.c7vrgulogxqu.ap-northeast-1.rds.amazonaws.com"
user = "admin"
password = "password"
db = "mydb"

connection = pymysql.connect(host=host, user=user, password=password, database=db)

def lambda_handler(event, context):
    
    with connection.cursor() as cursors:
        cursors.execute('show databases')
        print(cursors.fetchall())
    
    return {
        "statusCode": 200,
        "body": "ok!"
    }
