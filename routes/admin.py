from flask import Blueprint, request, jsonify, session
from db import get_connection
from auth import require_api_key, login_required

bp = Blueprint("admin", __name__, url_prefix="/api/admin")


@bp.before_request
def require_admin_role():
    # ensure user is logged in and has admin role
    if 'user_id' not in session:
        return jsonify({"success": False, "error": "Login required"}), 401
    if session.get('user_ruolo') != 'admin':
        return jsonify({"success": False, "error": "Admin role required"}), 403

# ------------------- DRONE -------------------

@bp.route("/drones", methods=["GET"])
@require_api_key
@login_required
def list_drones():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM Drone")
            return jsonify({"success": True, "data": cur.fetchall()})
    finally:
        conn.close()

@bp.route("/drones", methods=["POST"])
@require_api_key
@login_required
def create_drone():
    data = request.get_json()
    required = ["modello","capacità","batteria"]
    for r in required:
        if r not in data:
            return jsonify({"success": False, "error": f"Missing field {r}"}), 400
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("INSERT INTO Drone (modello, `capacità`, batteria) VALUES (%s,%s,%s)",
                        (data["modello"], data["capacità"], data["batteria"]))
            conn.commit()
            return jsonify({"success": True, "drone_id": cur.lastrowid}), 201
    finally:
        conn.close()

@bp.route("/drones/<int:drone_id>", methods=["PUT"])
@require_api_key
@login_required
def update_drone(drone_id):
    data = request.get_json()
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("UPDATE Drone SET modello=%s, `capacità`=%s, batteria=%s WHERE ID=%s",
                        (data.get("modello"), data.get("capacità"), data.get("batteria"), drone_id))
            conn.commit()
            return jsonify({"success": True})
    finally:
        conn.close()

@bp.route("/drones/<int:drone_id>", methods=["DELETE"])
@require_api_key
@login_required
def delete_drone(drone_id):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM Drone WHERE ID=%s", (drone_id,))
            conn.commit()
            return jsonify({"success": True})
    finally:
        conn.close()

# ------------------- PILOTA -------------------

@bp.route("/pilots", methods=["GET"])
@require_api_key
@login_required
def list_pilots():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM Pilota")
            return jsonify({"success": True, "data": cur.fetchall()})
    finally:
        conn.close()

@bp.route("/pilots", methods=["POST"])
@require_api_key
@login_required
def create_pilot():
    data = request.get_json()
    required = ["nome","cognome","turno","brevetto"]
    for r in required:
        if r not in data:
            return jsonify({"success": False, "error": f"Missing field {r}"}), 400
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("INSERT INTO Pilota (nome,cognome,turno,brevetto) VALUES (%s,%s,%s,%s)",
                        (data["nome"], data["cognome"], data["turno"], data["brevetto"]))
            conn.commit()
            return jsonify({"success": True, "pilot_id": cur.lastrowid}), 201
    finally:
        conn.close()

@bp.route("/pilots/<int:pilot_id>", methods=["PUT"])
@require_api_key
@login_required
def update_pilot(pilot_id):
    data = request.get_json()
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("UPDATE Pilota SET nome=%s, cognome=%s, turno=%s, brevetto=%s WHERE ID=%s",
                        (data.get("nome"), data.get("cognome"), data.get("turno"), data.get("brevetto"), pilot_id))
            conn.commit()
            return jsonify({"success": True})
    finally:
        conn.close()

@bp.route("/pilots/<int:pilot_id>", methods=["DELETE"])
@require_api_key
@login_required
def delete_pilot(pilot_id):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM Pilota WHERE ID=%s", (pilot_id,))
            conn.commit()
            return jsonify({"success": True})
    finally:
        conn.close()

# ------------------- MISSIONE -------------------

@bp.route("/missions", methods=["GET"])
@require_api_key
@login_required
def list_missions():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM Missione")
            return jsonify({"success": True, "data": cur.fetchall()})
    finally:
        conn.close()

@bp.route("/missions/<int:mission_id>", methods=["PUT"])
@require_api_key
@login_required
def update_mission(mission_id):
    data = request.get_json()
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            sql = """
            UPDATE Missione
            SET data_missione=%s, ora=%s, latPrelievo=%s, longPrelievo=%s,
                latConsegna=%s, longConsegna=%s, stato=%s, id_drone=%s, id_pilota=%s
            WHERE ID=%s
            """
            cur.execute(sql, (
                data.get("data_missione"), data.get("ora"), data.get("latPrelievo"), data.get("longPrelievo"),
                data.get("latConsegna"), data.get("longConsegna"), data.get("stato"),
                data.get("id_drone"), data.get("id_pilota"), mission_id
            ))
            conn.commit()
            return jsonify({"success": True})
    finally:
        conn.close()

@bp.route("/missions/<int:mission_id>", methods=["DELETE"])
@require_api_key
@login_required
def delete_mission(mission_id):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM Missione WHERE ID=%s", (mission_id,))
            conn.commit()
            return jsonify({"success": True})
    finally:
        conn.close()

# ------------------- ORDINE -------------------

@bp.route("/orders", methods=["GET"])
@require_api_key
@login_required
def list_orders():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM Ordine")
            return jsonify({"success": True, "data": cur.fetchall()})
    finally:
        conn.close()

@bp.route("/orders/<int:order_id>", methods=["PUT"])
@require_api_key
@login_required
def update_order(order_id):
    data = request.get_json()
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            sql = """
            UPDATE Ordine
            SET tipo=%s, peso_totale=%s, orario=%s, indirizzo_destinazione=%s, id_missione=%s, id_utente=%s
            WHERE ID=%s
            """
            cur.execute(sql, (
                data.get("tipo"), data.get("peso_totale"), data.get("orario"),
                data.get("indirizzo_destinazione"), data.get("id_missione"),
                data.get("id_utente"), order_id
            ))
            conn.commit()
            return jsonify({"success": True})
    finally:
        conn.close()

@bp.route("/orders/<int:order_id>", methods=["DELETE"])
@require_api_key
@login_required
def delete_order(order_id):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM Ordine WHERE ID=%s", (order_id,))
            conn.commit()
            return jsonify({"success": True})
    finally:
        conn.close()
