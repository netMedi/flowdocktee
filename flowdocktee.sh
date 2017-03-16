#!/usr/bin/env bash
api_token=""
flow=""
organization=""
textWrapper="\`\`\`"

function escape_string() {
  local result=$(echo "$1" \
    | sed 's/\\/\\\\/g' \
    | sed 's/"/\\"/g' \
    | sed "s/'/\\'/g")
  echo "$result"
}

function error() {
  exit_code=$1
  shift
  echo "flowdocktee: $@" > /dev/null >&2
  exit $exit_code
}

function parse_arguments() {
  while [[ $# -gt 0 ]]; do
    opt=$1
    shift
    case "$opt" in
      --config)
        CONFIG=$1
        shift
        ;;
      *)
        error 1 "illegal option $opt"
    esac
  done
}

function check_configuration() {
  if [[ -z $(command -v curl) ]]; then
    error 1 "curl is not installed. Please install it first"
  fi

  if [[ $api_token == "" ]]; then
    error 1 "Pleace specify api_token"
  fi

  if [[ $flow == "" ]]; then
    error 1 "Pleace specify flow"
  fi

  if [[ $organization == "" ]]; then
    error 1 "Pleace specify organization"
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
    error 1 "$post_result"
  fi
}

function set_environment() {
  if [[ -n "$HOME" && -e "$HOME/.flowdocktee" ]]; then
    . "$HOME/.flowdocktee"
  fi
  if [[ -e "$CONFIG" ]]; then
    . $CONFIG
  fi
}

function set_url() {
  url="https://"$api_token"@api.flowdock.com/flows/"$organization"/"$flow"/messages"
}

function main() {
  parse_arguments "$@"
  set_environment
  check_configuration
  set_url

  text=""
  while IFS='' read -r line; do
    process_line "$line"
  done
  send_message "$text"
}

main "$@"
