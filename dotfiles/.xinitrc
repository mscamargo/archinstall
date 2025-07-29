if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do [ -x "$f" ] && . "$f"; done
fi

systemctl --user import-environment DISPLAY XAUTHORITY
dbus-update-activation-environment --all &
gnome-keyring-daemon --start --components=secrets &
statusbarloop &
remaps &
exec dwm
