from mongoengine import Document, StringField, ReferenceField, ListField, FloatField
import bcrypt

class User(Document):
    username = StringField(required=True, unique=True, max_length=80)
    email = StringField(required=True, unique=True, max_length=120)
    password = StringField(required=True)
    readings = ListField(ReferenceField('AccelerometerData'))  # List of references to readings

    def set_password(self, password):
        self.password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    def check_password(self, password):
        return bcrypt.checkpw(password.encode('utf-8'), self.password.encode('utf-8'))

class AccelerometerData(Document):
    x = FloatField(required=True)  # Change to FloatField
    y = FloatField(required=True)  # Change to FloatField
    z = FloatField(required=True)  # Change to FloatField
    label = StringField(required=True)
    user = ReferenceField('User', required=True)