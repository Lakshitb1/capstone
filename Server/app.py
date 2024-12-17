from flask import Flask, request, jsonify, g
from mongoengine import connect, DoesNotExist
from models import User, AccelerometerData
import logging
import jwt
from middlewares import auth_required  
import pickle
import csv
import numpy as np
import io
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
app.config['SECRET_KEY'] = 'passwordKey'  

try:
    connect(
        db='capstone',
        host='mongodb+srv://bhansalilakshit838:u6bR2xonL7TLqAgM@capstone.2hiypvs.mongodb.net/capstone?retryWrites=true&w=majority&appName=capstone',
        tls=True,
        tlsAllowInvalidCertificates=True 
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

        # Generate JWT token with expiration time
        token = jwt.encode(
            {"id": str(user.id)},  # Add expiration if desired
            app.config['SECRET_KEY'],
            algorithm="HS256"
        )

        return jsonify({"status": "success", "token": token}), 200
    except DoesNotExist:
        return jsonify({"status": "error", "message": "Invalid email or password"}), 400
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

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
        user_data.pop('_id') 
        return jsonify({**user_data, "token": g.token})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
with open('classifier.pkl', 'rb') as model_file:
    model = pickle.load(model_file)

@app.route('/predict', methods = ['POST'])
def predict():
    try:
        data = request.get_json()
        x = data['x']
        y = data['y']
        z = data['z']
        input_data = pd.DataFrame([[x,y,z]], columns=['x', 'y', 'z'])
        prediction = model.predict(input_data)
        print(prediction[0])
        return jsonify({'label':prediction[0]})
    except Exception as e:
        return jsonify({'error': str(e)}), 400


@app.route('/upload_csv', methods=['POST'])
@auth_required(app)
def upload_csv():
    try:
        current_user = g.user
        data = request.get_json()
        csv_string = data.get('csv_data')

        if not csv_string:
            return jsonify({"status": "error", "message": "CSV data is missing"}), 400

        # Parse CSV
        csv_reader = csv.DictReader(io.StringIO(csv_string))
        required_fields = {'x', 'y', 'z', 'label'}
        if not required_fields.issubset(csv_reader.fieldnames):
            return jsonify({"status": "error", "message": "CSV is missing required columns"}), 400

        # Create records and add references to user
        records = []
        for row in csv_reader:
            reading = AccelerometerData(
                x=float(row['x']),
                y=float(row['y']),
                z=float(row['z']),
                label=row['label'],
                user=current_user
            )
            reading.save()  # Save individual reading
            current_user.readings.append(reading)  # Add reference to user
            records.append(reading)

        current_user.save()  # Save the user document with updated readings
        return jsonify({"status": "success", "message": "Data uploaded successfully"}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

from werkzeug.security import check_password_hash

@app.route('/get_user_readings', methods=['GET'])
@auth_required(app)
def get_user_readings():
    try:
        current_user = g.user  # Authenticated user from the token

        # Fetch readings linked to the user
        readings = AccelerometerData.objects(user=current_user)
        readings_data = [
            {
                "x": reading.x,
                "y": reading.y,
                "z": reading.z,
                "label": reading.label,
                "timestamp": reading.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            }
            for reading in readings
        ]

        return jsonify({"status": "success", "readings": readings_data}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    

@app.route('/fetch_all_readings', methods=['GET'])
def fetch_all_readings():
    
    try:
        # Query all documents in the AccelerometerData collection
        readings = AccelerometerData.objects()

        # Transform the data into a JSON-friendly format
        readings_data = [
            {
                "x": reading.x,
                "y": reading.y,
                "z": reading.z,
                "label": reading.label,
                "timestamp": reading.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                "user_id": str(reading.user.id) if reading.user else None  # Include user ID if linked
            }
            for reading in readings
        ]

        return jsonify({"status": "success", "readings": readings_data}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500



if __name__ == "__main__":
    app.run(host='0.0.0.0', port=10000, debug=True)

