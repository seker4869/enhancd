#!/bin/bash

filter() { :; }

LF=$(printf '\\\012_')
LF=${LF%_}
true=0
false=1
dummy="aaa
bbb
ccc
aaa
bbb"
dummy_log="/home/lisa
/home/lisa/work/zsh
/home/lisa/.zsh
/home/lisa/test
/home/lisa/text
"

json='{
    "options": [
        {
            "short": "-h",
            "long": "--help",
            "description": "desc",
            "action": "pwd"
        },
        {
            "short": "-v",
            "long": "--version",
            "description": "desc",
            "action": "pwd"
        }
    ]
}'

# Load enhancd
. ./init.sh || exit 1

T_SUB "__enhancd::load()" ((
  # skip
))

T_SUB "__enhancd::get_abspath()" ((
  expect="too few arguments"
  actual="$(__enhancd::get_abspath arg1 2>&1)"
  t_is "$expect" "$actual"

  expect="/home/lisa/work"
  actual="$(__enhancd::get_abspath /home/lisa/work/abc abc)"
  t_is "$expect" "$actual"

  expect="/home/lisa/work"
  actual="$(__enhancd::get_abspath /home/lisa/work/abc work)"
  t_is "$expect" "$actual"
))

T_SUB "__enhancd::split_path()" ((
  expect="/${LF}home${LF}lisa"
  actual="$(__enhancd::split_path /home/lisa/work)"
  t_is "$expect" "$actual"
))

T_SUB "__enhancd::get_dirstep()" ((
  expect="/home/lisa${LF}/home${LF}/"
  actual="$(__enhancd::get_dirstep /home/lisa/work)"
  t_is "$expect" "$actual"
))

T_SUB "__enhancd::get_dirname()" ((
  # Basically, the same as __enhancd::split_path
  expect="/${LF}home${LF}lisa"
  actual="$(__enhancd::get_dirname /home/lisa/work)"
  t_is "$expect" "$actual"

  expect="1: /${LF}2: home${LF}3: lisa${LF}4: lisa"
  actual="$(__enhancd::get_dirname /home/lisa/lisa/work)"
  t_is "$expect" "$actual"

  expect="/${LF}home${LF}lisa"
  actual="$(__enhancd::get_dirname /home/lisa/work)"
  t_is "$expect" "$actual"
))

T_SUB "__enhancd::list()" ((
  enhancd_dirs=( $dummy $PWD )

  expect="bbb${LF}aaa${LF}ccc"
  actual="$(__enhancd::list)"
  t_is "$expect" "$actual"

  expect="$HOME${LF}bbb${LF}aaa${LF}ccc"
  actual="$(__enhancd::list --home)"
  t_is "$expect" "$actual"

  enhancd_dirs=( "text" "test" "tax" )
  expect="test${LF}text"
  actual="$(__enhancd::list --narrow 'test')"
  t_is "$expect" "$actual"
))

T_SUB "__enhancd::narrow()" ((
  expect="/home/lisa${LF}/home/lisa/work/zsh${LF}/home/lisa/.zsh${LF}/home/lisa/test${LF}/home/lisa/text"
  actual="$(echo "$dummy_log" | __enhancd::narrow)"
  t_is "$expect" "$actual"

  expect="/home/lisa/work/zsh${LF}/home/lisa/.zsh"
  actual="$(echo "$dummy_log" | __enhancd::narrow 'zsh')"
  t_is "$expect" "$actual"

  expect="/home/lisa/test${LF}/home/lisa/text"
  actual="$(echo "$dummy_log" | __enhancd::narrow 'tent')"
  t_is "$expect" "$actual"
))

T_SUB "__enhancd::sync()" ((
  # skip
))

T_SUB "__enhancd::options()" ((
  echo "$json" >"$ENHANCD_ROOT/custom.json"
  expect="$PWD"
  actual="$(__enhancd::options '-h')"
  t_is "$expect" "$actual"

  git checkout "$ENHANCD_ROOT/custom.json" &>/dev/null
))

T_SUB "__enhancd::filter()" ((
  export ENHANCD_FILTER="head -1"
  expect="aaa"
  actual="$(__enhancd::filter "$dummy")"
  t_is "$expect" "$actual"

  export ENHANCD_FILTER="head -2 | tail -1"
  expect="bbb"
  actual="$(__enhancd::filter "$dummy")"
  t_is "$expect" "$actual"
))

T_SUB "__enhancd::cd()" ((
  # skip
))
