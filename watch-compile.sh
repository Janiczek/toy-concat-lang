#!/usr/bin/env bash

COLOR_OFF="\e[0m";
DIM="\e[2m";

function compile {
  find src -type f -name '*.elm' | xargs npx elm-esm make --output=elm.js \
    && echo "Starting the compiler" \
    && node index.js
}

function run {
  clear;
  tput reset;
  echo -en "\033c\033[3J";

  echo -en "${DIM}";
  date -R;
  echo -en "${COLOR_OFF}";

  compile;
}

run;

chokidar src | while read WHATEVER; do
  run;
done;
