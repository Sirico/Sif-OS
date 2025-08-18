# Containerfile — Sif-OS (Bluefin base + Remmina + Tailscale + branding)

FROM ghcr.io/ublue-os/bluefin:stable

LABEL org.opencontainers.image.title="Sif-OS (Thin Client)"
LABEL org.opencontainers.image.description="Bluefin (GNOME) + Remmina + Tailscale + autologin + branding for Wyse 5070"
LABEL org.opencontainers.image.source="https://github.com/<you>/Sif-OS"

# -------------------------
# 1) Core additions
# -------------------------
RUN rpm-ostree install tailscale \
    && systemctl enable tailscaled \
    && ostree container commit

# -------------------------
# 2) Remmina via Flatpak (system-wide)
# -------------------------
RUN flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo \
    && flatpak install --noninteractive --system flathub org.remmina.Remmina \
    && ostree container commit

# -------------------------
# 3) Thin client user + GDM autologin
# -------------------------
RUN useradd -m thinuser && passwd -d thinuser \
    && install -d /etc/gdm \
    && printf "[daemon]\nAutomaticLoginEnable=true\nAutomaticLogin=thinuser\n" > /etc/gdm/custom.conf \
    && ostree container commit

# -------------------------
# 4) Autostart Remmina
# -------------------------
RUN install -d /etc/xdg/autostart \
    && printf "[Desktop Entry]\nType=Application\nName=Remmina\nExec=flatpak run org.remmina.Remmina\nX-GNOME-Autostart-enabled=true\n" \
       > /etc/xdg/autostart/remmina.desktop \
    && ostree container commit

# -------------------------
# 5) Branding: wallpaper + logo
# -------------------------
COPY build_files/branding /usr/share/sif-branding

# Default wallpaper
RUN install -d /usr/share/backgrounds/sif \
    && [ -f /usr/share/sif-branding/wallpaper.jpg ] && cp /usr/share/sif-branding/wallpaper.jpg /usr/share/backgrounds/sif/default.jpg || true \
    && ostree container commit

# GNOME background schema override
RUN install -d /usr/share/glib-2.0/schemas \
    && bash -lc 'cat >/usr/share/glib-2.0/schemas/10-sif.gschema.override <<EOF
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/sif/default.jpg'
picture-uri-dark='file:///usr/share/backgrounds/sif/default.jpg'
EOF' \
    && glib-compile-schemas /usr/share/glib-2.0/schemas \
    && ostree container commit

# Optional: GDM greeter logo
RUN [ -f /usr/share/sif-branding/sif-logo.png ] && cp /usr/share/sif-branding/sif-logo.png /usr/share/pixmaps/sif-logo.png || true \
    && ostree container commit

# -------------------------
# 6) Preseed Remmina profiles
# -------------------------
COPY build_files/remmina /tmp/remmina-profiles
RUN install -d /etc/skel/.local/share/remmina \
    && if [ -d /tmp/remmina-profiles ]; then \
        cp -a /tmp/remmina-profiles/*.remmina /etc/skel/.local/share/remmina/ 2>/dev/null || true; \
    fi \
    && rm -rf /tmp/remmina-profiles \
    && ostree container commit

# -------------------------
# Notes:
# - First boot: join Tailscale:
#     sudo tailscale up --authkey=tskey-xxxx --ssh
# - Remmina autostarts for thinuser on login.
# - Branding: put wallpaper.jpg and sif-logo.png in build_files/branding/.
# -------------------------
