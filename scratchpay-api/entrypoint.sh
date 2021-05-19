#!/usr/bin/env sh

run_start_command() {
  npm run migrate
  npm run start
}

main() {
  run_start_command
}

main "$@"