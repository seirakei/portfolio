#!/usr/bin/env bash

echo -e "[\x1b[32mInfo\x1b[0m]: Listening on port 8000"
echo -e "[\x1b[32mInfo\x1b[0m]: > http-server -p 8000"

http-server -p 8000 > /dev/null 2> /dev/null