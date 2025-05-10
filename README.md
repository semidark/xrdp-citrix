# Remote Desktop Environment Docker Container

A Docker container providing a minimal Xfce desktop with an Citrix Workspace Client accessible via RDP, based on Debian Bookworm.
Can be run on Raspberry (armhf) and amd64 Hardware to give you a very lightweight Citrix Client.

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

With custom username and password:
```bash
docker build --build-arg USERNAME=custom_user --build-arg PASSWORD=secure_password -t rdp-desktop .
```

#### Using .env file for credentials (recommended)

For better security, you can use a .env file to store your credentials instead of passing them as command line arguments:

1. Create a `.env` file based on the example:
```bash
cp .env.example .env
```

2. Edit the `.env` file with your credentials:
```
USERNAME=custom_user
PASSWORD=secure_password
```

3. Run the provided build script:
```bash
./build.sh
```

This approach prevents credentials from appearing in your command history.

### Running the container

Basic usage:

```bash
docker run -d -p 3389:3389 --name rdp-desktop rdp-desktop
```

With persistent home directory:

```bash
docker run -d -p 3389:3389 -v rdp-home:/home/${USERNAME} --name rdp-desktop rdp-desktop
```

Or with explicit username:

```bash
docker run -d -p 3389:3389 -v rdp-home:/home/custom_user --name rdp-desktop rdp-desktop
```

### Connecting to the desktop

Connect using any RDP client (like Microsoft Remote Desktop) to:
- Host: localhost (or your host IP)
- Port: 3389
- Username: The value of USERNAME build arg (default: user)
- Password: The value of PASSWORD build arg (default: password)

## Customization

### Changing the default username and password

Use build arguments when building the image:
```bash
docker build --build-arg USERNAME=custom_user --build-arg PASSWORD=secure_password -t rdp-desktop .
```

If not specified, the default values are:
- Username: user
- Password: password

### Adding additional software

Add your required packages to the `apt-get install` command in the Dockerfile.

## Security Notes

- This container is intended for internal use or development environments.
- The default password should be changed for any usage beyond testing.
- Consider restricting the exposed port to specific networks when deploying.