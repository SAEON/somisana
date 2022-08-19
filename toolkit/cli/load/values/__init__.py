from postgis import connect

def upsert(model, run_date):
  with open('cli/load/values/values.sql', 'r') as file:
    sql = file.read()
    cursor = connect().cursor()
    cursor.execute(sql, (model, run_date))