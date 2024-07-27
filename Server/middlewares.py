from functools import wraps
from flask import request, g, jsonify
import jwt
from models import User

def auth_required(app):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            token = request.headers.get('x-auth-token')
            if not token:
                return jsonify({'message': 'No auth token, access denied'}), 401
            try:
                decoded_token = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
                g.user = User.objects.get(id=decoded_token['id'])
                g.token = token
            except jwt.ExpiredSignatureError:
                return jsonify({'message': 'Token expired, access denied'}), 401
            except jwt.InvalidTokenError:
                return jsonify({'message': 'Invalid token, access denied'}), 401
            except User.DoesNotExist:
                return jsonify({'message': 'User not found, access denied'}), 401
            except Exception as e:
                return jsonify({'error': str(e)}), 500

            return f(*args, **kwargs)
        return decorated_function
    return decorator
