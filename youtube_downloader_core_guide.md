# YouTube Downloader Core File Guide

This document explains the `youtube_downloader_core.py` file, which contains the essential Flask application logic and YouTube video downloading functionality. This single file is designed for easy integration into various Python projects or for quick deployment.

## 1. Introduction to `youtube_downloader_core.py`

The `youtube_downloader_core.py` file encapsulates the core functionalities of the YouTube Downloader application. It includes:

-   **Flask Application Instance**: A basic Flask app setup.
-   **API Endpoints**: Routes for fetching video information (`/api/video-info`), initiating downloads (`/api/download`), checking download status (`/api/status/<download_id>`), and serving downloaded files (`/api/file/<download_id>`).
-   **`yt-dlp` Integration**: Uses `yt-dlp` for robust video downloading, including quality selection and progress tracking.
-   **File Management**: Handles temporary storage and cleanup of downloaded files.

This file is self-contained for its core functionality, making it easy to drop into an existing project or use as a standalone script for testing and development.

## 2. File Structure and Key Components

```python
# --- Flask Application Setup ---
app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "your-secret-key-here")

# Directory to store downloaded videos temporarily
DOWNLOAD_DIR = "downloads"

# Dictionary to store download progress and status
download_status = {}

# --- Helper Functions ---
def sanitize_filename(filename):
    # ... (sanitizes filenames)

def get_video_info(url):
    # ... (fetches video metadata)

class DownloadProgressHook:
    # ... (updates download status)

# --- API Endpoints ---
@app.route("/api/video-info", methods=["POST"])
def video_info():
    # ... (handles video info requests)

@app.route("/api/download", methods=["POST"])
def download_video():
    # ... (initiates video download)

@app.route("/api/status/<download_id>")
def download_status_check(download_id):
    # ... (checks download progress)

@app.route("/api/file/<download_id>")
def serve_downloaded_file(download_id):
    # ... (serves downloaded file and cleans up)

# --- Main Execution ---
if __name__ == "__main__":
    # ... (runs the Flask app)
```

### Key Sections:

-   **Flask Application Setup**: Initializes the Flask app and defines the temporary download directory and a dictionary to track download statuses.
-   **Helper Functions**: Contains utility functions for sanitizing filenames, fetching video metadata using `yt-dlp`, and a custom progress hook for real-time download updates.
-   **API Endpoints**: Defines the Flask routes that handle various requests from the frontend or other services.
-   **Main Execution Block**: The `if __name__ == "__main__":` block allows you to run the Flask application directly for development or testing purposes.

## 3. How to Use `youtube_downloader_core.py`

### 3.1. Prerequisites

Before running this file, ensure you have the following installed:

-   **Python 3.x**: The script is written in Python.
-   **`pip`**: Python package installer.
-   **`yt-dlp`**: The command-line program for downloading videos. It will be installed as a Python package.
-   **`aria2c` (Optional but Recommended)**: A multi-protocol & multi-source download utility. `yt-dlp` can use it for faster, multi-threaded downloads. Install it via your system's package manager (e.g., `sudo apt-get install aria2` on Ubuntu, `brew install aria2` on macOS).

### 3.2. Installation

1.  **Save the file**: Save the provided `youtube_downloader_core.py` file to your desired project directory.

2.  **Install Python dependencies**: Open your terminal or command prompt, navigate to the directory where you saved the file, and install the required Python packages:
    ```bash
    pip install Flask yt-dlp
    ```

### 3.3. Running the Application

To run the Flask application directly for testing or development:

```bash
python youtube_downloader_core.py
```

The application will start on `http://0.0.0.0:5000` by default (or the port specified by the `PORT` environment variable).

### 3.4. Integrating into an Existing Project

You can import the `app` instance from `youtube_downloader_core.py` into a larger Flask application or a WSGI server setup (like Gunicorn).

**Example `wsgi.py` for Gunicorn:**

