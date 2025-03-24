from flask import Flask, request, jsonify
import pymcprotocol

app = Flask(__name__)

PLC_IP = "192.168.3.250"
PLC_PORT = 2001

def create_plc_connection():
    plc = pymcprotocol.Type3E()
    plc.setaccessopt(commtype="ascii")
    plc.connect(PLC_IP, PLC_PORT)
    return plc

@app.route("/ping")
def ping():
    return "pong", 200

@app.route("/set_d100", methods=["POST"])
def set_d100():
    try:
        data = request.get_json()
        value = data.get("value")

        if value is None:
            return jsonify({"error": "Missing value"}), 400

        plc = create_plc_connection()
        plc.batchwrite_wordunits(headdevice="D100", values=[value])
        plc.close()

        print(f"✅ D100에 {value} 기록 완료")
        return jsonify({"success": True, "message": f"D100 = {value}"}), 200

    except Exception as e:
        print(f"🚨 예외 발생: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/get_d100", methods=["GET"])
def get_d100():
    try:
        plc = create_plc_connection()
        value = plc.batchread_wordunits(headdevice="D100", readsize=1)[0]
        plc.close()

        print(f"🔍 D100 현재 값: {value}")
        return jsonify({"value": value}), 200
    except Exception as e:
        print(f"🚨 예외 발생: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
