# Remote Desktop Environment Docker Container

A Docker container providing a full Xfce desktop environment accessible via RDP, based on Debian Bookworm.

## Features

- Remote desktop access via XRDP (port 3389)
- Xfce4 desktop environment
- German keyboard layout and locale
- Pre-installed utilities:
  - File manager
  - Terminal
  - Text editor (Mousepad)
  - Midnight Commander
  - Vim
  - Basic network tools (curl, wget)
  - Citrix Workspace Client
- Non-root user with sudo privileges

## Prerequisites

### Download Citrix Workspace App

Before building the image, you need to manually download the Citrix Workspace app (icaclient) .deb package:

1. Download the latest Citrix Workspace app for Linux from:
   https://www.citrix.com/downloads/workspace-app/legacy-workspace-app-for-linux/workspace-app-for-linux-latest12.html

2. Place the downloaded .deb file in the same directory as the Dockerfile.

## Usage

### Building the image

```bash
docker build -t rdp-desktop .
```

### Running the container

Basic usage:

```bash
docker run -d -p 3389:3389 --name rdp-desktop rdp-desktop
```

With persistent home directory:

```bash
docker run -d -p 3389:3389 -v rdp-home:/home/user --name rdp-desktop rdp-desktop
```

### Connecting to the desktop

Connect using any RDP client (like Microsoft Remote Desktop) to:
- Host: localhost (or your host IP)
- Port: 3389
- Username: user
- Password: password

## Customization

### Changing the default password

Before building the image, modify the following line in the Dockerfile:
```
&& echo "user:password" | chpasswd \
```

### Adding additional software

Add your required packages to the `apt-get install` command in the Dockerfile.


## Security Notes

- This container is intended for internal use or development environments.
- The default password should be changed for any usage beyond testing.
- Consider restricting the exposed port to specific networks when deploying.
