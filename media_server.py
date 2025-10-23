#!/usr/bin/env python3
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from functools import partial
import os

PORT = 8001
MEDIA_DIR = os.path.join(os.path.dirname(__file__), "media")

class MediaHandler(SimpleHTTPRequestHandler):
    # Compatibilità con client vecchi (<5.12): POST /index.mth
    def do_POST(self):
        if self.path == "/index.mth":
            length = int(self.headers.get("Content-Length", 0) or 0)
            if length:
                self.rfile.read(length)  # scarta l'eventuale body
            self.path = "/index.mth"
            return SimpleHTTPRequestHandler.do_GET(self)
        self.send_error(405, "Method Not Allowed")

if __name__ == "__main__":
    handler = partial(MediaHandler, directory=MEDIA_DIR)  # <-- ROOT = ./media
    httpd = ThreadingHTTPServer(("0.0.0.0", PORT), handler)
    print(f"Servendo {MEDIA_DIR} su http://0.0.0.0:{PORT}/  (root = media)")
    httpd.serve_forever()
