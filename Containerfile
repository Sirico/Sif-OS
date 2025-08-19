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
      firefox \
      remmina \
      remmina-plugins-rdp \
      remmina-plugins-vnc \
      remmina-plugins-spice \
      remmina-plugins-secret


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
