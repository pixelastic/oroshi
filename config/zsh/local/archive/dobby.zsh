# Dump file to online domain
function dumptmp() {
  rsync -Pharz \
    $1 \
    pixelastic:./local/www/tmp.pixelastic.com/share
    echo "Available on http://tmp.pixelastic.com/share/${1:t}"
}

function ok() {
  # Only reload xmodmap
  ~/.oroshi/scripts/deploy/xmodmap
}
