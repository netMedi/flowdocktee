#!/usr/bin/env bash

install_path=/usr/local/bin
script_dir=$( cd $(dirname $0); pwd -P )
cp "$script_dir/flowdocktee.sh" "$install_path/flowdocktee"
chmod +x "$install_path/flowdocktee"

echo "flowdocktee has been installed to $install_path"
