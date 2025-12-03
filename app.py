from flask import Flask
from flask_cors import CORS
from config import SECRET_KEY, DEBUG
from routes.orders import bp as orders_bp
from routes.missions import bp as missions_bp
from routes.traces import bp as traces_bp
from routes.admin import bp as admin_bp
from routes.auth import bp as auth_bp

app = Flask(__name__)
app.config["SECRET_KEY"] = SECRET_KEY
CORS(app)
app.config.update(
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax'
)

# blueprint
app.register_blueprint(orders_bp)
app.register_blueprint(missions_bp)
app.register_blueprint(traces_bp)
app.register_blueprint(admin_bp)
app.register_blueprint(auth_bp)


@app.route('/client')
def client_page():
    return app.send_static_file('client.html')


@app.route('/admin')
def admin_page():
    return app.send_static_file('admin.html')

@app.route("/")
def home():
    return app.send_static_file('index.html')

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=DEBUG)
