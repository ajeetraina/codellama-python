# codellama-python
This is a PoC about integrating docker + codellama + python in order to apply code review in the pre-commit git hook

# How it works
- First you should serve `ollama` using docker `docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama` .
- Clone this project and move inside it.
- Create the following file `.git/hooks/pre-commit`
```
  #!/bin/sh

# Find all modified Python files
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')

if [ -z "$FILES" ]; then
  echo "No Python files to check."
  exit 0
fi

# Clean the review.md file before starting
> review.md

# Review each modified Python file
for FILE in $FILES; do
  content=$(cat "$FILE")
  prompt="\n Review this code, provide suggestions for improvement, coding best practices, improve readability, and maintainability. Remove any code smells and anti-patterns. Provide code examples for your suggestion. Respond in markdown format. If the file does not have any code or does not need any changes, say 'No changes needed'."
  
  # get model review suggestions
  suggestions=$(docker exec ollama ollama run codellama "Code: $content $prompt")
  
  # Añadir el prefijo del nombre del archivo y las sugerencias al archivo review.md
  echo "## Review for $FILE" >> review.md
  echo "" >> review.md
  echo "$suggestions" >> review.md
  echo "" >> review.md
  echo "---" >> review.md
  echo "" >> review.md
done

echo "All Python files were applied the code review."
exit 0
```

The provided shell script code in the .git/hooks/pre-commit file automates the code review process by finding all modified Python files, cleaning the review.md file, and iterating through each file to generate suggestions using the Ollama model. The suggestions are then appended to the review.md file, providing developers with immediate feedback on their code changes.



- Add or modify the python files.
- Apply a commit message and wait for the review. I could take some minutes, the final result is a review.md with all suggestions from codellama.

## How can I customize the prompts provided to the CodeLLama model for generating suggestions?

To customize the prompts provided to the CodeLLama model for generating suggestions, you can modify the prompt variable within the shell script.




## Running with Docker

For the Docker container that runs the Flask server, the `requirements.txt` file should include the Flask library and any other dependencies your application needs. Given the context of the example, you would minimally need Flask and possibly the `requests` and `flask-cors` libraries if you're making HTTP requests or handling cross-origin resource sharing.

Here's a basic example of what your `requirements.txt` might look like:

```txt
Flask
requests
flask-cors
```

This assumes that your Flask server is using the `requests` library to make HTTP requests and `flask-cors` to handle any CORS issues. If there are additional libraries your application requires, make sure to list them here.

### Sample `requirements.txt`:

```txt
Flask
requests
flask-cors
```

### Full Docker Setup

For completeness, here is the entire setup:

#### Dockerfile

```Dockerfile
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
```

#### docker-compose.yml

```yaml


services:
  codellama:
    image: ollama/ollama
    volumes:
      - ollama:/root/.ollama
    ports:
      - "11434:11434"

  flask-server:
    build: .
    volumes:
      - .:/app
    ports:
      - "11435:11434"
    depends_on:
      - codellama

volumes:
  ollama:
```

#### .git/hooks/pre-commit

Make sure the pre-commit hook script is updated to use the correct port for the Flask server.

```sh
#!/bin/sh

# Find all modified Python files
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')

if [ -z "$FILES" ]; then
  echo "No Python files to check."
  exit 0
fi

# Clean the review.md file before starting
> review.md

# Review each modified Python file
for FILE in $FILES; do
  content=$(cat "$FILE")
  prompt="\n Review this code, provide suggestions for improvement, coding best practices, improve readability, and maintainability. Remove any code smells and anti-patterns. Provide code examples for your suggestion. Respond in markdown format. If the file does not have any code or does not need any changes, say 'No changes needed'."

  # Send request to the running Docker container and get suggestions
  response=$(curl -s -X POST http://localhost:11435/review -d "$content")
  
  # Extract suggestions from JSON response
  suggestions=$(echo $response | jq -r '.suggestions')

  # Add the file name prefix and suggestions to the review.md file
  echo "## Review for $FILE" >> review.md
  echo "" >> review.md
  echo "$suggestions" >> review.md
  echo "" >> review.md
  echo "---" >> review.md
  echo "" >> review.md
done

echo "All Python files were applied the code review."
exit 0
```

### Steps to Run

1. **Build the Docker containers:**

    ```sh
    docker compose build
    ```

2. **Run the Docker containers:**

    ```sh
    docker compose up
    ```

3. **Modify your Python files and commit the changes to trigger the pre-commit hook.**

    ```sh
    git add .
    git commit -m "Test code review in pre-commit hook"
    ```
