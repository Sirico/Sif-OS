# Sif-OS base on a clean uBlue image
FROM ghcr.io/ublue-os/bluefin:latest

# ----- metadata (helps force a new ostree commit each build) -----
ARG IMAGE_VERSION=0.5.0
LABEL org.opencontainers.image.title="Sif-OS"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.description="uBlue-based thin client image with Tailscale + Remmina"

# ----- Tailscale: add official repo + install -----
# https://pkgs.tailscale.com/stable/fedora/
RUN curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
      -o /etc/yum.repos.d/tailscale.repo \
      && rpm-ostree install tailscale

# Enable tailscaled on boot (systemd presets get baked into /etc)
RUN systemctl enable tailscaled.service

# ----- Remmina via RPMs (system-wide) -----
# Core app + common plugins (RDP, VNC, SPICE, secret storage)
RUN rpm-ostree install \
      firefox \
      remmina \
      remmina-plugins-rdp \
      remmina-plugins-vnc \
      remmina-plugins-spice \
      remmina-plugins-secret


# --- Branding (optional) ---
# Put your files in build_files/branding (e.g. wallpapers/, gdm/, icons/, etc.)
COPY build_files/branding/ /usr/share/sif-branding/

RUN set -eux \
      && dest="/usr/share/ublue/branding" \
      && mkdir -p "$dest" \
      # 'rm -rf /path/*' errors if the dir didn't exist / glob doesn't expand; tolerate it:
      && rm -rf "$dest"/* 2>/dev/null || true \
      # copy contents (dot keeps hidden files), preserve attrs:
      && cp -a /usr/share/sif-branding/. "$dest"/
# ----- Branding -----
COPY build_files/branding /usr/share/sif-branding
RUN rm -rf /usr/share/ublue/branding/* \
      && cp -r /usr/share/sif-branding/* /usr/share/ublue/branding/


# ----- (Optional) theming/assets wiring (leave commented for now) -----
# COPY files/backgrounds/sif /usr/share/backgrounds/sif
# COPY files/themes/YourTheme /usr/share/themes/YourTheme
# COPY files/icons/YourIconTheme /usr/share/icons/YourIconTheme
# COPY files/plymouth/sif /usr/share/plymouth/themes/sif
# RUN sed -i 's/^Theme=.*/Theme=sif/' /etc/plymouth/plymouthd.conf || true

#####changes 0.5.0
# GNOME defaults (dark + yellow)
COPY build_files/schemas/ /usr/share/glib-2.0/schemas/
RUN glib-compile-schemas /usr/share/glib-2.0/schemas

# dconf defaults + locks (+ GDM, if those files exist)
COPY build_files/dconf/ /etc/dconf/
RUN dconf update || true



