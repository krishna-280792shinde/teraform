
const express = require("express");

const app = express();
const PORT = process.env.PORT || 3000;

// In Docker Compose, use the backend service name.
// When running locally, Flask is available at localhost:5000.
const BACKEND_URL =
  process.env.BACKEND_URL || "http://127.0.0.1:5000";

app.use(express.urlencoded({ extended: false }));

app.get("/", (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Student Registration</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background: #f2f5f9;
          margin: 0;
          padding: 40px 16px;
        }
        .container {
          max-width: 450px;
          margin: auto;
          padding: 28px;
          background: white;
          border-radius: 12px;
          box-shadow: 0 4px 16px rgba(0,0,0,0.08);
        }
        h1 { color: #244a7c; }
        label {
          display: block;
          margin-top: 16px;
          font-weight: bold;
        }
        input, select, button {
          box-sizing: border-box;
          width: 100%;
          padding: 11px;
          margin-top: 7px;
          border-radius: 6px;
          border: 1px solid #ccd3dd;
        }
        button {
          margin-top: 22px;
          background: #2457a7;
          color: white;
          border: none;
          cursor: pointer;
          font-size: 16px;
        }
        button:hover { background: #183e79; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Student Registration</h1>
        <p>Enter your details below.</p>

        <form action="/submit" method="POST">
          <label for="name">Full Name</label>
          <input id="name" name="name" type="text" required>

          <label for="email">Email Address</label>
          <input id="email" name="email" type="email" required>

          <label for="course">Course</label>
          <select id="course" name="course" required>
            <option value="">Select a course</option>
            <option value="DevOps">DevOps</option>
            <option value="Python">Python</option>
            <option value="Data Science">Data Science</option>
            <option value="Web Development">Web Development</option>
          </select>

          <button type="submit">Submit Details</button>
        </form>
      </div>
    </body>
    </html>
  `);
});

app.post("/submit", async (req, res) => {
  const { name, email, course } = req.body;

  if (
    typeof name !== "string" || !name.trim() ||
    typeof email !== "string" || !email.trim() ||
    typeof course !== "string" || !course.trim()
  ) {
    return res.status(400).send("Please fill in all fields.");
  }

  try {
    const response = await fetch(`${BACKEND_URL}/submit`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: name.trim(),
        email: email.trim(),
        course: course.trim()
      })
    });

    const result = await response.json();

    if (!response.ok) {
      return res.status(response.status).send(`
        <h2>Submission failed</h2>
        <p>${result.message || "Please check your details."}</p>
        <a href="/">Go back</a>
      `);
    }

    return res.send(`
      <h2>${result.message}</h2>
      <p>Name: ${escapeHtml(result.student.name)}</p>
      <p>Email: ${escapeHtml(result.student.email)}</p>
      <p>Course: ${escapeHtml(result.student.course)}</p>
      <a href="/">Register another student</a>
    `);
  } catch (error) {
    console.error("Backend request failed:", error.message);
    return res.status(502).send(`
      <h2>Unable to contact the Flask backend.</h2>
      <p>Please ensure the backend is running.</p>
      <a href="/">Go back</a>
    `);
  }
});

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;"
  })[character]);
}

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Frontend running on port ${PORT}`);
  console.log(`Flask backend URL: ${BACKEND_URL}`);
});
