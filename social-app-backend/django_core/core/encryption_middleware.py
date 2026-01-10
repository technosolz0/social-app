import json
import base64
import os
from django.utils.deprecation import MiddlewareMixin
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import padding

class EncryptionMiddleware(MiddlewareMixin):
    # AES-256 Key (must be 32 bytes)
    # Using the UTF-8 bytes of the string provided
    KEY_STRING = 'd01851e405106173a11030e463584852'
    KEY = KEY_STRING.encode('utf-8')
    
    def process_request(self, request):
        if not request.path.startswith('/api/'):
            return None
        
        # Skip for file uploads (multipart)
        if request.content_type.startswith('multipart/form-data'):
            return None

        # Skip if no body
        if not request.body:
            return None
            
        try:
            # We need to be careful not to break standard JSON parsing if unencrypted
            # But the requirement is "sab kuch encrypted".
            
            body_str = request.body.decode('utf-8')
            try:
                data = json.loads(body_str)
            except json.JSONDecodeError:
                return None
                
            if isinstance(data, dict) and 'payload' in data:
                encrypted_data = data['payload']
                decrypted_data = self.decrypt(encrypted_data)
                
                # Replace request body with decrypted data
                if decrypted_data:
                    request._body = decrypted_data.encode('utf-8')
                    # Also clear stream to force re-read if needed
                    request._stream = None
        except Exception as e:
            # print(f"Decryption Middleware Error: {e}")
            pass 

    def process_response(self, request, response):
        if not request.path.startswith('/api/'):
            return response
            
        # Only encrypt JSON responses
        if response.get('Content-Type') != 'application/json':
            return response
            
        # Avoid double encryption if something went wrong or recursive
        # Check if response code is successful or standard error
        # (We encrypt errors too)
        
        try:
            if hasattr(response, 'content'):
                content = response.content.decode('utf-8')
                
                # Simple check if it's already encrypted format (avoid double encrypt)
                # This is heuristic.
                try:
                    data = json.loads(content)
                    if isinstance(data, dict) and 'payload' in data and len(data) == 1:
                        return response
                except:
                    pass
                
                # Encrypt
                encrypted = self.encrypt(content)
                response_data = {'payload': encrypted}
                response.content = json.dumps(response_data)
                response['Content-Length'] = str(len(response.content))
            
        except Exception as e:
            print(f"Encryption Middleware Error: {e}")
            pass
            
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
            # print(f"Decrypt logic error: {e}")
            return None
