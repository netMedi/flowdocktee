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

function parse_arguments() {
  while [[ $# -gt 0 ]]; do
    opt=$1
    shift
    case "$opt" in
      --config)
        CONFIG=$1
        shift
        ;;
    esac
  done
}

function read_and_pipe_line() {
  echo "$1"
  line=$(escape_string "$1")
  if [[ -z "$text" ]]; then
    text="$line"
  else
    text="$text\n$line"
  fi
}

function send() {
  message="$textWrapper\n$1\n$textWrapper"
  json="{\
    \"event\": \"message\", \
    \"content\": \"$message\" \
  }"
  curl \
    -H "Content-Type: application/json" \
    -X POST \
    -d "$json" "$url" > /dev/null 2>&1
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
  set_url

  text=""
  while IFS='' read -r line; do
    read_and_pipe_line "$line"
  done
  send "$text"
}

main "$@"