```python
import sys
import os

# Add the directory containing youtube_downloader_core.py to the Python path
# Adjust this path based on your project structure
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from youtube_downloader_core import app as application

# This is for local development only, Gunicorn will use the 'application' object
if __name__ == "__main__":
    application.run()
```

**Example `gunicorn.conf.py`:**

```python
bind = "0.0.0.0:8001"
workers = 2
worker_class = "sync"
timeout = 120
keepalive = 5
```

### 3.5. Environment Variables

-   `SECRET_KEY`: Set a strong, random secret key for Flask sessions. This is crucial for production environments.
    ```bash
    export SECRET_KEY="your_very_secret_and_random_key_here"
    ```
-   `PORT`: (Optional) Specifies the port on which the Flask application will run. Defaults to `5000`.
    ```bash
    export PORT=8001
    ```

## 4. API Usage

This file exposes the following API endpoints:

### 4.1. Get Video Information

-   **Endpoint**: `/api/video-info`
-   **Method**: `POST`
-   **Request Body (JSON)**:
    ```json
    {
        "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    }
    ```
-   **Response (JSON)**:
    ```json
    {
        "success": true,
        "info": {
            "title": "Rick Astley - Never Gonna Give You Up (Official Music Video)",
            "duration": "00:03:33",
            "uploader": "Rick Astley",
            "view_count": "1,500,000,000",
            "thumbnail": "https://...
        }
    }
    ```
    or
    ```json
    {
        "success": false,
        "error": "Invalid URL or video not found"
    }
    ```

### 4.2. Start Video Download

-   **Endpoint**: `/api/download`
-   **Method**: `POST`
-   **Request Body (JSON)**:
    ```json
    {
        "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "quality": "1080"  // Optional: "auto", "2160", "1080", "720", "480", "audio"
    }
    ```
-   **Response (JSON)**:
    ```json
    {
        "success": true,
        "download_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef"
    }
    ```
    or
    ```json
    {
        "success": false,
        "error": "Download failed to initiate"
    }
    ```

### 4.3. Check Download Status

-   **Endpoint**: `/api/status/<download_id>`
-   **Method**: `GET`
-   **Response (JSON)**:
    ```json
    {
        "status": "downloading",
        "progress": 50.5,
        "speed": "2.50 MiB/s",
        "eta": "10s",
        "status_text": "50.5% of 100.00MiB at 2.50MiB/s ETA 00:00:10",
        "title": "Rick Astley - Never Gonna Give You Up"
    }
    ```
    or (on completion)
    ```json
    {
        "status": "completed",
        "progress": 100,
        "filepath": "downloads/Rick Astley - Never Gonna Give You Up.mp4",
        "title": "Rick Astley - Never Gonna Give You Up"
    }
    ```
    or (on error)
    ```json
    {
        "status": "error",
        "error": "Remote end closed connection without response",
        "title": "Rick Astley - Never Gonna Give You Up"
    }
    ```

### 4.4. Serve Downloaded File

-   **Endpoint**: `/api/file/<download_id>`
-   **Method**: `GET`
-   **Usage**: This endpoint is typically called by the frontend after the download status shows `completed`. It will serve the file as an attachment and then automatically delete it from the server.

## 5. Important Considerations

-   **Temporary Files**: Downloaded videos are stored temporarily in the `downloads/` directory and are deleted after being served to the user. Ensure your hosting environment allows writing to and deleting from this directory.
-   **Scalability**: For high-traffic applications, consider using a message queue (e.g., Celery with Redis/RabbitMQ) to handle download tasks asynchronously, preventing the Flask app from being blocked during long downloads.
-   **Error Handling**: The script includes basic error handling. For production, you might want more robust logging and error reporting.
-   **Security**: Always keep your `SECRET_KEY` confidential. Be mindful of potential abuse if exposing this API publicly without rate limiting or authentication.
-   **`yt-dlp` Updates**: `yt-dlp` is frequently updated. Ensure your environment has the latest version to maintain compatibility with various video platforms.

This `youtube_downloader_core.py` file provides a solid foundation for your YouTube video downloading service, allowing for flexible integration and deployment.


