#!/bin/bash
# User data script to setup Node.js API server

# Update system
yum update -y

# Install Node.js
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install git
yum install -y git

# Create app directory
mkdir -p /home/ec2-user/api
cd /home/ec2-user/api

# Create package.json
cat > package.json << 'EOF'
{
  "name": "boostup-api",
  "version": "1.0.0",
  "description": "Backend API for BoostUp infrastructure demo",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.5",
    "cors": "^2.8.5"
  }
}
EOF

# Create server.js
cat > server.js << 'EOFJS'
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database configuration
const dbConfig = {
  host: '${db_endpoint}'.split(':')[0],
  user: '${db_username}',
  password: '${db_password}',
  database: '${db_name}'
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

// Initialize database
async function initDatabase() {
  try {
    const connection = await pool.getConnection();
    
    // Create messages table
    await connection.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        text VARCHAR(500) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    connection.release();
    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Database initialization error:', error);
  }
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'API server is running' });
});

// Get all messages
app.get('/api/messages', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM messages ORDER BY created_at DESC LIMIT 10');
    res.json({ success: true, messages: rows });
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Add a new message
app.post('/api/messages', async (req, res) => {
  try {
    const { text } = req.body;
    
    if (!text || text.trim() === '') {
      return res.status(400).json({ success: false, error: 'Message text is required' });
    }

    const [result] = await pool.query('INSERT INTO messages (text) VALUES (?)', [text]);
    
    res.json({ 
      success: true, 
      message: 'Message saved successfully',
      id: result.insertId 
    });
  } catch (error) {
    console.error('Error saving message:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Test database connection
app.get('/api/test-connection', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    await connection.query('SELECT 1');
    connection.release();
    
    res.json({ 
      success: true, 
      message: 'Successfully connected to RDS MySQL database',
      database: '${db_name}',
      host: '${db_endpoint}'.split(':')[0]
    });
  } catch (error) {
    console.error('Database connection error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Start server
app.listen(PORT, async () => {
  console.log(`API server running on port $${PORT}`);
  await initDatabase();
});
EOFJS

# Install dependencies
npm install

# Create systemd service
cat > /etc/systemd/system/boostup-api.service << 'EOFSVC'
[Unit]
Description=BoostUp API Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/api
ExecStart=/usr/bin/node server.js
Restart=on-failure
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOFSVC

# Set permissions
chown -R ec2-user:ec2-user /home/ec2-user/api

# Enable and start service
systemctl daemon-reload
systemctl enable boostup-api
systemctl start boostup-api

# Log completion
echo "API server setup completed at $(date)" >> /var/log/user-data.log
