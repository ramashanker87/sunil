from http.server import BaseHTTPRequestHandler, HTTPServer
import os
MESSAGE1 = os.getenv("APP_MESSAGE1", "Hello from Docker and ")
MESSAGE2 = os.getenv("APP_MESSAGE2", " Amazon ECR from day 16!")

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(f"{MESSAGE1+MESSAGE2}\n".encode())

server = HTTPServer(("0.0.0.0", 8080), Handler)
print("Server running on port 8080")
server.serve_forever()