# # Use an official Python runtime as a parent image
# FROM python:3.9-slim

# # Set the working directory in the container to /app
# WORKDIR /app

# # Copy the current directory contents into the container at /app
# COPY . /app

# # Install any needed packages specified in requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt

# # Make the pre-commit hook executable
# RUN chmod +x .git/hooks/pre-commit

# # Run the pre-commit hook when the container starts
# CMD ["sh", "-c", ".git/hooks/pre-commit"]


# Use the official Python image from the Docker Hub
FROM python:3.11

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 11434 available to the world outside this container
EXPOSE 11434

# Define environment variable
ENV FLASK_APP=app.py

# Run app.py when the container launches
CMD ["flask", "run", "--host=0.0.0.0", "--port=11434"]

