If the touchpad refuse to scroll after resume, you should edit
/etc/modprobe.d/blacklist.conf and comment the line saying:

```
blacklist i2c_i801
```

Source: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1722478#yui_3_10_3_1_1538643308502_535
