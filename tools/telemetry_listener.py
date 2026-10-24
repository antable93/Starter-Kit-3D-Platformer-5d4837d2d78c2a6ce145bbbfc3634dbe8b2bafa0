import json
import socket

HOST = "127.0.0.1"
PORT = 9001

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((HOST, PORT))
print(f"Listening for telemetry on udp://{HOST}:{PORT}")

while True:
    data, _ = sock.recvfrom(65535)
    try:
        msg = json.loads(data.decode("utf-8"))
        print(msg)
    except Exception:
        print(data.decode("utf-8", errors="replace"))
