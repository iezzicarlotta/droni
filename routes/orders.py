from flask import Blueprint, jsonify, request, session
from db import get_connection
from auth import require_api_key, login_required

bp = Blueprint("orders", __name__, url_prefix="/api")

@bp.route("/order/<int:order_id>", methods=["GET"])
@require_api_key
def get_order(order_id):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            sql = """
            SELECT o.ID, o.tipo, o.peso_totale, o.orario, o.indirizzo_destinazione,
                   m.stato AS stato_missione, o.id_missione
            FROM Ordine o
            LEFT JOIN Missione m ON o.id_missione = m.ID
            WHERE o.ID=%s
            """
            cur.execute(sql, (order_id,))
            row = cur.fetchone()
            if not row:
                return jsonify({"success": False, "error": "Order not found"}), 404
            return jsonify({"success": True, "data": row})
    finally:
        conn.close()


@bp.route('/my_orders', methods=['GET'])
@require_api_key
@login_required
def my_orders():
    user_id = session.get('user_id')
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            sql = """
            SELECT o.ID, o.tipo, o.peso_totale, o.orario, o.indirizzo_destinazione,
                   m.stato AS stato_missione, o.id_missione
            FROM Ordine o
            LEFT JOIN Missione m ON o.id_missione = m.ID
            WHERE o.id_utente=%s
            ORDER BY o.orario DESC
            """
            cur.execute(sql, (user_id,))
            rows = cur.fetchall()
            return jsonify({"success": True, "data": rows})
    finally:
        conn.close()
