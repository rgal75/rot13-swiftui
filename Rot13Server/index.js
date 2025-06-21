const express = require("express");
const rot13 = require("./rot13");
const app = express();

// Middleware to parse JSON bodies
app.use(express.json());

// Helper function to create a delay
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// POST endpoint for Rot13 transformation
app.post("/rot13/transform", async (req, res) => {
    try {
        const { text } = req.body;

        if (!text || typeof text !== "string") {
            return res.status(400).json({
                error: "Invalid input. Please provide a text string.",
            });
        }

        // Add 2 second delay
        await delay(2000);

        const transformed = rot13(text);
        res.json({ transformed });
    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get port from command line arguments or use default
const args = process.argv.slice(2);
const portArgIndex = args.indexOf("--port");
const customPort = portArgIndex !== -1 ? args[portArgIndex + 1] : null;
const PORT = customPort ? parseInt(customPort) : 3000;

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
