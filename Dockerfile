# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    RSYNC_USERNAME=rsyncuser \
    RSYNC_PASSWORD=rsyncpassword

# Update the package repository and install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        lxde \
        wget \
        unzip \
        tightvncserver \
        openssh-server \
        supervisor \
        rsync \
        cron \
        sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add user for the minimal desktop environment
RUN useradd -m -s /bin/bash desktopuser && \
    echo "desktopuser:password" | chpasswd && \
    echo "desktopuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup SSH for the desktop user
RUN mkdir -p /home/desktopuser/.ssh && \
    chown desktopuser:desktopuser /home/desktopuser/.ssh && \
    chmod 700 /home/desktopuser/.ssh

# Download and install ActivityWatch
RUN wget --no-check-certificate https://github.com/ActivityWatch/activitywatch/releases/download/v0.12.2/activitywatch-v0.12.2-linux-x86_64.zip -P /home/desktopuser && \
    unzip /home/desktopuser/activitywatch-v0.12.2-linux-x86_64.zip -d /home/desktopuser && \
    chmod +x /home/desktopuser/activitywatch/aw-qt && \
    chown -R desktopuser:desktopuser /home/desktopuser/activitywatch && \
    rm /home/desktopuser/activitywatch-v0.12.2-linux-x86_64.zip

# Create ActivityWatchSync folder
RUN mkdir /home/desktopuser/ActivityWatchSync && \
    chown desktopuser:desktopuser /home/desktopuser/ActivityWatchSync

# Configure LXDE to autostart ActivityWatch
RUN mkdir -p /home/desktopuser/.config/lxsession/LXDE
RUN echo '@/home/desktopuser/activitywatch/aw-qt' >> /home/desktopuser/.config/lxsession/LXDE/autostart && \
    chown desktopuser:desktopuser /home/desktopuser/.config/lxsession/LXDE/autostart

#"echo '@rsync -avz --delete --password-file=/etc/rsyncd.secrets /home/${var.rsync_username}/ActivityWatchSync rsync://${var.rsync_username}@activitywatch-vm-0:873/ActivityWatchSync' >> ~/.config/lxsession/LXDE/autostart",
#"echo 'uid = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
#"echo 'gid = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
#"echo 'use chroot = yes' | sudo tee -a /etc/rsyncd.conf",
#"echo 'max connections = 4' | sudo tee -a /etc/rsyncd.conf",
#"echo 'pid file = /var/run/rsyncd.pid' | sudo tee -a /etc/rsyncd.conf",
#"echo 'lock file = /var/run/rsync.lock' | sudo tee -a /etc/rsyncd.conf",
#"echo 'log file = /var/log/rsyncd.log' | sudo tee -a /etc/rsyncd.conf",
#"echo '[ActivityWatchSync]' | sudo tee -a /etc/rsyncd.conf",
#"echo 'path = /home/${var.rsync_username}/ActivityWatchSync' | sudo tee -a /etc/rsyncd.conf",
#"echo 'comment = ActivityWatch Sync folder' | sudo tee -a /etc/rsyncd.conf",
#"echo 'read only = no' | sudo tee -a /etc/rsyncd.conf",
#"echo 'list = yes' | sudo tee -a /etc/rsyncd.conf",
#"echo 'uid = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
#"echo 'gid = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
#"echo 'auth users = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
#"echo 'secrets file = /etc/rsyncd.secrets' | sudo tee -a /etc/rsyncd.conf",
#"echo '${var.rsync_username}:${var.rsync_password}' | sudo tee /etc/rsyncd.secrets",
#RUN sudo chmod 600 /etc/rsyncd.secrets

# Copy over the rsync script
COPY rsync_script.sh /home/desktopuser/rsync_script.sh

# Set up cronjob
RUN (crontab -l ; echo "*/5 * * * * /home/desktopuser/rsync_script.sh") | crontab

# Copy over supervisord config
COPY etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# Needed for sshd, apparently
RUN mkdir /run/sshd

# Expose the SSH and VNC port
EXPOSE 22 5901

# Start VNC server and LXDE
ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
