autoload -U colors && colors

black()   { print_color black   $@ }
blue()    { print_color blue    $@ }
cyan()    { print_color cyan    $@ }
green()   { print_color green   $@ }
magenta() { print_color magenta $@ }
red()     { print_color red     $@ }
white()   { print_color white   $@ }
yellow()  { print_color yellow  $@ }

print_color() {
  color=$1
  shift
  print "$fg_no_bold[$color]$@$reset_color"
}
