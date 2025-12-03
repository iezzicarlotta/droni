from flask import Blueprint, jsonify, request
from db import get_connection
from auth import require_api_key

bp = Blueprint("traces", __name__, url_prefix="/api")

@bp.route("/mission/<int:mission_id>/traces", methods=["GET"])
@require_api_key
def get_traces(mission_id):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT latitudine,longitudine,TIMESTAMP FROM Traccia WHERE id_missione=%s ORDER BY TIMESTAMP ASC",
                        (mission_id,))
            rows = cur.fetchall()
            return jsonify({"success": True, "data": rows})
    finally:
        conn.close()
