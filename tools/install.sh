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

echo "To complete installation add an alias to your .bashrc file:"
echo "\t alias change='sh $CHANGE/changelog.sh'"
echo ""
echo "or add $CHANGE/bin to your \$PATH variable"
