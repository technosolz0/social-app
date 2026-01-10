from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response
import json
import base64
import os
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import padding

class EncryptionMiddleware(BaseHTTPMiddleware):
    # AES-256 Key (must be 32 bytes)
    KEY_STRING = 'd01851e405106173a11030e463584852'
    KEY = KEY_STRING.encode('utf-8')

    async def dispatch(self, request: Request, call_next):
        # Skip health check and root and docs
        if request.url.path in ["/", "/health", "/docs", "/openapi.json", "/redoc"]:
            return await call_next(request)

        # 1. Decrypt Request Body
        if request.method in ["POST", "PUT", "PATCH"]:
            try:
                # Read body
                body_bytes = await request.body()
                if body_bytes:
                    body_str = body_bytes.decode('utf-8')
                    try:
                        data = json.loads(body_str)
                        if isinstance(data, dict) and 'payload' in data:
                            decrypted_data = self.decrypt(data['payload'])
                            if decrypted_data:
                                # Replace the body in the request
                                # This is valid for Starlette/FastAPI requests
                                # We define a new receive function that returns the decrypted body
                                async def new_receive():
                                    return {"type": "http.request", "body": decrypted_data.encode('utf-8')}
                                
                                # Set request._receive to override the body reading mechanism
                                request._receive = new_receive
                    except (json.JSONDecodeError, UnicodeDecodeError):
                        pass
            except Exception as e:
                # print(f"Request decryption error: {e}")
                pass

        # 2. Process Request
        response = await call_next(request)

        # 3. Encrypt Response Body
        # Only for JSON responses
        content_type = response.headers.get("content-type", "")
        if "application/json" in content_type:
            try:
                # Read response body
                body_chunks = []
                async for chunk in response.body_iterator:
                    body_chunks.append(chunk)
                
                body_bytes = b"".join(body_chunks)
                body_str = body_bytes.decode('utf-8')

                # Check if already encrypted format (avoid double encrypt)
                try:
                    data = json.loads(body_str)
                    if isinstance(data, dict) and 'payload' in data and len(data) == 1:
                        # Already encrypted
                         return Response(
                            content=body_bytes,
                            status_code=response.status_code,
                            headers=dict(response.headers),
                            media_type=response.media_type
                        )
                except:
                    pass

                # Encrypt
                encrypted = self.encrypt(body_str)
                new_data = json.dumps({"payload": encrypted})
                
                # Update headers
                headers = dict(response.headers)
                headers['content-length'] = str(len(new_data))
                
                return Response(
                    content=new_data,
                    status_code=response.status_code,
                    headers=headers,
                    media_type="application/json"
                )
                
            except Exception as e:
                # Fallback to original content
                return Response(
                    content=body_bytes,
                    status_code=response.status_code,
                    headers=dict(response.headers),
                    media_type=response.media_type
                )
        
        return response

    def encrypt(self, data):
        iv = os.urandom(16)
        cipher = Cipher(algorithms.AES(self.KEY), modes.CBC(iv), backend=default_backend())
        encryptor = cipher.encryptor()
        
        padder = padding.PKCS7(128).padder()
        padded_data = padder.update(data.encode('utf-8')) + padder.finalize()
        
        encrypted = encryptor.update(padded_data) + encryptor.finalize()
        
        # Return IV:Ciphertext
        return base64.b64encode(iv).decode('utf-8') + ':' + base64.b64encode(encrypted).decode('utf-8')

    def decrypt(self, data):
        try:
            parts = data.split(':')
            if len(parts) != 2:
                return None
                
            iv = base64.b64decode(parts[0])
            ciphertext = base64.b64decode(parts[1])
            
            cipher = Cipher(algorithms.AES(self.KEY), modes.CBC(iv), backend=default_backend())
            decryptor = cipher.decryptor()
            
            padded_data = decryptor.update(ciphertext) + decryptor.finalize()
            
            unpadder = padding.PKCS7(128).unpadder()
            data = unpadder.update(padded_data) + unpadder.finalize()
            
            return data.decode('utf-8')
        except Exception as e:
            return None
