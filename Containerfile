# Containerfile — Sif-OS (Bluefin base + Remmina + Tailscale + autologin, no branding)

FROM ghcr.io/ublue-os/bluefin:stable

LABEL org.opencontainers.image.title="Sif-OS (Thin Client)"
LABEL org.opencontainers.image.description="Bluefin (GNOME) + Remmina + Tailscale + autologin for Wyse 5070"
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
# 5) Preseed Remmina profiles (optional)
# -------------------------
# If you add *.remmina files under build_files/remmina, they’ll be copied in.
COPY build_files/remmina /tmp/remmina-profiles
RUN install -d /etc/skel/.local/share/remmina \
    && if [ -d /tmp/remmina-profiles ]; then \
        cp -a /tmp/remmina-profiles/*.remmina /etc/skel/.local/share/remmina/ 2>/dev/null || true; \
    fi \
    && rm -rf /tmp/remmina-profiles \
    && ostree container commit

# -------------------------
# Notes:
# - Branding removed (no wallpaper/logo copy).
# - Add build_files/remmina if you want preseeded connection profiles.
# - First boot: connect Tailscale:
#     sudo tailscale up --authkey=tskey-xxxx --ssh
# -------------------------
