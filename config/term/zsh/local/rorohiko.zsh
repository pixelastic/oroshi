# CONFIG
# Rorohiko is my second Algolia Laptop, not using it much as the keyboard and
# hardware are subpar
# Rorohiko is running Ubuntu 20.04
# BAT theme was called ansi-dark
export BAT_THEME="ansi-dark"

# Dump file to online domain
function dumptmp() {
  rsync -Pharz \
    $1 \
    pixelastic:./local/www/tmp.pixelastic.com/share
    echo "Available on http://tmp.pixelastic.com/share/${1:t}"
}
