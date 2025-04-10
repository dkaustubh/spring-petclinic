#!/bin/bash
chmod +x /opt/spring-petclinic/spring-petclinic.jar

# Create systemd service file
cat > /etc/systemd/system/petclinic.service << 'EOF'
[Unit]
Description=Spring PetClinic Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/opt/spring-petclinic
ExecStart=/usr/bin/java -jar /opt/spring-petclinic/spring-petclinic.jar
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload
