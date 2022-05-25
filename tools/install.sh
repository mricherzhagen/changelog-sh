#!/bin/bash

if [ ! -n "$CHANGE" ]; then
  CHANGE=~/.change
fi

if [ -d "$CHANGE" ]; then
  printf "You already have CHANGE installed.\n"
  printf "You'll need to remove $CHANGE if you want to re-install.\n"
  exit
fi

git clone https://github.com/mricherzhagen/changelog-sh.git $CHANGE

echo ""
chmod +x $CHANGE/changelog.sh

cd $CHANGE
# Code from https://stackoverflow.com/a/3867811/2256700
latestTag=$(git describe --tags --match "v[0-9]*" --abbrev=0 HEAD)

# Code from https://stackoverflow.com/a/45652159/2256700
git -c advice.detachedHead=false checkout $latestTag

echo ""
echo "To complete installation add $CHANGE/bin to your \$PATH variable:"
echo ""
echo "    PATH=$CHANGE/bin:\$PATH"
echo ""
echo "or add an alias to your .bashrc file:"
echo ""
echo "    alias change='bash $CHANGE/changelog.sh'"
echo ""
