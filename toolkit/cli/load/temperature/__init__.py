from postgis import connect

def merge(model, run_date):
  with open('cli/load/temperature/temperature.sql', 'r') as file:
    sql = file.read()
    cursor = connect().cursor()
    cursor.execute(sql, (model, run_date))