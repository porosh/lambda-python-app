#!/bin/bash

# Exit immediately if any command fails
set -e

# Constants
ZIP_FILE="lambda_function.zip"
VENV_DIR="src/.venv"
PACKAGE_DIR="package"
PYTHON_VERSION="3.11"

# Function: Delete a file if it exists
delete_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo "File $file exists. Deleting..."
        rm "$file"
        echo "File $file deleted successfully."
    else
        echo "File $file does not exist. Nothing to delete."
    fi
}

# Function: Check if a command exists
check_command() {
    local cmd=$1
    local install_instructions=$2
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it before running this script."
        echo "$install_instructions"
        exit 1
    fi
}

# Step 1: Delete old ZIP file
delete_file "$ZIP_FILE"

# Step 2: Create or activate the virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found. Creating a new one..."
    python"$PYTHON_VERSION" -m venv "$VENV_DIR"
fi
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Step 3: Install dependencies
if [ -f "src/requirements.txt" ]; then
    echo "Installing dependencies..."
    pip install -r src/requirements.txt
else
    echo "No requirements.txt found. Skipping dependency installation."
fi
echo "Virtual environment setup complete."

# Step 4: Check for required tools
check_command "sam" "Install AWS SAM CLI: https://github.com/aws/aws-sam-cli/releases/latest"
check_command "aws" "Install AWS CLI: https://aws.amazon.com/cli/"

# Step 5: Build the Lambda function using AWS SAM
echo "Building the Lambda function..."
rm -rf .aws-sam
sam build --region us-east-1
sam validate --region us-east-1

# Step 6: Invoke the Lambda function locally for testing
echo "Invoking the Lambda function locally..."
if [ -f "event.json" ]; then
    sam local invoke "MyLambdaFunction" -e event.json
else
    echo "No event.json found. Skipping local invocation."
fi

# Step 7: Prepare deployment package
echo "Preparing deployment package..."
if [ -d "$PACKAGE_DIR" ]; then
    rm -rf "$PACKAGE_DIR"
fi
mkdir -p "$PACKAGE_DIR"

# Copy source files, excluding .venv and requirements.txt
echo "Copying source files to the package directory..."
rsync -av --exclude='.venv' --exclude='requirements.txt' src/ "$PACKAGE_DIR/"

# Copy installed dependencies from .venv to the package directory
echo "Copying dependencies to the package directory..."
cp -r "$VENV_DIR/lib/python$PYTHON_VERSION/site-packages/." "$PACKAGE_DIR/"

# Create the deployment ZIP file
echo "Creating deployment ZIP file..."
cd "$PACKAGE_DIR"
zip -r "../$ZIP_FILE" .
cd ..
echo "Deployment package created: $ZIP_FILE"

# Step 8: Cleanup
if [ -d "$PACKAGE_DIR" ]; then
    rm -rf "$PACKAGE_DIR"
fi
deactivate
echo "Cleanup complete."