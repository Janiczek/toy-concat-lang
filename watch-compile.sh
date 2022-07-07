#!/usr/bin/env bash

COLOR_OFF="\e[0m";
DIM="\e[2m";
OUTFILE="compiler.js"

function compile {
  rm elm.js >& /dev/null
  find src -type f -name '*.elm' | xargs elm make --output=/dev/null
  npx elm-esm make src/Main.elm --output="${OUTFILE}"
  if [ -f "${OUTFILE}" ]; then
    echo "Starting the compiler"
    node index.js
  fi

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
