# Sif-OS base on a clean uBlue image
FROM ghcr.io/ublue-os/bluefin:latest

# ----- metadata (helps force a new ostree commit each build) -----
ARG IMAGE_VERSION=0.4.0
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
      remmina \
      remmina-plugins-rdp \
      remmina-plugins-vnc \
      remmina-plugins-spice \
      remmina-plugins-secret


# ----- Flatpak: add Flathub + install Remmina system-wide -----
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
      && flatpak install -y --system org.mozilla.firefox

# make a place for your branding
RUN mkdir -p /usr/share/ublue/branding

# copy your assets in
COPY build_files/branding/ /usr/share/ublue/branding/


# ----- (Optional) theming/assets wiring (leave commented for now) -----
# COPY files/backgrounds/sif /usr/share/backgrounds/sif
# COPY files/themes/YourTheme /usr/share/themes/YourTheme
# COPY files/icons/YourIconTheme /usr/share/icons/YourIconTheme
# COPY files/plymouth/sif /usr/share/plymouth/themes/sif
# RUN sed -i 's/^Theme=.*/Theme=sif/' /etc/plymouth/plymouthd.conf || true
