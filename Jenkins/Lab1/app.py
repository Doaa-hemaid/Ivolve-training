from flask import Flask, render_template, request
from configparser import ConfigParser
from flask_sqlalchemy import SQLAlchemy
import sqlalchemy
import os

app = Flask(__name__)

# Update the path to the config file to use an absolute path
config_path = os.path.join(os.path.dirname(__file__), 'config.ini')

# Read configuration from config.ini
config = ConfigParser()
config.read(config_path)

# Ensure that the 'App' section and 'PORT' key exist in the config
if 'App' not in config or 'PORT' not in config['App']:
    raise ValueError("Configuration error: 'App' section or 'PORT' key not found in config.ini")

# Access the port value from the config
port = int(config.get('App', 'PORT'))  # Convert the port to an integer

# Define the database_url using the config values
database_url = f"postgresql://{config.get('Database', 'USER')}:{config.get('Database', 'PASSWORD')}@db:5432/{config.get('Database', 'NAME')}"


# Initialize Flask-SQLAlchemy
app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# User model for the database
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)

@app.route('/')
def index():
    return 'Hello NTI students, welcome to the user registration app!'

@app.route('/user', methods=['GET', 'POST'])
def user():
    if request.method == 'POST':
        # Get user data from the form
        first_name = request.form.get('first_name')
        last_name = request.form.get('last_name')

        # Add user to the database
        new_user = User(first_name=first_name, last_name=last_name)
        db.session.add(new_user)
        db.session.commit()

    # Fetch all users from the database
    users = User.query.all()

    return render_template('user.html', users=users)

@app.route('/live')
def live():
    try:
        # Try to connect to the database
        engine = sqlalchemy.create_engine(database_url)
        connection = engine.connect()
        connection.close()
        return 'Well done'
    except Exception as e:
        return f'Maintenance: {str(e)}'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port, debug=True)

