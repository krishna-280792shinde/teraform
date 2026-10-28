
from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "message": "Flask backend is running successfully!"
    })


@app.route("/submit", methods=["POST"])
def submit_form():
    data = request.get_json(silent=True) or {}

    name = str(data.get("name", "")).strip()
    email = str(data.get("email", "")).strip()
    course = str(data.get("course", "")).strip()

    if not name or not email or not course:
        return jsonify({
            "success": False,
            "message": "Name, email, and course are required."
        }), 400

    return jsonify({
        "success": True,
        "message": "Student information submitted successfully!",
        "student": {
            "name": name,
            "email": email,
            "course": course
        }
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
