shellescape() {
  for word in $@; do
    case "$word" in
      *' '*)
        case "$word" in '\-'*) word="\\$word" ;; esac
        word="'$word'"
        ;;
    esac
    print -n -- "$word "
  done
  print
}

print_eval() {
  print "\e[33m"
  shellescape $@
  print "\e[0m"
  $@
}

