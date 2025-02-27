# Boot Animation Generator for Android

This script extracts frames from a video to create a **bootanimation.zip** for Android devices. It also extracts the audio as a **boot.wav** file and optionally generates a **shutdownanimation.zip** with reversed frames.

## Features
✅ Extracts frames from a video and formats them for boot animation.
✅ Supports two scaling modes: `pad` (adds black bars) and `cover` (fills screen, crops if needed).
✅ Generates `bootanimation.zip` with `part0` (animated frames) and `part1` (static final frame).
✅ Extracts audio as `boot.wav`.
✅ Optionally creates `shutdownanimation.zip` with reversed frames.
✅ Allows specifying FPS, start and end time, and resolution.

## Requirements
Ensure you have `ffmpeg` and `zip` installed on your system:
```sh
sudo apt install ffmpeg zip  # Debian/Ubuntu
brew install ffmpeg zip      # macOS
```

## Installation
1. Download the script:
   ```sh
   curl -O [https://your-repo-url/bootanimation.sh](https://raw.githubusercontent.com/luca-saggese/video2bootanimation/refs/heads/main/video2bootanimation.sh)
   ```
2. Make it executable:
   ```sh
   chmod +x bootanimation.sh
   ```

## Usage
### Basic Boot Animation Generation
```sh
./bootanimation.sh -i video.mp4 -w 1080 -h 1920
```
Generates `bootanimation.zip` and `boot.wav`.

### Using Different Scaling Modes
- **Pad Mode (default)**: Maintains aspect ratio with black bars.
  ```sh
  ./bootanimation.sh -i video.mp4 -w 1080 -h 1920 -scale pad
  ```
- **Cover Mode**: Fills the screen, cropping excess parts.
  ```sh
  ./bootanimation.sh -i video.mp4 -w 1080 -h 1920 -scale cover
  ```

### Extracting a Specific Video Segment
```sh
./bootanimation.sh -i video.mp4 -w 1080 -h 1920 -s 00:00:05 -e 00:00:10
```
Extracts frames between `00:00:05` and `00:00:10`.

### Changing Frame Rate
```sh
./bootanimation.sh -i video.mp4 -w 1080 -h 1920 -f 60
```
Uses 60 FPS instead of the default 30.

### Generating a Shutdown Animation
```sh
./bootanimation.sh -i video.mp4 -w 1080 -h 1920 -shutdown
```
Creates `shutdownanimation.zip` with reversed frames.

## Output Files
- **bootanimation.zip** → Android-compatible boot animation.
- **boot.wav** → Extracted audio.
- **shutdownanimation.zip** (optional) → Shutdown animation with reversed frames.

## Installation on Android (Root Required)
Copy `bootanimation.zip` to your device:
```sh
adb push bootanimation.zip /system/media/bootanimation.zip
adb push boot.wav /system/media/audio/ui/boot.wav
adb reboot
```
For shutdown animation:
```sh
adb push shutdownanimation.zip /system/media/shutdownanimation.zip
```

## License
MIT License. Free to use and modify.

---
🚀 **Enjoy your custom Android boot animation!**

