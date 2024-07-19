#!/bin/bash
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.cutefishos.com/cutefishos.gpg -O- | sudo tee /etc/apt/keyrings/cutefishos.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/cutefishos.asc] https://packages.cutefishos.com/ stable main" | sudo tee -a /etc/apt/sources.list.d/cutefishos.list > /dev/null
