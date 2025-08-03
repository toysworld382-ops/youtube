# YouTube Downloader - Deployment Guide

## Overview

This guide provides comprehensive instructions for deploying the YouTube Downloader Flask application to your own hosting environment and domain. The application allows users to download YouTube videos in high quality using a modern, responsive web interface.

## Application Features

- **Modern UI**: Clean, responsive design with gradient backgrounds and smooth animations
- **Real-time Progress**: Live progress tracking with percentage and status updates
- **Error Handling**: Comprehensive error messages and validation
- **High Quality Downloads**: Uses yt-dlp for best available video quality
- **Mobile Friendly**: Responsive design works on all devices
- **Secure**: Temporary file handling with automatic cleanup

## Prerequisites

Before deploying, ensure your hosting environment has:

- Python 3.8 or higher
- pip package manager
- Sufficient disk space for temporary video files
- Internet connectivity for downloading videos
- Web server capability (Apache, Nginx, or similar)

## Deployment Options

### Option 1: VPS/Dedicated Server Deployment

This is the recommended approach for full control and performance.

#### Step 1: Server Setup

1. **Connect to your server** via SSH:
   ```bash
   ssh username@your-server-ip
   ```

2. **Update system packages**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **Install required system packages**:
   ```bash
   sudo apt install python3 python3-pip python3-venv nginx supervisor git -y
   ```

#### Step 2: Application Deployment

1. **Create application directory**:
   ```bash
   sudo mkdir -p /var/www/youtube-downloader
   sudo chown $USER:$USER /var/www/youtube-downloader
   cd /var/www/youtube-downloader
   ```

2. **Upload application files** (choose one method):
   
   **Method A: Direct upload**
   - Upload the entire `youtube-downloader` folder to `/var/www/youtube-downloader/`
   
   **Method B: Git repository**
   ```bash
   git clone <your-repository-url> .
   ```

3. **Set up Python environment**:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

4. **Test the application**:
   ```bash
   python src/main.py
   ```
   Visit `http://your-server-ip:8000` to verify it works.

#### Step 3: Production Configuration

1. **Create Gunicorn configuration** (`/var/www/youtube-downloader/gunicorn.conf.py`):
   ```python
   bind = "127.0.0.1:8000"
   workers = 4
   worker_class = "sync"
   worker_connections = 1000
   timeout = 300
   keepalive = 2
   max_requests = 1000
   max_requests_jitter = 100
   preload_app = True
   ```

2. **Create systemd service** (`/etc/systemd/system/youtube-downloader.service`):
   ```ini
   [Unit]
   Description=YouTube Downloader Flask App
   After=network.target

   [Service]
   User=www-data
   Group=www-data
   WorkingDirectory=/var/www/youtube-downloader
   Environment=PATH=/var/www/youtube-downloader/venv/bin
   ExecStart=/var/www/youtube-downloader/venv/bin/gunicorn --config gunicorn.conf.py src.main:app
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

3. **Configure Nginx** (`/etc/nginx/sites-available/youtube-downloader`):
   ```nginx
   server {
       listen 80;
       server_name your-domain.com www.your-domain.com;
       
       client_max_body_size 100M;
       
       location / {
           proxy_pass http://127.0.0.1:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
           proxy_read_timeout 300s;
           proxy_connect_timeout 75s;
       }
   }
   ```

4. **Enable and start services**:
   ```bash
   sudo systemctl enable youtube-downloader
   sudo systemctl start youtube-downloader
   sudo ln -s /etc/nginx/sites-available/youtube-downloader /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

#### Step 4: SSL Certificate (Recommended)

1. **Install Certbot**:
   ```bash
   sudo apt install certbot python3-certbot-nginx -y
   ```

2. **Obtain SSL certificate**:
   ```bash
   sudo certbot --nginx -d your-domain.com -d www.your-domain.com
   ```

### Option 2: Shared Hosting Deployment

For shared hosting providers that support Python applications:

#### Step 1: Check Hosting Requirements

Ensure your hosting provider supports:
- Python 3.8+
- Flask applications
- Custom Python packages
- Long-running processes (for video downloads)

#### Step 2: Upload Files

1. Upload all application files to your hosting directory
2. Install dependencies (if supported):
   ```bash
   pip install --user -r requirements.txt
   ```

#### Step 3: Configuration

1. **Modify main.py** for shared hosting:
   ```python
   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8000)), debug=False)
   ```

2. **Create .htaccess** (for Apache):
   ```apache
   RewriteEngine On
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteRule ^(.*)$ main.py/$1 [QSA,L]
   ```

### Option 3: Cloud Platform Deployment

#### Heroku Deployment

1. **Create Procfile**:
   ```
   web: gunicorn src.main:app
   ```

