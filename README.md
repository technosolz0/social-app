# Social Media App 📱

A comprehensive social media application built with Flutter (frontend) and Django/FastAPI (backend), featuring real-time chat, gamification, reels, and more.

## 🏗️ Architecture

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: Go Router
- **UI**: Material Design 3
- **Features**:
  - User authentication & profiles
  - Posts, stories, and reels
  - Real-time chat & group messaging
  - Gamification (points, badges, leaderboard)
  - Activity tracking
  - Push notifications (Firebase)

### Backend (Microservices)
- **Django + DRF**: Main API, user management, posts
- **FastAPI**: Feed algorithms, recommendations, analytics
- **WebSocket**: Real-time messaging
- **Celery**: Background tasks
- **PostgreSQL**: Primary database
- **Redis**: Cache & message broker
- **Nginx**: Reverse proxy & load balancer

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Flutter SDK (3.x)
- Android Studio / VS Code
- Git

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd social-app-backend
   ```

2. **Start all services:**
   ```bash
   # On Linux/Mac
   chmod +x start.sh
   ./start.sh

   # Or manually:
   docker-compose up --build -d
   ```

3. **Wait for services to start** (may take 2-3 minutes on first run)

4. **Verify services:**
   - Django API: http://localhost:8000
   - FastAPI: http://localhost:8001/docs
   - WebSocket: ws://localhost:8002

### Frontend Setup

1. **Install dependencies:**
   ```bash
   cd instachat
   flutter pub get
   ```

2. **Configure API endpoints:**
   - For Android emulator: `10.63.172.167:8000` (already configured)
   - For physical device: Use your computer's IP address
   - Update `lib/core/constants/api_constants.dart` if needed

3. **Run the app:**
   ```bash
   flutter run
   ```

## 📱 Features

### ✅ Core Features
- **Authentication**: Login, register, JWT tokens
- **User Profiles**: Edit profile, follow/unfollow, stats
- **Posts & Stories**: Create, like, comment, share
- **Reels**: Short-form video content with interactions
- **Real-time Chat**: Direct messages & group chats
- **Gamification**: Points, badges, leaderboard, quests
- **Activity Tracking**: User activity history
- **Search**: Find users and content

### 🎮 Gamification System
- **Points**: Earn points for engagement
- **Badges**: Achievement system with rarities
- **Leaderboard**: Competitive rankings
- **Quests**: Daily/weekly challenges
- **Streaks**: Activity streak tracking

### 💬 Chat System
- **Direct Messages**: One-on-one conversations
- **Group Chats**: Multi-user conversations
- **Real-time**: WebSocket-based messaging
- **Media Sharing**: Images, videos, files
- **Chat Settings**: Mute, wallpapers, notifications

## 🔧 Configuration

### API Endpoints
Update `instachat/lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8000';
```

### Environment Variables
Backend uses `.env` file. Key variables:
```env
DEBUG=True
DB_NAME=social_app
DB_USER=social_user
DB_PASSWORD=social_password
JWT_SECRET_KEY=your-secret-key
```

### Firebase (Optional)
For push notifications, configure `google-services.json` in `android/app/`.

## 🐳 Docker Services

### Available Services
- **django**: Main API (port 8000)
- **fastapi**: Feed & recommendations (port 8001)
- **websocket**: Real-time messaging (port 8002)
- **postgres**: Database (port 5432)
- **redis**: Cache & queue (port 6379)
- **nginx**: Reverse proxy (port 80)

### Useful Commands
```bash
# View logs
docker-compose logs -f django

# Restart service
docker-compose restart django

# Stop all services
docker-compose down

# Rebuild and restart
docker-compose up --build -d
```

## 📊 API Documentation

- **Django API**: http://localhost:8000/swagger/
- **FastAPI**: http://localhost:8001/docs
- **WebSocket**: ws://localhost:8002 (Socket.IO)

## 🧪 Testing

### Backend Tests
```bash
cd social-app-backend
docker-compose exec django python manage.py test
```

### Frontend Tests
```bash
cd instachat
flutter test
```

## 🚀 Deployment

### Production Setup
1. Update environment variables for production
2. Configure SSL certificates
3. Set up proper database backups
4. Configure monitoring (Sentry)
5. Set up CI/CD pipelines

### Scaling
- Use Redis cluster for caching
- PostgreSQL read replicas
- Load balancer for multiple instances
- CDN for media files

## 🐛 Troubleshooting

### Common Issues

**Backend Connection Timeout:**
- Ensure Docker services are running: `docker-compose ps`
- Check IP address in API constants
- Verify firewall settings

**Firebase Initialization Failed:**
- Check `google-services.json` configuration
- Ensure correct package name in Firebase console

**Database Connection Issues:**
- Check PostgreSQL container logs
- Verify database credentials in `.env`

**WebSocket Connection Failed:**
- Ensure WebSocket service is running on port 8002
- Check network connectivity

### Logs & Debugging
```bash
# Backend logs
docker-compose logs -f

# Flutter logs
flutter logs

# Clear Flutter cache
flutter clean && flutter pub get
```

## 📝 Development

### Code Structure
```
instachat/
├── lib/
│   ├── core/           # Constants, themes, utilities
│   ├── data/           # Models, services, repositories
│   ├── domain/         # Business logic, use cases
│   ├── presentation/   # UI, providers, screens
│   └── main.dart

social-app-backend/
├── django_core/        # Django application
├── fastapi_service/    # FastAPI microservice
├── websocket_service/  # WebSocket server
├── celery_worker/      # Background tasks
└── docker-compose.yml
```

### Adding New Features
1. Create models in `data/models/`
2. Add API endpoints in services
3. Create providers for state management
4. Build UI screens and widgets
5. Add navigation routes in `app.dart`

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For questions or issues:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the API documentation

---

**Happy coding! 🎉**
