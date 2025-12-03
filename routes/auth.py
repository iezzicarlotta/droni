from flask import Blueprint, request, session, jsonify
from auth import check_credentials
from config import API_KEY

bp = Blueprint("auth", __name__, url_prefix="/api")

@bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    print('DEBUG /api/login - raw request data:', data)
    mail = data.get("mail")
    password = data.get("password")
    if not mail or not password:
        return jsonify({"success": False, "error": "mail and password required"}), 400
    user = check_credentials(mail, password)
    if not user:
        return jsonify({"success": False, "error": "Invalid credentials"}), 401
    # user is a dict from DB: ID, nome, cognome, ruolo, mail
    session["user_id"] = user["ID"]
    session["user_nome"] = user["nome"]
    session["user_cognome"] = user["cognome"]
    session["user_ruolo"] = user["ruolo"]
    # store API key in server-side session to authorize subsequent API calls from client
    session['api_key'] = API_KEY
    return jsonify({"success": True, "user": {"ID": user["ID"], "nome": user["nome"], "cognome": user["cognome"], "ruolo": user["ruolo"]}})

@bp.route("/logout", methods=["POST"])
def logout():
    session.clear()
    return jsonify({"success": True})
