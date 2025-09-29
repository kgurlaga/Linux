#!/bin/bash
echo "Moje procesy:"
ps -u $USER
echo "---------------------------"
echo "Najwięcej RAM:"
ps -eo pid,comm,%mem --sort=-%mem | head -5
echo "---------------------------"
echo "Najwięcej CPU:"
ps -eo pid,comm,%cpu --sort=-%cpu | head -5
