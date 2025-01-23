# APK Downloader with Admin and User Functionality

## Overview

This project provides a system where an admin can host APK files and users can request and download these files over the same Wi-Fi network. The functionality includes scanning phone IDs, detecting processor types, and handling APK file transfers seamlessly. Below is a summary of the tasks achieved and the current issues:

---

## Features

1. **Admin Functionality:**
   - Scans and identifies the phone's unique ID to determine admin access.
   - Hosts a server locally to share APK files over the same Wi-Fi network.

2. **User Functionality:**
   - Scans and identifies the processor type of the user's device.
   - Sends a request to the admin server to fetch APK files specific to the processor type.
   - Displays a download progress bar in the UI from 0% to 100%.
   - Automatically opens the downloaded APK file after completion.
   - Automatically deletes the APK file after a specified delay.

3. **File Support:**
   - Successfully supports the transfer of other file types like PNG, JPG, and MP4, regardless of size.

---

## Current Issue

- **APK File Streaming Issue:**
  When the admin hosts an APK file and tries to stream it to the user, an issue occurs. However, other file types (PNG, JPG, MP4) work perfectly, even for large files.

---

## How It Works

1. **Admin:**
   - Hosts a local server using `shelf` to handle file requests.
   - Streams files from the specified path to the user, depending on the processor type received in the request.

2. **User:**
   - Sends a request to the admin's server with their processor type.
   - Receives the requested file and displays the download progress.
   - Automatically opens and deletes the file after downloading.

---

## Requirements

- Both admin and user devices should be connected to the same Wi-Fi network.
- Permissions are required to access storage (handled programmatically).
- Ensure the server is running on the admin side before sending requests.

---

## Next Steps

- Debug and resolve the issue with APK file streaming.
- Conduct additional tests to confirm the solution's stability across various scenarios.

---

### Author

This project was created and tested by **Osama Abdelrassoul**.