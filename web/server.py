from flask import Flask, request
from datetime import datetime
import sys
import sqlite3
import hashlib
import json

app = Flask(__name__, static_url_path='/static')

PATH_DB = 'database.db'
CERT = '.'

@app.route('/api/getdata', methods=['POST'])
def getdata():
     username = request.form['username']
     classs = request.form['class']
     conn = sqlite3.connect(PATH_DB)
     c = conn.cursor()

     out = c.execute("SELECT items, health, stamina, mana, posx, posy FROM data where usr=?", (username + " " + classs,))

     if(out.fetchone() == None):
          conn.close()
          return json.dumps({"items": "{}", "health": 100.0, "stamina": 100.0, "mana": 100.0, "posx": 0.0, "posy": 0.0}), 201
     else:
          output = out.fetchone()
          ret = json.dumps({"items": output[0], "health": output[1], "stamina": output[2], "mana": output[3], "posx": output[4], "posy": output[5]})
          conn.close()
          return ret, 200

@app.route('/api/setdata', methods=['POST'])
def setdata():
     username = request.form['username']
     classs = request.form['class']
     items = request.form['items']
     health = request.form['health']
     stamina = request.form['stamina']
     mana = request.form['mana']
     posx = request.form['posx']
     posy = request.form['posy']

     data = (username + " " + classs, items, health, stamina, mana, posx, posy)

     conn = sqlite3.connect(PATH_DB)
     c = conn.cursor()

     out = c.execute("REPLACE INTO data (usr, items, health, stamina, mana, posx, posy) VALUES (?,?,?,?,?,?,?)", data)

     conn.commit()
     conn.close()

     return json.dumps({"status": 1}), 200

@app.route('/api/login', methods=['POST'])
def login():
     username = request.form['username']
     psw = request.form['psw']

     conn = sqlite3.connect(PATH_DB)
     c = conn.cursor()

     out = c.execute("SELECT usr, hash FROM users WHERE usr=? AND hash=?", [username, hashlib.sha512(psw.encode('utf-8')).hexdigest()])

     if(out.fetchone() == None):
          conn.close()
          return json.dumps({"error":"not found"}), 666
     else:
          conn.close()
          # Generate the session token
          return json.dumps({"token": hashlib.sha512((username + str(datetime.now())).encode('utf-8')).hexdigest()}), 200


@app.route('/api/createaccount', methods=['POST'])
def createaccount():
#     print(request.form['username'], request.form['psw'], request.form['psw-repeat'], file=sys.stderr)
     if request.form['psw'] != request.form['psw-repeat']:
          return json.dumps({"error":"passwords do not match"}), 666

     if len(request.form['psw']) < 3:
          return json.dumps({"error":"password must be 3 characters or longer"}), 668

     conn = sqlite3.connect(PATH_DB)
     c = conn.cursor()
     t = (request.form['username'], )

     c.execute('CREATE TABLE IF NOT EXISTS users (usr text PRIMARY KEY, hash text NOT NULL)')
     c.execute("CREATE TABLE IF NOT EXISTS data (usr text PRIMARY KEY, items text, health real, stamina real, mana real, posx real, posy real)")

     c.execute("SELECT * FROM users WHERE usr=?", t)
     out = c.fetchone()

     if(out != None):
         return json.dumps({"error":"username in use"}), 667

     credentials = (request.form['username'], hashlib.sha512(request.form['psw'].encode('utf-8')).hexdigest())

     c.execute("INSERT INTO USERS VALUES(?,?)", credentials)

     #c.execute("SELECT * FROM users")
     #print(c.fetchall())

     conn.commit()
     conn.close()

     return json.dumps({"error":"none"}), 200

@app.route('/api/createuser', methods=['POST'])
def createuser():
#     print(request.form['username'], request.form['psw'], request.form['psw-repeat'], file=sys.stderr)
     if request.form['psw'] != request.form['psw-repeat']:
          return app.send_static_file('createacc_passwords_do_not_match.html')

     conn = sqlite3.connect(PATH_DB)
     c = conn.cursor()
     t = (request.form['username'], )

     c.execute('CREATE TABLE IF NOT EXISTS users (usr text PRIMARY KEY, hash text NOT NULL)')
     c.execute("CREATE TABLE IF NOT EXISTS data (usr text PRIMARY KEY, items text, health real, stamina real, mana real, posx real, posy real)")

     c.execute("SELECT * FROM users WHERE usr=?", t)
     out = c.fetchone()

     if(out != None):
         return app.send_static_file("createacc_username_in_use.html")

     credentials = (request.form['username'], hashlib.sha512(request.form['psw'].encode('utf-8')).hexdigest())

     c.execute("INSERT INTO USERS VALUES(?,?)", credentials)

     #c.execute("SELECT * FROM users")
     #print(c.fetchall())

     conn.commit()
     conn.close()

     return app.send_static_file("account_created.html")

@app.route('/')
def home():
     return app.send_static_file('createacc.html')

if __name__ == '__main__':
     app.run(debug=True, host='0.0.0.0', port=443, ssl_context=(CERT + '/cert.pem', CERT + '/key.pem'))
