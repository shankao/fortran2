#!/bin/sh
set -e

wine tools/SplitDeck.exe main.cbn -1 main_stripped.cbn transfer.cbn

rm -f output.cbn
wine tools/CopyCards.exe main_stripped.cbn+square.cbn+transfer.cbn output.cbn

# Cleanup
rm -f main_stripped.cbn transfer.cbn
