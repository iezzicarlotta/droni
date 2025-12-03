from flask import Blueprint, jsonify, request
from db import get_connection
from auth import require_api_key

bp = Blueprint("missions", __name__, url_prefix="/api")

@bp.route("/mission", methods=["POST"])
@require_api_key
def create_mission():
    data = request.get_json()
    required = ["data_missione","ora","latPrelievo","longPrelievo","latConsegna","longConsegna","id_drone","id_pilota","stato"]
    for r in required:
        if r not in data:
            return jsonify({"success": False, "error": f"Missing field {r}"}), 400
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            sql = """
            INSERT INTO Missione (data_missione, ora, latPrelievo, longPrelievo,
                                  latConsegna, longConsegna, stato, id_drone, id_pilota)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """
            cur.execute(sql, (
                data["data_missione"], data["ora"], data["latPrelievo"], data["longPrelievo"],
                data["latConsegna"], data["longConsegna"], data["stato"], data["id_drone"], data["id_pilota"]
            ))
            conn.commit()
            return jsonify({"success": True, "mission_id": cur.lastrowid}), 201
    finally:
        conn.close()

@bp.route("/mission/<int:mission_id>/rating", methods=["POST"])
@require_api_key
def mission_rating(mission_id):
    data = request.get_json()
    valutazione = data.get("valutazione")
    commento = data.get("commento")
    if not isinstance(valutazione, int) or not (1 <= valutazione <= 5):
        return jsonify({"success": False, "error": "valutazione must be int 1-5"}), 400
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("UPDATE Missione SET valutazione=%s, commento=%s WHERE ID=%s",
                        (valutazione, commento, mission_id))
            conn.commit()
            return jsonify({"success": True, "mission_id": mission_id})
    finally:
        conn.close()
