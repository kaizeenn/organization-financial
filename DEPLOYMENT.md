# 🚀 Deployment Guide - Organization Financial Management System

## Deployment Options

### Option 1: VPS/Cloud Server (Recommended)

#### Prerequisites
- Ubuntu 20.04+ or similar Linux server
- Node.js 16+ installed
- MySQL 8+ installed
- Nginx (for reverse proxy)
- Domain name (optional)

#### Step-by-Step Deployment

##### 1. Setup Server
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js (using NodeSource)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation

# Install Nginx
sudo apt install nginx -y

# Install PM2 (Process Manager)
sudo npm install -g pm2
```

##### 2. Setup MySQL Database
```bash
# Login to MySQL
sudo mysql

# Create database and user
CREATE DATABASE organization_financial;
CREATE USER 'orgfin'@'localhost' IDENTIFIED BY 'your-strong-password';
GRANT ALL PRIVILEGES ON organization_financial.* TO 'orgfin'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Import database structure
mysql -u orgfin -p organization_financial < sql/organization_financial.sql

# Import demo data (optional)
mysql -u orgfin -p organization_financial < sql/seeder.sql
```

##### 3. Upload Application
```bash
# Create application directory
sudo mkdir -p /var/www/organization-financial
sudo chown $USER:$USER /var/www/organization-financial

# Upload files (using scp, git, or FTP)
# Example with git:
cd /var/www/organization-financial
git clone your-repository-url .

# Or use SCP from local machine:
# scp -r organization-financial/ user@server:/var/www/
```

##### 4. Configure Application
```bash
cd /var/www/organization-financial

# Install dependencies
npm install --production

# Create .env file
nano .env
```

**.env for Production:**
```env
# Database
DB_HOST=localhost
DB_USER=orgfin
DB_PASSWORD=your-strong-password
DB_NAME=organization_financial

# Session
SESSION_SECRET=generate-random-secret-here-use-openssl
SESSION_MAX_AGE=86400000

# Server
PORT=3001
NODE_ENV=production
```

**Generate strong session secret:**
```bash
openssl rand -base64 32
```

##### 5. Build Assets
```bash
# Build Tailwind CSS
npm run build:css

# Create uploads directory
mkdir -p public/uploads
chmod 755 public/uploads
```

##### 6. Setup PM2
```bash
# Start application with PM2
pm2 start bin/www --name organization-financial

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Follow the command it outputs

# View logs
pm2 logs organization-financial

