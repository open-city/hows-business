import requests
import sqlite3
import csv

con = sqlite3.connect(":memory:")
cur = con.cursor()
cur.execute("CREATE TABLE licenses (account_number, site_number, application_type, payment_date)")

with open('business_permits.csv') as f:
    reader = csv.DictReader(f)
    values = ((row["ACCOUNT NUMBER"], 
               row["SITE NUMBER"], 
               row["APPLICATION TYPE"], 
               row["PAYMENT DATE"]) for row in reader)

    cur.executemany("INSERT INTO licenses VALUES (?, ?, ?, ?)", values)
    con.commit()

cur.execute("""
SELECT payment_date, count(*) 
FROM licenses INNER JOIN 
 (SELECT account_number, site_number, MIN(payment_date) AS payment_date 
  FROM licenses GROUP BY account_number, site_number) 
USING (account_number, site_number, payment_date) 
WHERE application_type='ISSUE' 
GROUP BY payment_date
""")

with open('daily_count.csv', 'w') as f:
    writer = csv.writer(f)
    for daily_count in cur.fetchall() :
        writer.writerow(daily_count)

