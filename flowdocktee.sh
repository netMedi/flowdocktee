#!/usr/bin/env bash
api_token=""
flow=""
organization=""
url="https://"$api_token"@api.flowdock.com/flows/"$organization"/"$flow"/messages"
me=$(basename "$0")
textWrapper="\`\`\`"

function escape_string() {
  local result=$(echo "$1" \
    | sed 's/\\/\\\\/g' \
    | sed 's/"/\\"/g' \
    | sed "s/'/\\'/g")
  echo "$result"
}

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

  if [[ $api_token == "" ]]; then
    err_exit 1 "Pleace specify api_token"
  fi

  if [[ $flow == "" ]]; then
    err_exit 1 "Pleace specify flow"
  fi

  if [[ $organization == "" ]]; then
    err_exit 1 "Pleace specify organization"
  fi
}

function process_line() {
  echo "$1"
  line=$(escape_string "$1")
  if [[ -z "$text" ]]; then
    text="$line"
  else
    text="$text\n$line"
  fi
}

function send_message() {
  message="$textWrapper\n$1\n$textWrapper"
  json="{\
    \"event\": \"message\", \
    \"content\": \"$message\" \
  }"
  post_result=$(curl \
    -H "Content-Type: application/json" \
    -X POST \
    -d "$json" "$url" 2> /dev/null)
  if [[ $? != "0" ]]; then
    err_exit 1 "$post_result"
  fi
}

function main() {
  parse_arguments "$@"
  check_configuration

  text=""
  while IFS='' read -r line; do
    process_line "$line"
  done
  send_message "$text"
}

main "$@"