# Monitor
pm2 monit
```

##### 7. Configure Nginx

**Create Nginx config:**
```bash
sudo nano /etc/nginx/sites-available/organization-financial
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location /stylesheets/ {
        alias /var/www/organization-financial/public/stylesheets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /uploads/ {
        alias /var/www/organization-financial/public/uploads/;
        expires 1y;
        add_header Cache-Control "public";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Max upload size
    client_max_body_size 10M;
}
```

**Enable site:**
```bash
sudo ln -s /etc/nginx/sites-available/organization-financial /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

##### 8. Setup SSL (Let's Encrypt)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal is setup automatically
# Test renewal:
sudo certbot renew --dry-run
```

##### 9. Setup Firewall
```bash
# Allow SSH, HTTP, HTTPS
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

##### 10. Monitoring & Logs
```bash
# View application logs
pm2 logs organization-financial

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# View system resources
pm2 monit
```

---

### Option 2: Heroku Deployment

#### Prerequisites
- Heroku account
- Heroku CLI installed
- Git repository

#### Steps

##### 1. Prepare Application
```bash
# Add Procfile
echo "web: node bin/www" > Procfile

# Ensure package.json has start script
# (Already configured)
```

##### 2. Setup Database
```bash
# Add JawsDB MySQL addon
heroku addons:create jawsdb:kitefin

# Get database credentials
heroku config:get JAWSDB_URL
```

##### 3. Configure Environment
```bash
# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set SESSION_SECRET=$(openssl rand -base64 32)

# Database config will be from JAWSDB_URL
# Modify config/db.js to parse JAWSDB_URL if present
```

##### 4. Deploy
```bash
# Initialize git (if not already)
git init
git add .
git commit -m "Initial commit"

# Create Heroku app
heroku create your-app-name

# Deploy
git push heroku main

# Run database migration
heroku run bash
mysql -h <host> -u <user> -p <database> < sql/organization_financial.sql
```

---

### Option 3: Docker Deployment

#### Dockerfile
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --production

COPY . .

RUN npm run build:css

EXPOSE 3001

CMD ["node", "bin/www"]
```

#### docker-compose.yml
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - DB_HOST=db
      - DB_USER=orgfin
      - DB_PASSWORD=strongpassword
      - DB_NAME=organization_financial
      - SESSION_SECRET=your-secret-key
    depends_on:
      - db
    volumes:
      - ./public/uploads:/app/public/uploads

  db:
    image: mysql:8
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=organization_financial
      - MYSQL_USER=orgfin
      - MYSQL_PASSWORD=strongpassword
    volumes:
      - mysql-data:/var/lib/mysql
      - ./sql:/docker-entrypoint-initdb.d

volumes:
  mysql-data:
```

#### Deploy with Docker
```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## Post-Deployment Checklist

### Security
- [ ] Change all default passwords
- [ ] Generate strong SESSION_SECRET
- [ ] Setup firewall rules
- [ ] Enable SSL/HTTPS
- [ ] Configure CORS if needed
- [ ] Setup rate limiting
- [ ] Regular security updates

### Monitoring
- [ ] Setup application monitoring (PM2, New Relic, etc.)
- [ ] Setup error tracking (Sentry)
- [ ] Setup uptime monitoring (UptimeRobot)
- [ ] Configure log rotation
- [ ] Setup alerts

### Backup
- [ ] Daily database backup
- [ ] Backup uploaded files
- [ ] Test restore procedures
- [ ] Offsite backup storage

### Performance
- [ ] Enable Nginx caching
- [ ] Optimize images
- [ ] Enable compression
- [ ] CDN for static assets (optional)
- [ ] Database query optimization

### Maintenance
- [ ] Document deployment process
- [ ] Create update procedure
- [ ] Schedule regular backups
- [ ] Plan for scaling
- [ ] Monitor disk space

---

## Database Backup Script

**backup.sh:**
```bash
#!/bin/bash

# Configuration
DB_USER="orgfin"
DB_PASS="your-password"
DB_NAME="organization_financial"
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/orgfin_$DATE.sql.gz

# Backup uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz /var/www/organization-financial/public/uploads/

# Delete backups older than 30 days
find $BACKUP_DIR -type f -mtime +30 -delete

echo "Backup completed: $DATE"
```

**Setup cron:**
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1
```

---

## Update Procedure

```bash
# 1. Backup current version
pm2 stop organization-financial
cd /var/www/organization-financial
tar -czf ../backup_$(date +%Y%m%d).tar.gz .

# 2. Pull updates
git pull origin main

# 3. Install dependencies
npm install --production

# 4. Run migrations (if any)
# mysql -u orgfin -p organization_financial < sql/migration.sql

# 5. Rebuild assets
npm run build:css

# 6. Restart application
pm2 restart organization-financial

# 7. Check logs
pm2 logs organization-financial --lines 50
```

---

## Troubleshooting

### Application won't start
```bash
# Check logs
pm2 logs organization-financial

# Check Node.js version
node --version  # Should be 16+

# Check dependencies
npm install

# Check database connection
mysql -u orgfin -p organization_financial
```

### Database connection error
```bash
# Check MySQL running
sudo systemctl status mysql

# Check credentials in .env
cat .env

# Test connection
mysql -u orgfin -p -h localhost organization_financial
```

### Nginx 502 Bad Gateway
```bash
# Check app is running
pm2 status

# Check port is correct
netstat -tlnp | grep 3001

# Check Nginx config
sudo nginx -t

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log
```

### File upload not working
```bash
# Check directory permissions
ls -la public/uploads/
chmod 755 public/uploads/

# Check Nginx client_max_body_size
# Should be at least 10M in nginx config
```

---

## Scaling Considerations

### Horizontal Scaling
- Use load balancer (Nginx, HAProxy)
- Shared session store (Redis)
- Shared file storage (NFS, S3)
- Database replication

### Vertical Scaling
- Increase server resources
- Optimize database queries
- Enable caching
- Use CDN

---

## Support & Resources

- **Application Logs**: `pm2 logs organization-financial`
- **Database**: Check `/var/log/mysql/error.log`
- **Nginx**: Check `/var/log/nginx/error.log`
- **System**: Check `journalctl -xe`

---

**Deployment completed successfully! 🚀**
