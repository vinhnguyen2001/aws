// Configuration - Update this with your API endpoint after terraform apply
const API_ENDPOINT = 'http://API_PUBLIC_IP:3000';

// Test connection button functionality
document.addEventListener('DOMContentLoaded', function() {
    const testButton = document.getElementById('test-connection');
    const saveButton = document.getElementById('save-message');
    const loadButton = document.getElementById('load-messages');
    const messageInput = document.getElementById('message-input');
    const resultDiv = document.getElementById('result');
    const messagesListDiv = document.getElementById('messages-list');
    
    // Test RDS connection
    if (testButton) {
        testButton.addEventListener('click', async function() {
            resultDiv.textContent = 'Testing connection to RDS...';
            resultDiv.className = 'result';
            
            try {
                const response = await fetch(`${API_ENDPOINT}/api/test-connection`);
                const data = await response.json();
                
                if (data.success) {
                    resultDiv.className = 'result success';
                    resultDiv.innerHTML = `
                        <strong>✓ Connection Successful!</strong><br>
                        Connected to RDS MySQL Database<br>
                        • Database: ${data.database}<br>
                        • Host: ${data.host}<br>
                        • Status: ${data.message}
                    `;
                } else {
                    resultDiv.className = 'result error';
                    resultDiv.innerHTML = `
                        <strong>✗ Connection Failed</strong><br>
                        Error: ${data.error}
                    `;
                }
            } catch (error) {
                resultDiv.className = 'result error';
                resultDiv.innerHTML = `
                    <strong>✗ Connection Failed</strong><br>
                    Error: ${error.message}<br>
                    Make sure the API server is running and accessible.
                `;
            }
        });
    }
    
    // Save message to database
    if (saveButton && messageInput) {
        saveButton.addEventListener('click', async function() {
            const text = messageInput.value.trim();
            
            if (!text) {
                resultDiv.className = 'result error';
                resultDiv.textContent = 'Please enter a message';
                return;
            }
            
            resultDiv.textContent = 'Saving to database...';
            resultDiv.className = 'result';
            
            try {
                const response = await fetch(`${API_ENDPOINT}/api/messages`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ text })
                });
                
                const data = await response.json();
                
                if (data.success) {
                    resultDiv.className = 'result success';
                    resultDiv.innerHTML = `
                        <strong>✓ Message Saved!</strong><br>
                        Your message has been stored in RDS MySQL database<br>
                        Message ID: ${data.id}
                    `;
                    messageInput.value = '';
                    
                    // Auto-load messages after save
                    setTimeout(() => loadMessages(), 500);
                } else {
                    resultDiv.className = 'result error';
                    resultDiv.textContent = `Error: ${data.error}`;
                }
            } catch (error) {
                resultDiv.className = 'result error';
                resultDiv.textContent = `Error: ${error.message}`;
            }
        });
        
        // Allow Enter key to save
        messageInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                saveButton.click();
            }
        });
    }
    
    // Load messages from database
    async function loadMessages() {
        messagesListDiv.innerHTML = '<p>Loading messages...</p>';
        
        try {
            const response = await fetch(`${API_ENDPOINT}/api/messages`);
            const data = await response.json();
            
            if (data.success && data.messages.length > 0) {
                messagesListDiv.innerHTML = '<ul class="messages">' + 
                    data.messages.map(msg => `
                        <li class="message-item">
                            <div class="message-text">${escapeHtml(msg.text)}</div>
                            <div class="message-time">${new Date(msg.created_at).toLocaleString()}</div>
                        </li>
                    `).join('') + 
                    '</ul>';
            } else if (data.success && data.messages.length === 0) {
                messagesListDiv.innerHTML = '<p class="no-messages">No messages yet. Be the first to add one!</p>';
            } else {
                messagesListDiv.innerHTML = '<p class="error-text">Error loading messages</p>';
            }
        } catch (error) {
            messagesListDiv.innerHTML = `<p class="error-text">Error: ${error.message}</p>`;
        }
    }
    
    if (loadButton) {
        loadButton.addEventListener('click', loadMessages);
    }
    
    // Escape HTML to prevent XSS
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    // Add smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Animate service cards on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    document.querySelectorAll('.service-card').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });
});
