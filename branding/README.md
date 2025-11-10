# SifOS Branding Assets

This directory contains company branding assets that will be deployed to all SifOS machines.

## Required Assets

Place your company branding files in this directory with these exact filenames:

### 1. **company-logo.png**
- **Used for**: Login screen logo, about dialogs
- **Recommended size**: 256x256px or 512x512px
- **Format**: PNG with transparency
- **Description**: Your company logo for login screens and system dialogs

### 2. **plymouth-logo.png**
- **Used for**: Boot splash screen (shown during system startup)
- **Recommended size**: 256x256px
- **Format**: PNG with transparency
- **Description**: Logo displayed while system is booting

### 3. **login-background.jpg**
- **Used for**: Login screen background
- **Recommended size**: 1920x1080px (or higher for 4K displays)
- **Format**: JPG or PNG
- **Description**: Background image for the login/lock screen

### 4. **wallpaper.jpg**
- **Used for**: Desktop wallpaper for all users
- **Recommended size**: 1920x1080px or higher
- **Format**: JPG or PNG
- **Description**: Default desktop wallpaper

### 5. **user-icon.png**
- **Used for**: User avatar in login screen and system menus
- **Recommended size**: 96x96px or 128x128px
- **Format**: PNG with transparency
- **Description**: Default avatar for admin and sif users

## File Format Guidelines

### Logo Files (company-logo.png, plymouth-logo.png)
- Use PNG format with transparency
- Keep simple and recognizable at small sizes
- Square aspect ratio recommended
- High contrast for visibility

### Background Files (login-background.jpg, wallpaper.jpg)
- JPG for photos, PNG for graphics
- Use company brand colors
- Avoid busy patterns that make text hard to read
- Consider multiple monitor setups

### User Icon (user-icon.png)
- PNG with transparency
- Simple, recognizable design
- Works well at small sizes (48x48 to 128x128)

## Quick Start

1. **Add your files to this directory**:
   ```bash
   # Copy your branded images here
   cp /path/to/your-logo.png branding/company-logo.png
   cp /path/to/your-logo.png branding/plymouth-logo.png
   cp /path/to/background.jpg branding/login-background.jpg
   cp /path/to/wallpaper.jpg branding/wallpaper.jpg
   cp /path/to/user-avatar.png branding/user-icon.png
   ```

2. **Enable branding module** in `configuration.nix`:
   ```nix
   imports = [
     ./modules/branding.nix  # Add this line
     # ... other modules
   ];
   ```

3. **Test the configuration**:
   ```bash
   ./scripts/test-build.sh
   ```

4. **Commit and deploy**:
   ```bash
   git add branding/
   git commit -m "Add company branding assets"
   git push
   ./remote-deploy.sh -t 192.168.0.49 -a
   ```

## GNOME Theme Settings

The branding module automatically configures:

- **🌑 Dark Mode**: GNOME set to dark theme
- **💛 Yellow Accents**: Primary color set to yellow (#FDB714)
- **⚫ Black Backgrounds**: Secondary color set to black
- **🎨 System-wide**: All users get consistent branding

### Color Scheme

- **Primary (Yellow)**: `#FDB714` - Used for highlights and accents
- **Secondary (Black)**: `#000000` - Used for backgrounds
- **Theme**: Adwaita-dark (GNOME's built-in dark theme)
- **Accent Color**: Yellow

### What Gets Themed

✅ **System UI** - Top bar, menus, dialogs  
✅ **Applications** - GTK apps follow dark theme  
✅ **File Manager** - Nautilus in dark mode  
✅ **Terminal** - Dark background by default  
✅ **Selection Colors** - Yellow highlights  
✅ **Focus Indicators** - Yellow borders on active elements  

### Customizing Colors

To change the color scheme, edit `modules/branding.nix`:

```nix
# Change yellow to your company color
primary-color='#FDB714'  # Your color hex code here
accent-color='yellow'     # Options: blue, green, orange, pink, purple, red, slate, teal, yellow
```

## Where Each Asset Appears

| Asset | Location | When Visible |
|-------|----------|--------------|
| **plymouth-logo.png** | Boot splash screen | During system boot |
| **company-logo.png** | Login screen (top center) | At login/lock screen |
| **login-background.jpg** | Login screen background | At login/lock screen |
| **wallpaper.jpg** | Desktop background | After login |
| **user-icon.png** | User menu, login screen | Login and top-right menu |

## Testing Branding

After deployment, you can test each component:

### Test Boot Logo (Plymouth)
```bash
# On the target machine
sudo plymouthd --debug
sudo plymouth show-splash
# Wait 5 seconds
sudo plymouth quit
```

### Test Login Screen
```bash
# Lock the screen to see login background
gnome-screensaver-command -l
```

### Test Wallpaper
- Log in as `sif` user
- Wallpaper should appear automatically

### Test User Icon
- Check top-right corner of GNOME
- Check user list on login screen

## Advanced Customization

### Custom Plymouth Theme

For a fully custom Plymouth theme, you can create a theme package. See `modules/branding.nix` for how to configure it.

### Per-User Wallpapers

To set different wallpapers for different users, edit their home directory settings:

```bash
# As the user
gsettings set org.gnome.desktop.background picture-uri 'file:///path/to/wallpaper.jpg'
```

### Custom Fonts

Add your company fonts to `modules/branding.nix`:

```nix
fonts.packages = with pkgs; [
  # Add custom font packages
];
```

## Git and Version Control

- ✅ **DO** commit branding assets to git
- ✅ **DO** use compressed JPG for photos (keep repo size small)
- ✅ **DO** optimize PNG files before committing
- ⚠️ **NOTE**: Branding files will be public if repository is public

### Optimize Images Before Committing

```bash
# Optimize JPG files (requires jpegoptim)
jpegoptim --size=500k branding/*.jpg

# Optimize PNG files (requires optipng)
optipng -o5 branding/*.png
```

## Troubleshooting

### Branding not appearing
- Check files are in correct location: `ls -lh branding/`
- Verify module is imported in `configuration.nix`
- Check files copied to machine: `ls -lh /etc/sifos/branding/`
- Rebuild and reboot: `sudo nixos-rebuild switch && sudo reboot`

### Plymouth logo not showing
- Verify plymouth is enabled: `systemctl status plymouth-start.service`
- Check boot options: `cat /proc/cmdline | grep splash`
- May need to add `quiet splash` to boot options

### Wallpaper not changing
- Run dconf update: `sudo dconf update`
- Check dconf settings: `dconf dump /org/gnome/desktop/background/`
- Restart GNOME: Log out and back in

### User icons not appearing
- Check AccountsService: `ls -l /var/lib/AccountsService/icons/`
- Verify permissions: Icons should be readable by all users
- Restart display manager: `sudo systemctl restart display-manager`

## Examples

Example branding assets structure:
```
branding/
├── company-logo.png          # 512x512, company logo with transparency
├── plymouth-logo.png         # 256x256, simplified logo for boot
├── login-background.jpg      # 1920x1080, company branded background
├── wallpaper.jpg             # 2560x1440, desktop wallpaper
└── user-icon.png             # 128x128, generic user avatar
```

## See Also

- [NixOS Manual - GNOME](https://nixos.org/manual/nixos/stable/#sec-gnome)
- [Plymouth Themes](https://www.freedesktop.org/wiki/Software/Plymouth/)
- [AccountsService](https://www.freedesktop.org/wiki/Software/AccountsService/)
