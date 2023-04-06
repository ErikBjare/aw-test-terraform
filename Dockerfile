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
        openssh-server \
        rsync \
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
RUN wget https://github.com/ActivityWatch/activitywatch/releases/download/v0.12.2/activitywatch-v0.12.2-linux-x86_64.zip -P /home/desktopuser && \
    unzip /home/desktopuser/activitywatch-v0.12.2-linux-x86_64.zip -d /home/desktopuser && \
    chmod +x /home/desktopuser/activitywatch/aw-qt && \
    chown -R desktopuser:desktopuser /home/desktopuser/activitywatch && \
    rm /home/desktopuser/activitywatch-v0.12.2-linux-x86_64.zip

# Create ActivityWatchSync folder
RUN mkdir /home/desktopuser/ActivityWatchSync && \
    chown desktopuser:desktopuser /home/desktopuser/ActivityWatchSync

# Configure LXDE to autostart ActivityWatch
RUN echo '@/home/desktopuser/activitywatch/aw-qt' >> /home/desktopuser/.config/lxsession/LXDE/autostart && \
    chown desktopuser:desktopuser /home/desktopuser/.config/lxsession/LXDE/autostart

# Expose the SSH port
EXPOSE 22

# Start the SSH service
CMD ["/usr/sbin/sshd", "-D"]
