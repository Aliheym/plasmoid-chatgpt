#!/bin/bash

git clone https://github.com/Aliheym/plasmoid-chatgpt.git ~/tmp/plasma-chatgpt && plasmapkg2 --install ~/tmp/plasma-chatgpt/package

if [ $? -eq 0 ]; then
  echo "ChatGPT plasmoid installed successfully"
fi