2. **Create runtime.txt**:
   ```
   python-3.11.0
   ```

3. **Deploy to Heroku**:
   ```bash
   heroku create your-app-name
   git add .
   git commit -m "Initial deployment"
   git push heroku main
   ```

#### DigitalOcean App Platform

1. **Create app.yaml**:
   ```yaml
   name: youtube-downloader
   services:
   - name: web
     source_dir: /
     github:
       repo: your-username/youtube-downloader
       branch: main
     run_command: gunicorn --worker-tmp-dir /dev/shm src.main:app
     environment_slug: python
     instance_count: 1
     instance_size_slug: basic-xxs
     http_port: 8080
   ```

## Domain Configuration

### DNS Setup

1. **Point your domain to your server**:
   - A Record: `your-domain.com` → `your-server-ip`
   - CNAME Record: `www.your-domain.com` → `your-domain.com`

2. **Wait for DNS propagation** (up to 48 hours)

3. **Verify DNS resolution**:
   ```bash
   nslookup your-domain.com
   ```

### Subdomain Setup

If using a subdomain (e.g., `downloader.your-domain.com`):

1. **Create subdomain DNS record**:
   - A Record: `downloader.your-domain.com` → `your-server-ip`

2. **Update Nginx configuration**:
   ```nginx
   server_name downloader.your-domain.com;
   ```

## Security Considerations

### Rate Limiting

Implement rate limiting to prevent abuse:

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/api/download', methods=['POST'])
@limiter.limit("5 per minute")
def start_download():
    # existing code
```

### File Size Limits

Configure maximum file sizes in your web server:

**Nginx:**
```nginx
client_max_body_size 500M;
```

**Apache:**
```apache
LimitRequestBody 524288000
```

### Firewall Configuration

```bash
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```

## Monitoring and Maintenance

### Log Monitoring

1. **Application logs**:
   ```bash
   sudo journalctl -u youtube-downloader -f
   ```

2. **Nginx logs**:
   ```bash
   sudo tail -f /var/log/nginx/access.log
   sudo tail -f /var/log/nginx/error.log
   ```

### Automatic Updates

Create update script (`/var/www/youtube-downloader/update.sh`):

```bash
#!/bin/bash
cd /var/www/youtube-downloader
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart youtube-downloader
```

### Backup Strategy

1. **Database backup** (if using database):
   ```bash
   sqlite3 src/database/app.db .dump > backup.sql
   ```

2. **Application backup**:
   ```bash
   tar -czf youtube-downloader-backup-$(date +%Y%m%d).tar.gz /var/www/youtube-downloader
   ```

## Troubleshooting

### Common Issues

1. **Port already in use**:
   ```bash
   sudo lsof -i :8000
   sudo kill -9 <PID>
   ```

2. **Permission errors**:
   ```bash
   sudo chown -R www-data:www-data /var/www/youtube-downloader
   sudo chmod -R 755 /var/www/youtube-downloader
   ```

3. **yt-dlp errors**:
   ```bash
   pip install --upgrade yt-dlp
   ```

4. **Memory issues**:
   - Increase server RAM
   - Configure swap space
   - Limit concurrent downloads

### Performance Optimization

1. **Enable Gzip compression** (Nginx):
   ```nginx
   gzip on;
   gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
   ```

2. **Configure caching**:
   ```nginx
   location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   ```

3. **Optimize Python**:
   ```python
   # Add to main.py
   app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 31536000
   ```

## Legal Considerations

### Terms of Service

Implement clear terms of service covering:
- Acceptable use policy
- Copyright compliance
- User responsibilities
- Service limitations

### Content Policy

- Only allow downloads of content that users have rights to download
- Implement content filtering if required
- Consider geographic restrictions
- Monitor for abuse

### DMCA Compliance

If hosting in the US, implement DMCA takedown procedures:
- Designated agent registration
- Takedown request handling
- Counter-notification process

## Support and Maintenance

### Regular Maintenance Tasks

1. **Weekly**:
   - Check disk space
   - Review error logs
   - Update yt-dlp: `pip install --upgrade yt-dlp`

2. **Monthly**:
   - Update system packages
   - Review security logs
   - Backup application data

3. **Quarterly**:
   - Update Python dependencies
   - Review and update security configurations
   - Performance optimization review

### Getting Help

For technical support:
1. Check application logs first
2. Review this deployment guide
3. Search for similar issues online
4. Contact your hosting provider for server-specific issues

## Conclusion

This deployment guide provides comprehensive instructions for hosting your YouTube Downloader application on your own domain. Choose the deployment method that best fits your technical expertise and hosting requirements. Remember to regularly maintain and monitor your application for optimal performance and security.

For any questions or issues not covered in this guide, refer to the official documentation of your hosting platform or web server software.

