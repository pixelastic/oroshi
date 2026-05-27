# We might be using both Yarn Classic (v1) and Yarn Berry (v2+) on different
# projects.
#
# To make "yarn link" work in both version, we need some wrapper scripts, and
# those scripts need to check the following folder to see where Yarn Classic
# stores its registered links
export OROSHI_YARN_CLASSIC_LINK_FOLDER=~/.config/yarn/link/
