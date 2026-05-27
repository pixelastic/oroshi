# Rbenv
# The suggested way of installing rbenv is running eval "$(rbenv init -)"
# This adds ~150ms to shell startup. The only thing important it's doing is
# running rbenv rehash, which is what takes the most time.
#
# Rehashing is needed to update the shims whenever we add new gems, so I added
# some wrapper scripts (bundle-install/update and gem-install/update) that will
# call the rehash.
#
# Source: https://github.com/rbenv/rbenv#how-rbenv-hooks-into-your-shell

# We disable the installation of local docs when installing gems, as it adds
# time to the install for a feature I never use.
RUBY_CONFIGURE_OPTS=--disable-install-doc
