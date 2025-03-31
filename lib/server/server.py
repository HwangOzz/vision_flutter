from flask import Flask, request, jsonify, Response, send_file
from flask_cors import CORS
from PIL import Image
import os, io, threading, socket, time
import pymcprotocol

app = Flask(__name__)
CORS(app)

# ====== 네트워크 설정 ======
VISION_IP = "10.10.24.230"
VISION_PORT = 2005

PLC_IP = "192.168.24.51"
PLC_PORT = 2002

# ====== PLC 연결 함수 ======
def create_plc_connection():
    plc = pymcprotocol.Type3E()
    plc.setaccessopt(commtype="ascii")
    plc.connect(PLC_IP, PLC_PORT)
    return plc

# ====== 검사 상태 수신 쓰레드 함수 ======
def vision_socket_thread():
    previous_result = None

    while True:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
                client_socket.settimeout(10)  # 타임아웃 설정
                client_socket.connect((VISION_IP, VISION_PORT))
                print(f"✅ 비전 센서 연결됨! (IP: {VISION_IP}, 포트: {VISION_PORT})")

                buffer = ""  # 받은 데이터 누적용

                while True:
                    try:
                        data = client_socket.recv(1024).decode('utf-8')
                        if not data:
                            print("⚠️ 비전 센서 응답 없음 (데이터 없음)")
                            time.sleep(1)
                            continue

                        buffer += data
                        # 데이터 끝에 개행(\n)이나 명확한 구분자가 있다면 분리
                        results = buffer.strip().split(",")
                        buffer = ""  # 버퍼 초기화

                        for result in results:
                            result = result.strip()

                            if "1P" in result:
                                current_result = 1
                            elif "1F" in result:
                                current_result = 0
                            else:
                                current_result = None

                            if current_result is not None and current_result != previous_result:
                                print(f"📌 검사 결과 변경됨! {previous_result} ➡ {current_result}")
                                try:
                                    plc = create_plc_connection()
                                    plc.batchwrite_wordunits("D1900", [current_result])
                                    plc.close()
                                    print(f"📡 D1900 = {current_result} 으로 전송 완료!")
                                except Exception as e:
                                    print(f"❌ D1900 전송 실패: {e}")
                                previous_result = current_result
                    except socket.timeout:
                        print("⏳ 비전 센서 응답 대기 중...")
                        continue

        except Exception as e:
            print(f"🚨 소켓 연결 오류: {e}")
            time.sleep(5)

# ====== Flask API ======

@app.route("/get_D1900_status", methods=["GET"])
def get_D1900_status():
    try:
        plc = create_plc_connection()
        value = plc.batchread_wordunits("D1900", 1)[0]
        plc.close()
        return jsonify({"status": int(value)}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/set_d100", methods=["POST"])
def set_d100():
    try:
        data = request.get_json()
        value = data.get("value")
        if value is None:
            return jsonify({"error": "Missing value"}), 400
        plc = create_plc_connection()
        plc.batchwrite_wordunits("D100", [value])
        plc.close()
        return jsonify({"success": True, "message": f"D100 = {value}"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/get_d100", methods=["GET"])
def get_d100():
    try:
        plc = create_plc_connection()
        value = plc.batchread_wordunits("D100", 1)[0]
        plc.close()
        return jsonify({"value": value}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/set_bit", methods=["POST"])
def set_bit():
    try:
        data = request.get_json()
        address = data.get("address")
        value = data.get("value")

        if not address or value not in [0, 1]:
            return jsonify({"error": "Invalid address or value"}), 400

        plc = create_plc_connection()
        plc.batchwrite_bitunits(headdevice=address, values=[value])
        plc.close()

        return jsonify({"success": True, "message": f"{address} = {value} 설정됨"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route("/get_m_bits", methods=["GET"])
def get_m_bits():
    try:
        plc = create_plc_connection()
        values = plc.batchread_bitunits("M0", 10)  # M0 ~ M9까지 10개 읽기
        plc.close()

        result = {f"M{i}": int(values[i]) for i in range(10)}  # 딕셔너리 형태로 변환
        return jsonify(result), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ====== 이미지 관련 ======
FAIL_IMAGE_FOLDER = r"\\10.10.24.194\VisionSensorImages\Fail"

@app.route('/get_fail_count', methods=['GET'])
def get_fail_count():
    fail_images = [f for f in os.listdir(FAIL_IMAGE_FOLDER) if f.endswith(".bmp")]
    return jsonify({"fail_count": len(fail_images)})

@app.route('/get_fail_images', methods=['GET'])
def get_fail_images():
    fail_images = [f for f in os.listdir(FAIL_IMAGE_FOLDER) if f.endswith(".bmp")]
    return jsonify(fail_images)

@app.route("/get_image/<filename>")
def get_image(filename):
    try:
        file_path = os.path.join(FAIL_IMAGE_FOLDER, filename)
        if not os.path.exists(file_path):
            return jsonify({"error": "File not found"}), 404
        with Image.open(file_path) as img:
            img = img.convert("RGBA")
            img_io = io.BytesIO()
            img.save(img_io, format="PNG")
            img_io.seek(0)
        return Response(img_io, mimetype="image/png")
    except Exception as e:
        return jsonify({"error": str(e)}), 500
# ====== QR코드 관련 ======
@app.route("/set_word", methods=["POST"])
def set_word():
    try:
        data = request.get_json()
        address = data.get("address")
        value = data.get("value")

        if not address or value is None:
            return jsonify({"error": "Invalid address or value"}), 400

        plc = create_plc_connection()
        plc.batchwrite_wordunits(address, [int(value)])
        plc.close()

        return jsonify({"success": True, "message": f"{address} = {value} 설정됨"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ====== 서버 실행 + 비전센서 쓰레드 시작 ======
if __name__ == "__main__":
    threading.Thread(target=vision_socket_thread, daemon=True).start()
    print("🚀 Flask 서버 시작 중...")
    app.run(host="0.0.0.0", port=5000, debug=True)
