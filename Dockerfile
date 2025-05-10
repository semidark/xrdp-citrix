# Define build arguments for username and password without defaults
ARG USERNAME
ARG PASSWORD

FROM debian:bookworm-slim
#FROM dtcooper/raspberrypi-os:lite-bookworm

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Make build args available after FROM
ARG USERNAME
ARG PASSWORD

# Set USERNAME as environment variable for runtime
ENV CONTAINER_USER=${USERNAME}

# Install minimal required packages
RUN apt update && apt install -y \
    xrdp \
    ca-certificates \
    xorgxrdp \
    xdotool \
    xfce4 \
    xfce4-terminal \
    dumb-init \
    dbus \
    mc \
    vim \
    curl \
    wget \
    mousepad \
    dbus-x11 \
    sudo \
    keyboard-configuration \
    locales \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Copy pre-downloaded Citrix Workspace App packages
# COPY icaclient_24.2.0.65_armhf.deb icaclient_24.2.0.65_amd64.deb /tmp/

# Install Citrix Workspace App non-interactively using BuildKit mounts
# Note: This requires BuildKit to be enabled (DOCKER_BUILDKIT=1)
RUN --mount=type=bind,source=icaclient_24.2.0.65_armhf.deb,target=/tmp/icaclient_24.2.0.65_armhf.deb \
    --mount=type=bind,source=icaclient_24.2.0.65_amd64.deb,target=/tmp/icaclient_24.2.0.65_amd64.deb \
    apt update && \
    export DEBIAN_FRONTEND="noninteractive" \
    && echo "icaclient app_protection/install_app_protection select yes" | debconf-set-selections \
    # For armhf architecture (Raspberry Pi 32-bit)
    && if [ "$(dpkg --print-architecture)" = "armhf" ]; then \
        apt install -y -f /tmp/icaclient_24.2.0.65_armhf.deb; \
    # For amd64 architecture (64-bit x86)
    elif [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        apt install -y -f /tmp/icaclient_24.2.0.65_amd64.deb; \
    fi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure locale and generate German locale
RUN sed -i 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

# Configure XRDP for better performance
RUN sed -i 's/^new_cursors=true/new_cursors=false/g' /etc/xrdp/xrdp.ini \
    && sed -i 's/^max_bpp=32/max_bpp=16/g' /etc/xrdp/xrdp.ini \
    && adduser xrdp ssl-cert

# Set German keyboard layout system-wide
RUN echo 'XKBMODEL="pc105"\nXKBLAYOUT="de"\nXKBVARIANT=""\nXKBOPTIONS=""' > /etc/default/keyboard \
    && dpkg-reconfigure -f noninteractive keyboard-configuration \
    && echo "setxkbmap de" > /etc/profile.d/keyboard.sh \
    && chmod +x /etc/profile.d/keyboard.sh

# Create non-root user with sudo privileges
RUN useradd -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME}:${PASSWORD}" | chpasswd \
    && usermod -aG sudo ${USERNAME}

# Define volume for user home directory
VOLUME /home/${USERNAME}

# Set up Xfce session for XRDP
RUN echo "#!/bin/sh" > /etc/xrdp/startwm.sh \
    && echo "export XDG_SESSION_DESKTOP=xfce" >> /etc/xrdp/startwm.sh \
    && echo "export XDG_CURRENT_DESKTOP=xfce" >> /etc/xrdp/startwm.sh \
    && echo "setxkbmap de" >> /etc/xrdp/startwm.sh \
    && echo "exec startxfce4" >> /etc/xrdp/startwm.sh \
    && chmod +x /etc/xrdp/startwm.sh

# Create startup script
RUN echo '#!/bin/bash\n\
# Ensure keyboard configuration exists in user home\n\
mkdir -p /home/$CONTAINER_USER/.config/autostart\n\
echo "[Desktop Entry]\nType=Application\nName=Keyboard Layout\nExec=setxkbmap de\nStartupNotify=false\nTerminal=false\nHidden=false" > /home/$CONTAINER_USER/.config/autostart/keyboard-layout.desktop\n\
chown -R $CONTAINER_USER:$CONTAINER_USER /home/$CONTAINER_USER/.config\n\
\n\
# Start services\n\
mkdir -p /var/run/dbus\n\
dbus-daemon --system\n\
service xrdp start\n\
service xrdp-sesman start\n\
echo "XRDP server started. Connect to port 3389."\n\
# Keep container running\n\
tail -f /var/log/xrdp-sesman.log' > /start.sh \
    && chmod +x /start.sh

# Expose RDP port
EXPOSE 3389/tcp

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start services
CMD ["/start.sh"]
