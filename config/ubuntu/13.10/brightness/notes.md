Open `/etc/default/grub`
Check for the `GRUB_CMDLINE_LINUX_DEFAULT` option
Add `acpi_backlight=vendor`

Eg.
    GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi_backlight=vendor"

$ sudo update-grub
$ sudo reboot

