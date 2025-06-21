# Rot13 JSON Web Service

A simple Node.js web service that performs Rot13 transformation on text.

## Installation

```bash
npm install
```

## Running the Server

```bash
node index.js [--port N]
```

The server will start on port 3000 by default.

## API Usage

### Transform Text

**Endpoint:** `POST /rot13/transform`

**Request Body:**

```json
{
    "text": "<plain text>"
}
```

**Response:**

```json
{
    "transformed": "<rot13 transformed text>"
}
```

## Example using curl

```bash
curl -X POST \
  http://localhost:3000/rot13/transform \
  -H 'Content-Type: application/json' \
  -d '{"text": "Hello, World!"}'
```
