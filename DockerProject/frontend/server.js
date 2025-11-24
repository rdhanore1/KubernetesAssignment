const express = require('express');
const path = require('path');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Proxy endpoint: the browser posts to this server, and the server forwards to Flask backend.
app.post('/api/submit', async (req, res) => {
try {
// Build target URL. In docker-compose the backend service is named "backend" and listens on 5000.
const backendUrl = process.env.BACKEND_URL || 'http://backend:5000/submit';

// Forward data as JSON
const response = await axios.post(backendUrl, req.body, {
headers: { 'Content-Type': 'application/json' }
});

// Forward backend response back to browser
res.status(response.status).json(response.data);
} catch (err) {
console.error('Error forwarding to backend:', err.message);
if (err.response) {
res.status(err.response.status).json(err.response.data);
} else {
res.status(500).json({ error: 'Failed to contact backend', details: err.message });
}
}
});

app.listen(PORT, () => {
console.log(`Frontend server running on port ${PORT}`);
});