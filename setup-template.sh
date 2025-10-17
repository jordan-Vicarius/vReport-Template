#!/bin/bash

# Evidence Project Template Setup Script
# This script helps users initialize their Evidence project from the template

set -e

echo "🚀 Setting up Evidence Project Template..."

# Check if .env already exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists. Backing up to .env.backup"
    cp .env .env.backup
fi

# Copy template environment file
if [ ! -f ".env" ]; then
    echo "📋 Creating .env file from template..."
    cp .env.template .env
    echo "✅ Created .env file. Please edit it with your project configuration."
else
    echo "📋 .env file already exists, skipping creation."
fi

# Prompt for project name
read -p "Enter your project name (default: my-evidence-project): " project_name
project_name=${project_name:-my-evidence-project}

# Prompt for project version
read -p "Enter your project version (default: 0.0.1): " project_version
project_version=${project_version:-0.0.1}

# Prompt for container name
read -p "Enter your container name (default: evidence-dashboard): " container_name
container_name=${container_name:-evidence-dashboard}

# Prompt for port
read -p "Enter the port for Evidence (default: 8080): " evidence_port
evidence_port=${evidence_port:-8080}

# Update .env file with user inputs
echo "🔧 Updating configuration..."
sed -i "s/PROJECT_NAME=.*/PROJECT_NAME=$project_name/" .env
sed -i "s/PROJECT_VERSION=.*/PROJECT_VERSION=$project_version/" .env
sed -i "s/CONTAINER_NAME=.*/CONTAINER_NAME=$container_name/" .env
sed -i "s/EVIDENCE_PORT=.*/EVIDENCE_PORT=$evidence_port/" .env

# Update package.json
echo "📦 Updating package.json..."
sed -i "s/{{PROJECT_NAME}}/$project_name/g" package.json
sed -i "s/{{PROJECT_VERSION}}/$project_version/g" package.json

# Install dependencies
echo "📥 Installing dependencies..."
npm install

# Build the project
echo "🔨 Building Evidence project..."
npm run build

echo "✅ Template setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env file to configure your database connection"
echo "2. Update your data sources in the sources/ directory"
echo "3. Customize your pages in the pages/ directory"
echo "4. Run 'docker-compose up' to start your Evidence dashboard"
echo ""
echo "Your Evidence dashboard will be available at: http://localhost:$evidence_port"
