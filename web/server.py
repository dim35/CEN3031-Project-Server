from flask import Flask, request
from datetime import datetime
import sys
import sqlite3
import hashlib

app = Flask(__name__, static_url_path='/static')

@app.route('/api/login', methods=['POST'])
def login():
     username = request.form['username']
     psw = rewquest.form['psw']

     conn = sqlite3.connect('/home/ubuntu/database.db')
     c = conn.cursor()

     out = c.execute("SELECT usr, psw FROM users WHERE usr=? AND hash=?", username, hashlib.sha512(psw.encode('utf-8')).hexdigest())
     conn.close()

     if(out != None):
          return -1
     else:
          # Generate the session token
          return hashlib.sha512(username + str(datetime.now()))


@app.route('/api/logout', methods=['POST'])
def logout():
     return -1

@app.route('/api/createuser', methods=['POST'])
def createuser():
#     print(request.form['username'], request.form['psw'], request.form['psw-repeat'], file=sys.stderr)
     if request.form['psw'] != request.form['psw-repeat']:
          return app.send_static_file('createacc_passwords_do_not_match.html')

     conn = sqlite3.connect('/home/ubuntu/database.db')
     c = conn.cursor()
     t = (request.form['username'], )
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
     app.run(debug=True, host='0.0.0.0', port=443, ssl_context=('/home/ubuntu/cert.pem', '/home/ubuntu/key.pem'))
