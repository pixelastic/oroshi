# Method 1
Adding `/usr/share/X11/xorg.conf.d/20-intel.conf`

Section "Device"
  Identifier  "card0"
  Driver      "intel"
  Option      "Backlight"  "intel_backlight"
  BusID       "PCI:0:2:0"
EndSection

Log out

# Method 2 (no longer seems to work)
Open `/etc/default/grub`
Check for the `GRUB_CMDLINE_LINUX_DEFAULT` option
Add `acpi_backlight=vendor`

Eg.
    GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi_backlight=vendor"

$ sudo update-grub
$ sudo reboot
