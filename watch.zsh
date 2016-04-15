#!/usr/bin/env zsh
autoload -U colors && colors
typeset -a processes

fork() {
  print $fg_no_bold[yellow]"$@"$reset_color
  $@ 1>/dev/null 2>&1 &
  processes+=$!
}

check() {
  print $fg_no_bold[green]"wait $processes"$reset_color
  wait $processes 2>/dev/null
  processes=()
}
