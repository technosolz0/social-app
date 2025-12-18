# ============================================
# COMPLETE API DOCUMENTATION
# ============================================

"""
==================================================
🚀 COMPLETE API DOCUMENTATION
==================================================

BASE URLs:
- Django API: http://localhost:8000/api/v1/
- FastAPI: http://localhost:8001/
- Admin: http://localhost:8000/admin/
- API Docs: http://localhost:8000/api/docs/

==================================================
AUTHENTICATION
==================================================

POST /api/v1/users/register/
Body: {username, email, password}
Response: {user, access_token}

POST /api/v1/users/login/
Body: {email, password}
Response: {access, refresh, user}

GET /api/v1/users/me/
Headers: Authorization: Bearer {token}
Response: {user with profile, points, level}

==================================================
CONTENT
==================================================

POST /api/v1/posts/
Body: {post_type, caption, media_url, hashtags}
Response: {post}

GET /api/v1/posts/feed/
Response: {posts from following users}

GET /api/v1/posts/trending/
Response: {trending posts}

GET /feed/for-you (FastAPI)
Response: {personalized feed with ML ranking}

POST /api/v1/stories/
Body: {media_url, media_type}
Response: {story}

==================================================
SOCIAL
==================================================

POST /api/v1/follows/follow_user/
Body: {user_id}
Response: {message}

POST /api/v1/likes/
Body: {post_id}
Response: {liked: true/false}

POST /api/v1/comments/
Body: {post, text}
Response: {comment}

==================================================
GAMIFICATION
==================================================

GET /api/v1/gamification/my_stats/
Response: {points, level, badges}

GET /api/v1/gamification/leaderboard/
Response: [{rank, user, points}]

GET /api/v1/gamification/daily_quests/
Response: [{quest, progress}]

==================================================
CHAT (WebSocket)
==================================================

WS ws://localhost:8000/ws/chat/{conversation_id}/

Messages:
- Send: {type: 'message', content: 'text'}
- Typing: {type: 'typing', is_typing: true}
- Read: {type: 'read_receipt', message_id: 'xxx'}

POST /api/v1/conversations/create_direct_message/
Body: {user_id}
Response: {conversation}

==================================================
LIVE STREAMING (WebSocket)
==================================================

WS ws://localhost:8000/ws/stream/{stream_id}/

POST /api/v1/streams/create_stream/
Body: {title, description}
Response: {stream with stream_key}

POST /api/v1/streams/{id}/start/
Response: {status: 'started'}

==================================================
AI FEATURES
==================================================

POST /api/v1/ai/
Actions:
- generate_caption: {action: 'generate_caption', image_url}
- moderate: {action: 'moderate', url, text}
- analyze_sentiment: {action: 'analyze_sentiment', text}
- detect_objects: {action: 'detect_objects', image_url}

==================================================
PAYMENTS
==================================================

GET /api/v1/packages/
Response: [{coin packages}]

POST /api/v1/payments/create_stripe_payment/
Body: {package_id}
Response: {client_secret, payment_id}

POST /api/v1/payments/create_paypal_payment/
Body: {package_id}
Response: {approval_url, order_id}

POST /api/v1/payments/{id}/confirm_payment/
Response: {status: 'completed'}

==================================================
NOTIFICATIONS
==================================================

GET /api/v1/notifications/
Response: [{notifications}]

GET /api/v1/notifications/unread_count/
Response: {unread_count}

POST /api/v1/notifications/{id}/mark_read/
Response: {status}

POST /api/v1/devices/
Body: {device_type, fcm_token}
Response: {device}

GET /api/v1/preferences/
Response: {notification preferences}

==================================================
RECOMMENDATIONS (FastAPI)
==================================================

GET /recommendations/users
Response: {users to follow}

GET /recommendations/content
Response: {recommended posts}

GET /recommendations/hashtags
Response: {trending hashtags}

==================================================
ANALYTICS (FastAPI)
==================================================

POST /analytics/track
Body: {event_type, event_data}
Response: {status: 'tracked'}

GET /analytics/user-engagement
Response: {views, likes, engagement_rate}
"""
