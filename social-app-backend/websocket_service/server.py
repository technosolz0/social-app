import asyncio
import websockets
import json
import redis.asyncio as redis
import os
from dotenv import load_dotenv

load_dotenv()

# Redis connection
redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'redis'),
    port=int(os.getenv('REDIS_PORT', 6379)),
    decode_responses=True
)

# Store active connections
active_connections = {}

async def chat_handler(websocket, path):
    """Handle WebSocket connections for chat"""
    try:
        # Extract user_id from path (e.g., /ws/chat/123)
        path_parts = path.strip('/').split('/')
        if len(path_parts) >= 3 and path_parts[1] == 'chat':
            user_id = path_parts[2]
        else:
            await websocket.send(json.dumps({
                'type': 'error',
                'message': 'Invalid path format. Use /ws/chat/{user_id}'
            }))
            return

        # Register connection
        active_connections[user_id] = websocket
        print(f"User {user_id} connected")

        # Send welcome message
        await websocket.send(json.dumps({
            'type': 'connected',
            'user_id': user_id,
            'message': f'Welcome to chat, user {user_id}!'
        }))

        async for message in websocket:
            try:
                data = json.loads(message)
                message_type = data.get('type', 'message')

                if message_type == 'message':
                    # Handle chat message
                    room_id = data.get('room_id')
                    text = data.get('text', '')

                    # Store message in Redis for persistence
                    message_data = {
                        'user_id': user_id,
                        'room_id': room_id,
                        'text': text,
                        'timestamp': asyncio.get_event_loop().time()
                    }

                    # Publish to Redis pub/sub for real-time distribution
                    await redis_client.publish(f'chat:{room_id}', json.dumps(message_data))

                    # Broadcast to all users in the room (simplified - in production you'd track room members)
                    for uid, conn in active_connections.items():
                        if conn != websocket:  # Don't echo back to sender
                            try:
                                await conn.send(json.dumps({
                                    'type': 'message',
                                    'user_id': user_id,
                                    'room_id': room_id,
                                    'text': text,
                                    'timestamp': message_data['timestamp']
                                }))
                            except Exception as e:
                                print(f"Error sending to user {uid}: {e}")

                elif message_type == 'typing':
                    # Handle typing indicator
                    room_id = data.get('room_id')
                    await redis_client.publish(f'typing:{room_id}', json.dumps({
                        'user_id': user_id,
                        'typing': data.get('typing', True)
                    }))

                elif message_type == 'join_room':
                    # Handle room joining
                    room_id = data.get('room_id')
                    await websocket.send(json.dumps({
                        'type': 'room_joined',
                        'room_id': room_id,
                        'message': f'Joined room {room_id}'
                    }))

            except json.JSONDecodeError:
                await websocket.send(json.dumps({
                    'type': 'error',
                    'message': 'Invalid JSON format'
                }))
            except Exception as e:
                print(f"Error processing message: {e}")
                await websocket.send(json.dumps({
                    'type': 'error',
                    'message': 'Internal server error'
                }))

    except Exception as e:
        print(f"Connection error: {e}")
    finally:
        # Clean up connection
        if user_id in active_connections:
            del active_connections[user_id]
            print(f"User {user_id} disconnected")

async def main():
    """Start the WebSocket server"""
    server = await websockets.serve(
        chat_handler,
        "0.0.0.0",
        int(os.getenv('WS_PORT', 8002)),
        ping_interval=30,
        ping_timeout=10
    )

    print(f"WebSocket server started on ws://0.0.0.0:{os.getenv('WS_PORT', 8002)}")
    await server.wait_closed()

if __name__ == "__main__":
    asyncio.run(main())
