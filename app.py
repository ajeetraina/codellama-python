from flask import Flask, request, jsonify
import re

app = Flask(__name__)

@app.route('/review', methods=['POST'])
def review():
    data = request.get_data(as_text=True)
    
    # Add your code review logic here
    suggestions = review_code(data)
    
    return jsonify(suggestions=suggestions)

def review_code(code):
    # This is a placeholder for actual code review logic
    # Replace this with integration to CodeLlama or your preferred tool
    suggestions = []
    if "print" in code:
        suggestions.append("Use logging instead of print statements.")
    
    # Example of checking for function definition issues
    if re.search(r'def \w+\(.*,\s*\w+$', code):
        suggestions.append("Check function definition: possible syntax error.")
    
    # Example of detecting unfinished return statements
    if re.search(r'return \w+\s*\w+$', code):
        suggestions.append("Check return statement: possible syntax error.")
    
    # Format suggestions as a markdown string
    return '\n'.join(suggestions) if suggestions else "No changes needed"

if __name__ == '__main__':
    app.run(port=11434)
