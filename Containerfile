# Minimal Fedora bootc + GNOME + Remmina + Tailscale
FROM quay.io/fedora/fedora-bootc:41

RUN rpm-ostree install \
      gdm gnome-shell gnome-control-center gnome-terminal nautilus \
      xdg-desktop-portal-gnome gsettings-desktop-schemas adwaita-gtk2-theme \
      flatpak tailscale \
    && systemctl enable gdm tailscaled \
    && ostree container commit

# Remmina system-wide (Flatpak)
RUN flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo \
 && flatpak install --noninteractive --system flathub org.remmina.Remmina \
 && ostree container commit

# Autologin + thin client user + autostart Remmina
RUN useradd -m thinuser && passwd -d thinuser \
 && install -d /etc/gdm \
 && printf "[daemon]\nAutomaticLoginEnable=true\nAutomaticLogin=thinuser\n" > /etc/gdm/custom.conf \
 && install -d /etc/xdg/autostart \
 && printf "[Desktop Entry]\nType=Application\nName=Remmina\nExec=flatpak run org.remmina.Remmina\nX-GNOME-Autostart-enabled=true\n" \
    > /etc/xdg/autostart/remmina.desktop \
 && ostree container commit
