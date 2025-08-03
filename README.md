# YouTube Video Downloader

A modern, responsive Flask web application that allows users to download YouTube videos in high quality. Built with a clean, user-friendly interface and robust error handling.

## Features

- 🎥 **High Quality Downloads**: Downloads videos in the best available quality using yt-dlp
- 🎨 **Modern UI**: Clean, responsive design with gradient backgrounds and smooth animations
- 📊 **Real-time Progress**: Live progress tracking with percentage and status updates
- 🛡️ **Error Handling**: Comprehensive error messages and input validation
- 📱 **Mobile Friendly**: Responsive design that works perfectly on all devices
- 🔒 **Secure**: Temporary file handling with automatic cleanup
- ⚡ **Fast**: Optimized for performance with background processing

## Screenshots

The application features a beautiful gradient interface with:
- Clean input field for YouTube URLs
- Animated download button with loading states
- Real-time progress bar with percentage display
- Success/error message handling
- Feature showcase section

## Quick Start

### Local Development

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd youtube-downloader
   ```

2. **Set up virtual environment**:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**:
   ```bash
   python src/main.py
   ```

5. **Open your browser** and navigate to `http://localhost:8000`

### Production Deployment

For production deployment on your own domain, see the comprehensive [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) which covers:

- VPS/Dedicated server deployment
- Shared hosting deployment
- Cloud platform deployment (Heroku, DigitalOcean)
- Domain configuration
- SSL certificate setup
- Security considerations
- Monitoring and maintenance

## Project Structure

```
youtube-downloader/
├── src/
│   ├── routes/
│   │   └── download.py          # Download API endpoints
│   ├── static/
│   │   └── index.html          # Frontend interface
│   └── main.py                 # Flask application entry point
├── venv/                       # Virtual environment
├── requirements.txt            # Python dependencies
├── gunicorn.conf.py           # Production server configuration
├── wsgi.py                    # WSGI entry point
├── DEPLOYMENT_GUIDE.md        # Comprehensive deployment guide
└── README.md                  # This file
```

## API Endpoints

The application provides the following REST API endpoints:

- `POST /api/download` - Start a video download
- `GET /api/status/<download_id>` - Check download progress
- `GET /api/file/<download_id>` - Download the completed file
- `DELETE /api/cleanup/<download_id>` - Clean up download files

## Technology Stack

- **Backend**: Flask (Python web framework)
- **Download Engine**: yt-dlp (YouTube video downloader)
- **Frontend**: Vanilla HTML/CSS/JavaScript
- **Production Server**: Gunicorn
- **Web Server**: Nginx (recommended)
- **Database**: None (stateless design)

## Requirements

- Python 3.8 or higher
- Internet connection for downloading videos
- Sufficient disk space for temporary video files

## Configuration

### Environment Variables

The application supports the following environment variables:

- `PORT`: Server port (default: 8000)
- `DEBUG`: Enable debug mode (default: False in production)
- `SECRET_KEY`: Flask secret key for sessions

### Production Settings

For production deployment, the application automatically:
- Disables debug mode
- Uses secure session handling
- Implements proper error handling
- Configures logging

## Security Features

- Input validation for YouTube URLs
- Temporary file cleanup
- Rate limiting ready (see deployment guide)
- CORS protection
- Secure file handling

## Browser Support

The application supports all modern browsers:
- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+
- Mobile browsers (iOS Safari, Chrome Mobile)

## Legal Considerations

**Important**: This application is for educational and personal use only. Users are responsible for:

- Ensuring they have the right to download content
- Complying with YouTube's Terms of Service
- Respecting copyright laws in their jurisdiction
- Using the application responsibly

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For deployment help, see the [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

For technical issues:
1. Check the application logs
2. Verify your Python and dependency versions
3. Ensure yt-dlp is up to date: `pip install --upgrade yt-dlp`

## Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - The powerful YouTube downloader library
- [Flask](https://flask.palletsprojects.com/) - The lightweight Python web framework
- Modern CSS techniques for the beautiful gradient interface

---

**Disclaimer**: This tool is for personal use only. Please respect copyright laws and YouTube's Terms of Service.

