from flask import Flask,request,jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:root@localhost:5432/flask_authentication'
db = SQLAlchemy(app)

# this class is for creating tables in db
class user(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80))
    email = db.Column(db.String(120))
    password = db.Column(db.String(80))

@app.route("/login",methods=["GET", "POST"])
def login():
    d = {}
    if request.method == "POST":
        uname = request.form["uname"]
        passw = request.form["passw"]
        
        login = user.query.filter_by(username=uname, password=passw).first()

        if login is not None:
            # account found
            d["status"] = 'Login Successfully'
            return jsonify(d)
        else:
            # account not exist
            d["status"] = 'Username or Password is incorrect'
            return jsonify(d)
            


@app.route("/register", methods=["GET", "POST"])
def register():
    d = {}
    if request.method == "POST":
        uname = request.form['uname']
        mail = request.form['mail']
        passw = request.form['passw']
        username = user.query.filter_by(username=uname).first()
        if username is None:
            register = user(username = uname, email = mail, password = passw)
            db.session.add(register)
            db.session.commit()
            d["status"] = 'User is registered succesfully'
            return jsonify(d)
        else:
            # already exist
            d["status"] = 'Username already exists'
            return jsonify(d)
        
if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(debug= True)
    