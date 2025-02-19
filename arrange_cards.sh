#!/bin/sh
set -e

# Check at least one argument (the main deck)
if [ $# -lt 1 ]; then
  echo "Usage: $0 main.cbn [extra1.cbn] [extra2.cbn] ..."
  exit 1
fi

MAIN="$1"      # The first file is the main deck
shift          # Everything else is additional decks

# 1) Split the main deck into "all but last card" + "last card (transfer.cbn)"
wine tools/SplitDeck.exe "$MAIN" -1 main_stripped.cbn transfer.cbn

# 2) Build up a chain of decks to copy in order
CARDCHAIN="main_stripped.cbn"

# 3) Append each extra deck one by one
for f in "$@"; do
  CARDCHAIN="$CARDCHAIN+$f"
done

# 4) Finally add the transfer card at the bottom
CARDCHAIN="$CARDCHAIN+transfer.cbn"

# 5) Merge them all into output.cbn
wine tools/CopyCards.exe "$CARDCHAIN" output.cbn

# 6) Clean up
rm -f main_stripped.cbn transfer.cbn
