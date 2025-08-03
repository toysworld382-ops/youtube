#!/bin/bash

# YouTube Downloader Setup Script
# This script helps set up the application for production deployment

set -e  # Exit on any error

echo "🎥 YouTube Downloader Setup Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons"
   exit 1
fi

# Check Python version
print_status "Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
REQUIRED_VERSION="3.8"

if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)"; then
    print_error "Python 3.8 or higher is required. Found: Python $PYTHON_VERSION"
    exit 1
fi

print_success "Python version check passed: Python $PYTHON_VERSION"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    print_status "Creating virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
else
    print_warning "Virtual environment already exists"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Install requirements
print_status "Installing Python packages..."
pip install -r requirements.txt

print_success "All dependencies installed successfully"

# Test the application
print_status "Testing application startup..."
timeout 10s python src/main.py > /dev/null 2>&1 &
TEST_PID=$!
sleep 3

if kill -0 $TEST_PID 2>/dev/null; then
    print_success "Application starts successfully"
    kill $TEST_PID 2>/dev/null || true
else
    print_error "Application failed to start"
    exit 1
fi

# Create log directory
print_status "Creating log directory..."
sudo mkdir -p /var/log/youtube-downloader
sudo chown $USER:$USER /var/log/youtube-downloader
print_success "Log directory created"

# Set permissions
print_status "Setting file permissions..."
chmod +x setup.sh
chmod 644 requirements.txt
chmod 644 gunicorn.conf.py
chmod 644 wsgi.py
print_success "File permissions set"

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review the DEPLOYMENT_GUIDE.md for detailed deployment instructions"
echo "2. Configure your web server (Nginx/Apache)"
echo "3. Set up your domain DNS records"
echo "4. Configure SSL certificate"
echo ""
echo "To start the application in development mode:"
echo "  source venv/bin/activate"
echo "  python src/main.py"
echo ""
echo "To start the application in production mode:"
echo "  source venv/bin/activate"
echo "  gunicorn --config gunicorn.conf.py wsgi:app"
echo ""
echo "For detailed deployment instructions, see DEPLOYMENT_GUIDE.md"

