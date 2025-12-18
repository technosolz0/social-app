# ============================================
# DEPLOYMENT GUIDE
# ============================================

"""
🚀 COMPLETE DEPLOYMENT GUIDE
====================================================

1️⃣ LOCAL DEVELOPMENT SETUP
====================================================

# Clone repository
git clone <repo-url>
cd social-app-backend

# Create environment file
cp .env.example .env
# Edit .env with your credentials

# Start services
docker-compose up -d --build

# Run migrations
docker-compose exec django python manage.py migrate

# Create superuser
docker-compose exec django python manage.py createsuperuser

# Initialize database
docker-compose exec django python scripts/init_db.py

# Seed test data (optional)
docker-compose exec django python scripts/seed_data.py

# Access services
# Django: http://localhost:8000
# FastAPI: http://localhost:8001
# Admin: http://localhost:8000/admin

====================================================
2️⃣ FIREBASE SETUP (Push Notifications)
====================================================

1. Go to Firebase Console: https://console.firebase.google.com
2. Create new project
3. Go to Project Settings > Service Accounts
4. Generate new private key
5. Save as firebase-credentials.json in django_core/
6. Update .env: FIREBASE_CREDENTIALS_PATH=/app/firebase-credentials.json

====================================================
3️⃣ AWS S3 SETUP (Media Storage)
====================================================

1. Create S3 bucket in AWS Console
2. Enable public access for media files
3. Create IAM user with S3 permissions
4. Get Access Key ID and Secret Access Key
5. Update .env with credentials

====================================================
4️⃣ STRIPE SETUP (Payments)
====================================================

1. Sign up at https://stripe.com
2. Get API keys from Dashboard
3. Create products and prices
4. Set up webhook endpoint: /api/v1/webhooks/stripe/
5. Update .env with keys

====================================================
5️⃣ PRODUCTION DEPLOYMENT
====================================================

OPTION A: AWS (EC2 + RDS + S3)
-------------------------------
1. Launch EC2 instance (Ubuntu 22.04)
2. Set up RDS PostgreSQL database
3. Create S3 bucket for media
4. Install Docker on EC2
5. Clone repository
6. Update .env with production values
7. Run: docker-compose -f docker-compose.prod.yml up -d

OPTION B: DigitalOcean (Droplet + Spaces)
-----------------------------------------
1. Create Droplet (Docker droplet recommended)
2. Set up managed PostgreSQL database
3. Create Spaces for media storage
4. Deploy with docker-compose

OPTION C: Google Cloud (GKE)
----------------------------
1. Create GKE cluster
2. Set up Cloud SQL
3. Use Cloud Storage for media
4. Deploy with Kubernetes manifests

====================================================
6️⃣ PRODUCTION CHECKLIST
====================================================

Security:
✅ Set DEBUG=False
✅ Change SECRET_KEY to 50+ random characters
✅ Set proper ALLOWED_HOSTS
✅ Enable HTTPS (SSL certificate)
✅ Set up firewall rules
✅ Enable CORS only for trusted domains

Performance:
✅ Enable Redis caching
✅ Set up CDN (CloudFront/Cloudflare)
✅ Configure Celery workers (4-8 workers)
✅ Enable database connection pooling
✅ Set up load balancer

Monitoring:
✅ Configure Sentry for error tracking
✅ Set up log aggregation (ELK/CloudWatch)
✅ Enable APM monitoring
✅ Set up uptime monitoring

Backup:
✅ Automated database backups (daily)
✅ Media files backup
✅ Configuration backup

====================================================
7️⃣ SCALING STRATEGIES
====================================================

Database:
- Use read replicas for read-heavy operations
- Implement database sharding for large datasets
- Use connection pooling (PgBouncer)

Caching:
- Redis for session, cache, Celery
- CloudFront/CDN for static/media files
- Cache expensive database queries

Load Balancing:
- Use Nginx/HAProxy for load balancing
- Multiple Django/FastAPI instances
- Separate Celery workers by queue

====================================================
8️⃣ MONITORING & MAINTENANCE
====================================================

# View logs
docker-compose logs -f

# Check service status
docker-compose ps

# Database backup
docker-compose exec postgres pg_dump -U social_user social_app > backup.sql

# Restart services
docker-compose restart

# Update code
git pull
docker-compose up -d --build

====================================================
9️⃣ PERFORMANCE OPTIMIZATION
====================================================

Database Optimization:
- Add indexes on frequently queried fields
- Use select_related/prefetch_related
- Optimize slow queries (use EXPLAIN)
- Implement database partitioning

API Optimization:
- Implement pagination for all list endpoints
- Use async views where possible
- Enable compression (gzip)
- Implement rate limiting

Celery Optimization:
- Use separate queues for different tasks
- Set task time limits
- Monitor queue sizes
- Scale workers based on load

====================================================
🎯 PRODUCTION ENVIRONMENT VARIABLES
====================================================

DEBUG=False
SECRET_KEY=<generate-with-python-secrets>
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

DATABASE_URL=postgresql://user:pass@production-db:5432/dbname
REDIS_URL=redis://production-redis:6379/0

# Use production S3 bucket
USE_S3=True
AWS_STORAGE_BUCKET_NAME=production-bucket

# Production payment keys
STRIPE_SECRET_KEY=sk_live_...
PAYPAL_MODE=live

# Enable monitoring
SENTRY_DSN=https://...@sentry.io/...

====================================================
💡 TIPS
====================================================

1. Always test in staging before production
2. Monitor error rates and performance metrics
3. Keep dependencies updated
4. Use environment-specific configurations
5. Implement proper logging
6. Set up CI/CD pipeline
7. Document all changes
8. Monitor costs (AWS/cloud services)
9. Have a rollback plan
10. Implement proper monitoring and alerting
"""
