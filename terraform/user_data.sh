#!/bin/bash

# Update system packages
apt-get update -y
apt-get install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    mysql-client \
    awscli

# Install Node.js application dependencies
cd /opt || exit
cat > package.json << 'EOF'
{
  "name": "simple-web-app",
  "version": "1.0.0",
  "description": "Simple web application",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mysql": "^2.18.1",
    "aws-sdk": "^2.1431.0"
  }
}
EOF

npm install

# Create the Express application
cat > app.js << 'NODEJS_APP'
const express = require('express');
const mysql = require('mysql');
const AWS = require('aws-sdk');
const os = require('os');

const app = express();
const port = 80;

// AWS Configuration
AWS.config.update({ region: '${aws_region}' });
const s3 = new AWS.S3();

// MySQL Connection Pool
const pool = mysql.createPool({
  connectionLimit: 10,
  host: '${db_host}',
  user: '${db_user}',
  password: '${db_password}',
  database: '${db_name}'
});

// Initialize database
pool.query(`
  CREATE TABLE IF NOT EXISTS visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(255),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    request_path VARCHAR(255)
  )
`, function (error) {
  if (error) console.error('Database initialization error:', error);
  else console.log('Database table verified');
});

// Middleware
app.use(express.static('public'));
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  const hostname = os.hostname();
  
  pool.query('INSERT INTO visitors (hostname, request_path) VALUES (?, ?)', 
    [hostname, '/'], 
    function (error) {
      if (error) console.error('Database insert error:', error);
    }
  );

  pool.query('SELECT COUNT(*) as total FROM visitors', (error, results) => {
    if (error) {
      return res.status(500).send('Database error');
    }
    
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <title>Simple Web Application</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f0f0f0;
          }
          .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          h1 { color: #333; }
          .info {
            background-color: #e3f2fd;
            padding: 15px;
            border-left: 4px solid #2196F3;
            margin: 10px 0;
          }
          .stat {
            font-size: 18px;
            margin: 10px 0;
          }
          .label {
            font-weight: bold;
            color: #666;
          }
          .value {
            color: #2196F3;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🚀 Simple Web Application on AWS</h1>
          
          <div class="info">
            <div class="stat">
              <span class="label">Instance Hostname:</span>
              <span class="value">${hostname}</span>
            </div>
            <div class="stat">
              <span class="label">Total Page Visits:</span>
              <span class="value">${results[0].total}</span>
            </div>
            <div class="stat">
              <span class="label">S3 Bucket:</span>
              <span class="value">${process.env.S3_BUCKET || 'Not configured'}</span>
            </div>
            <div class="stat">
              <span class="label">Database:</span>
              <span class="value">${process.env.DB_NAME} @ ${process.env.DB_HOST}</span>
            </div>
          </div>

          <h2>AWS Services Used:</h2>
          <ul>
            <li><strong>EC2 (Auto Scaling):</strong> Running on instance ${hostname}</li>
            <li><strong>RDS:</strong> MySQL database for storing visitor data</li>
            <li><strong>S3:</strong> Object storage for application data</li>
            <li><strong>ALB:</strong> Load balancer distributing traffic</li>
            <li><strong>VPC:</strong> Isolated network infrastructure</li>
          </ul>

          <h2>Terraform Managed Infrastructure</h2>
          <p>This entire infrastructure is managed using Terraform, including:</p>
          <ul>
            <li>VPC with public and private subnets</li>
            <li>Application Load Balancer with health checks</li>
            <li>Auto Scaling Group for EC2 instances</li>
            <li>RDS MySQL database with Multi-AZ</li>
            <li>S3 bucket with versioning and encryption</li>
            <li>Security groups and IAM roles</li>
          </ul>
        </div>
      </body>
      </html>
    `;
    
    res.send(html);
  });
});

app.get('/api/visitors', (req, res) => {
  pool.query('SELECT COUNT(*) as total FROM visitors', (error, results) => {
    if (error) {
      return res.status(500).json({ error: error.message });
    }
    res.json({ total_visits: results[0].total });
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', hostname: hostname });
});

// Start server
app.listen(port, () => {
  console.log(`Simple Web App listening on port ${port}`);
});
NODEJS_APP

# Start the application with PM2 for process management
npm install -g pm2
pm2 start app.js --name "web-app"
pm2 startup
pm2 save

# Set environment variables for the app
export AWS_REGION=${aws_region}
export S3_BUCKET=${s3_bucket}
export DB_HOST=${db_host}
export DB_NAME=${db_name}
export DB_USER=${db_user}

# Log startup
echo "Application deployment completed at $(date)" >> /var/log/app-startup.log
echo "S3 Bucket: ${s3_bucket}" >> /var/log/app-startup.log
echo "Database: ${db_host}" >> /var/log/app-startup.log
