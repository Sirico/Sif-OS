# Sif-OS base on a clean uBlue image
FROM ghcr.io/ublue-os/silverblue-main:latest

# ----- metadata (helps force a new ostree commit each build) -----
ARG IMAGE_VERSION=0.1.0
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

# ----- Flatpak: add Flathub + install Remmina system-wide -----
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
 && flatpak install -y --system flathub org.remmina.Remmina

# ----- (Optional) smartcard + Intel media decode for Wyse 5070 -----
# Uncomment if you want better HW video decode and CAC support out of the box
# RUN rpm-ostree install intel-media-driver libva-utils pcsc-lite ccid opensc \
#  && systemctl enable pcscd.service

# ----- (Optional) GNOME power defaults for thin clients -----
# If you later add a gschema override, copy it like this:
# COPY files/gschema-overrides/zzz-thinclient.gschema.override /usr/share/glib-2.0/schemas/
# RUN glib-compile-schemas /usr/share/glib-2.0/schemas

# ----- (Optional) theming/assets wiring (leave commented for now) -----
# COPY files/backgrounds/sif /usr/share/backgrounds/sif
# COPY files/themes/YourTheme /usr/share/themes/YourTheme
# COPY files/icons/YourIconTheme /usr/share/icons/YourIconTheme
# COPY files/plymouth/sif /usr/share/plymouth/themes/sif
# RUN sed -i 's/^Theme=.*/Theme=sif/' /etc/plymouth/plymouthd.conf || true
