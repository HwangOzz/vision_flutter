from flask import Flask, request, jsonify, Response, send_file
from flask_cors import CORS
from PIL import Image
import os, io, threading, socket, time
import pymcprotocol

app = Flask(__name__)
CORS(app)


# ====== 전역 캐시용 변수 ======
m_bit_cache = [0] * 1000  # M0~M999 저장

# ====== 네트워크 설정 ======
VISION_IP = "10.10.24.230"
VISION_PORT = 2005

# ✅ 동적으로 변경 가능한 PLC IP와 포트
current_plc_ip = "192.168.3.250"
current_plc_port = 2005

# ====== PLC 연결 함수 ======
def create_plc_connection():
    plc = pymcprotocol.Type3E()
    plc.setaccessopt(commtype="ascii")
    plc.connect(current_plc_ip, current_plc_port)
    return plc

# ====== 검사 상태 수신 쓰레드 함수 ======
def vision_socket_thread():
    previous_result = None

    while True:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
                client_socket.settimeout(10)
                client_socket.connect((VISION_IP, VISION_PORT))
                print(f"✅ 비전 센서 연결됨! (IP: {VISION_IP}, 포트: {VISION_PORT})")

                buffer = ""

                while True:
                    try:
                        data = client_socket.recv(1024).decode('utf-8')
                        if not data:
                            print("⚠️ 비전 센서 응답 없음 (데이터 없음)")
                            time.sleep(1)
                            continue

                        buffer += data
                        results = buffer.strip().split(",")
                        buffer = ""

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

# ====== PLC API ======
def update_m_bit_cache_thread():
    global m_bit_cache
    while True:
        try:
            plc = create_plc_connection()
            temp_cache = []
            for i in range(0, 1000, 100):  # 100개씩 나눠서 읽기
                values = plc.batchread_bitunits(f"M{i}", 100)
                temp_cache.extend([int(v) for v in values])
            plc.close()
            m_bit_cache = temp_cache
        except Exception as e:
            print(f"❌ M 비트 캐시 업데이트 실패: {e}")
        time.sleep(1)  # 1초에 한 번 갱신

@app.route("/set_plc_info", methods=["POST"])
def set_plc_info():
    global current_plc_ip, current_plc_port
    try:
        data = request.get_json()
        new_ip = data.get("ip")
        new_port = data.get("port")

        if not new_ip:
            return jsonify({"error": "IP 주소 없음"}), 400
        if not isinstance(new_port, int):
            return jsonify({"error": "포트는 숫자여야 함"}), 400

        current_plc_ip = new_ip
        current_plc_port = new_port

        print(f"📡 PLC IP/Port 변경됨: {current_plc_ip}:{current_plc_port}")
        return jsonify({
            "success": True,
            "message": f"PLC IP가 {current_plc_ip}:{current_plc_port} 로 변경됨"
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

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
        start = int(request.args.get("start", 0))
        count = int(request.args.get("count", 10))
        if start < 0 or count < 1 or (start + count) > len(m_bit_cache):
            return jsonify({"error": "Invalid range"}), 400

        sliced = m_bit_cache[start:start+count]
        result = {f"M{start + i}": sliced[i] for i in range(len(sliced))}
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
    threading.Thread(target=update_m_bit_cache_thread, daemon=True).start()
    print("🚀 Flask 서버 시작 중...")
    app.run(host="0.0.0.0", port=5000, debug=True)