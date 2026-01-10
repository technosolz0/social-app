#!/bin/bash

# Social App Backend Startup Script
# This script helps you start the backend services for the social media app

echo "🚀 Starting Social App Backend Services..."
echo "=========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env 2>/dev/null || echo "# Add your environment variables here" > .env
    echo "✅ Created .env file. Please edit it with your configuration."
fi

# Build and start services
echo "🏗️  Building and starting services..."
echo "   This may take a few minutes on first run..."
echo ""

if command -v docker-compose &> /dev/null; then
    docker-compose up --build -d
else
    docker compose up --build -d
fi

# Wait for services to be healthy
echo ""
echo "⏳ Waiting for services to start..."
sleep 10

# Check service status
echo "📊 Service Status:"
echo "=================="

# Check if Django is running
if curl -s http://localhost:8000/health/ > /dev/null 2>&1; then
    echo "✅ Django API: http://localhost:8000"
else
    echo "❌ Django API: Not responding (may still be starting)"
fi

# Check if FastAPI is running
if curl -s http://localhost:8001/docs > /dev/null 2>&1; then
    echo "✅ FastAPI Service: http://localhost:8001"
else
    echo "❌ FastAPI Service: Not responding (may still be starting)"
fi

# Check if WebSocket is running
if nc -z localhost 8002 2>/dev/null; then
    echo "✅ WebSocket Service: ws://localhost:8002"
else
    echo "❌ WebSocket Service: Not responding (may still be starting)"
fi

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo "1. Wait a few more minutes for all services to fully start"
echo "2. Check service logs: docker-compose logs -f"
echo "3. For Flutter app, use IP: 192.168.43.227 (Android emulator) or your machine's IP"
echo "4. Access Django admin at: http://localhost:8000/admin/"
echo "5. Access FastAPI docs at: http://localhost:8001/docs"
echo ""
echo "🛑 To stop services: docker-compose down"
echo "🗑️  To stop and remove volumes: docker-compose down -v"
