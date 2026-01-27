#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import os

TUNNEL_URL_FILE = "/app/tunnel_url.txt"

class TunnelHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/tunnel" or self.path == "/":
            try:
                if os.path.exists(TUNNEL_URL_FILE):
                    with open(TUNNEL_URL_FILE, "r") as f:
                        url = f.read().strip()
                    self.send_response(200)
                    self.send_header("Content-Type", "text/plain")
                    self.end_headers()
                    self.wfile.write(url.encode())
                else:
                    self.send_response(503)
                    self.send_header("Content-Type", "text/plain")
                    self.end_headers()
                    self.wfile.write(b"Tunnel not ready yet")
            except Exception as e:
                self.send_response(500)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(str(e).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # Отключаем логи

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8318), TunnelHandler)
    print("Tunnel URL server running on port 8318")
    server.serve_forever()
