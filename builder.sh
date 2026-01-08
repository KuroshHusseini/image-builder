#!/bin/sh

# Check if correct number of arguments provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <github_repo> <dockerhub_repo>"
    echo "Example: $0 mluukkai/express_app mluukkai/testing"
    exit 1
fi

# Get arguments
GITHUB_REPO="$1"
DOCKERHUB_REPO="$2"

# Extract project name from GitHub repo
PROJECT_NAME="${GITHUB_REPO##*/}"

# Construct GitHub URL
GITHUB_URL="https://github.com/${GITHUB_REPO}.git"

echo "=== Docker Image Builder and Publisher ==="
echo "GitHub Repository: $GITHUB_URL"
echo "Docker Hub Repository: $DOCKERHUB_REPO"
echo "Project Name: $PROJECT_NAME"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker daemon is not running. Please start Docker first."
    exit 1
fi

# Clone the repository
echo "Step 1: Cloning repository..."
if [ -d "$PROJECT_NAME" ]; then
    echo "Directory '$PROJECT_NAME' already exists. Removing it..."
    rm -rf "$PROJECT_NAME"
fi

if git clone "$GITHUB_URL"; then
    echo "Repository cloned successfully."
else
    echo "Failed to clone repository."
    exit 1
fi

# Navigate to project directory
cd "$PROJECT_NAME" || { echo "Failed to enter project directory."; exit 1; }

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo "Error: Dockerfile not found in the root of the repository."
    cd ..
    rm -rf "$PROJECT_NAME"
    exit 1
fi

# Build Docker image
echo ""
echo "Step 2: Building Docker image..."
if docker build -t "$DOCKERHUB_REPO" .; then
    echo "Docker image built successfully."
else
    echo "Failed to build Docker image."
    cd ..
    rm -rf "$PROJECT_NAME"
    exit 1
fi

# Push to Docker Hub
echo ""
echo "Step 3: Pushing image to Docker Hub..."
if docker push "$DOCKERHUB_REPO"; then
    echo "Image pushed successfully to Docker Hub!"
else
    echo "Failed to push image to Docker Hub."
    echo "Make sure you are logged in with: docker login"
    cd ..
    rm -rf "$PROJECT_NAME"
    exit 1
fi

# Clean up
echo ""
echo "Step 4: Cleaning up..."
cd ..
rm -rf "$PROJECT_NAME"
echo "Cleaned up temporary files."

echo ""
echo "=== Build and Publish Complete ==="
echo "Image '$DOCKERHUB_REPO' is now available on Docker Hub!"