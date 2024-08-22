from flask import Flask, request, jsonify, g
from mongoengine import connect, DoesNotExist
from models import User
import logging
import jwt
from middlewares import auth_required  

app = Flask(__name__)
app.config['SECRET_KEY'] = 'passwordKey'  

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

@app.route('/register', methods=['POST'])
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

    return jsonify({"status": "success", "message": "User registered successfully! Login with the same credentials"}), 201

@app.route('/login', methods=['POST'])
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

        token = jwt.encode({"id": str(user.id)}, app.config['SECRET_KEY'], algorithm="HS256")

        return jsonify({"status": "success", "token": token}), 200
    except DoesNotExist:
        return jsonify({"status": "error", "message": "Invalid email or password"}), 400

@app.route('/tokenIsValid', methods=['POST'])
def token_is_valid():
    try:
        token = request.headers.get('x-auth-token')
        if not token:
            return jsonify(False)
        
        verified = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        if not verified:
            return jsonify(False)
        
        user = User.objects.get(id=verified['id'])
        if not user:
            return jsonify(False)
        
        return jsonify(True)
    except jwt.ExpiredSignatureError:
        return jsonify(False)
    except jwt.InvalidTokenError:
        return jsonify(False)
    except DoesNotExist:
        return jsonify(False)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/', methods=['GET'])
@auth_required(app)
def get_user_data():
    try:
        user = g.user
        user_data = user.to_mongo().to_dict()
        user_data.pop('_id')  # Remove _id from the response
        return jsonify({**user_data, "token": g.token})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5002, debug=True)
