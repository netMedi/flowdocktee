#!/usr/bin/env bash
token=""
org=""
flow=""
url="https://"$token"@api.flowdock.com/flows/"$org"/"$flow"/messages"
me=$(basename "$0")

function err_exit() {
  exit_code=$1
  shift
  echo "$me: $@" > /dev/null >&2
  exit $exit_code
}

function parse_arguments() {
  while [[ $# -gt 0 ]]; do
    opt=$1
    shift
    case "$opt" in
      *)
        err_exit 1 "illegal option $opt"
    esac
  done
}

function check_configuration() {
  if [[ -z $(command -v curl) ]]; then
    err_exit 1 "curl is not installed. Please install it first"
  fi
}

function process_line() {
  echo "$1"
  line="$1"
  text="$line"
}

function send_message() {
  message="$1"
  json="{\
    \"event\": \"message\", \
    \"content\": \"$message\" \
  }"
  post_result=$(curl -H "Content-Type: application/json" -X POST -d \
    "$json" "$url" 2> /dev/null)
  if [[ $? != "0" ]]; then
    err_exit 1 "$post_result"
  fi
}

function main() {
  parse_arguments "$@"
  check_configuration
  trap cleanup SIGINT SIGTERM SIGKILL

  text=""
  while IFS='' read -r line; do
    process_line "$line"
  done
  send_message "$text"
}

main "$@"
