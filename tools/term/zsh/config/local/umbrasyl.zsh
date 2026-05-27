# Reload keybindings
# Umbrasyl is my "temporary" Algolia laptop, X1 Carbon 5th generation
function ok() {
	# Xmodmap (keys)
	$OROSHI_ROOT/tools/keybindings/xmodmap/deploy

	# Ubuntu (window management, apps)
	$OROSHI_ROOT/tools/ubuntu/22.04/keybindings/deploy

	# Xbindkey (media playback)
	$OROSHI_ROOT/tools/keybindings/xbindkeys/deploy
}
