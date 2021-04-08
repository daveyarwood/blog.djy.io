#!/usr/bin/env bash

read -r -p "What is your name? " name
read -r -p "What is your quest? " quest
read -r -p "What is your favorite color? " fav_color

echo "name: $name"
echo "quest: $quest"
echo "favorite color: $fav_color"

read -r -p "What is the capital of Assyria? "
echo "$REPLY"
