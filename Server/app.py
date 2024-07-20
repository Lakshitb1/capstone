from flask import Flask, request, jsonify
from mongoengine import connect, DoesNotExist
from models import User
import logging

app = Flask(__name__)

try:
    connect(
        db='capstone',
        host='mongodb+srv://bhansalilakshit838:u6bR2xonL7TLqAgM@capstone.2hiypvs.mongodb.net/capstone?retryWrites=true&w=majority&appName=capstone',
        tls=True,
        tlsAllowInvalidCertificates=True  # Add this line to bypass SSL verification temporarily
    )
    logging.info("Successfully connected to MongoDB")
except Exception as e:
    logging.error("Error connecting to MongoDB: %s", e)
    raise

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    if not username or not email or not password:
        return jsonify({"status": "error", "message": "All fields are required"}), 400

    if User.objects(username=username).first():
        return jsonify({"status": "error", "message": "Username already exists"}), 400

    if User.objects(email=email).first():
        return jsonify({"status": "error", "message": "Email already exists"}), 400

    user = User(username=username, email=email)
    user.set_password(password)
    user.save()

    return jsonify({"status": "success", "message": "User registered successfully"}), 201

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({"status": "error", "message": "Email and password are required"}), 400

    try:
        user = User.objects.get(email=email)
        if not user.check_password(password):
            return jsonify({"status": "error", "message": "Invalid email or password"}), 400
    except DoesNotExist:
        return jsonify({"status": "error", "message": "Invalid email or password"}), 400

    return jsonify({"status": "success", "message": "Login successful"}), 200

if __name__ == "__main__":
    app.run(debug=True, port=5001)
