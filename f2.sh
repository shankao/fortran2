#!/bin/sh
set -e

##############################################################################
# Config files for IBM 704 Fortran II:
#   - f2_simple.xml:   Minimal config (no subroutines).
#   - f2_subroutines.xml: Enhanced config for calls/SUBROUTINE/FUNCTION usage.
##############################################################################
IBM704_CONFIG_SIMPLE="f2_simple.xml"
IBM704_CONFIG_SUBR="f2_subroutines.xml"

# Check that we have at least one source file.
if [ $# -lt 1 ]; then
  echo "Usage: $0 <main.for> [subr1.for] [subr2.for] ..."
  exit 1
fi

##############################################################################
# 1) DETECT SUBROUTINE USAGE
#    If *any* file contains 'SUBROUTINE', 'FUNCTION', or 'CALL' (case-insensitive),
#    we'll choose the "subroutines" config.
##############################################################################
NEEDS_SUBR=0
for SRC in "$@"; do
  if grep -Eiq 'SUBROUTINE|FUNCTION|CALL' "$SRC" 2>/dev/null; then
    NEEDS_SUBR=1
    break
  fi
done

if [ $NEEDS_SUBR -eq 1 ]; then
  IBM704_CONFIG="$IBM704_CONFIG_SUBR"
  echo "[INFO] Detected subroutine usage -> Using config: $IBM704_CONFIG"
else
  IBM704_CONFIG="$IBM704_CONFIG_SIMPLE"
  echo "[INFO] No subroutine usage found -> Using config: $IBM704_CONFIG"
fi

##############################################################################
# 2) COMPILE EACH SOURCE FILE INDIVIDUALLY
#    - For each .for file:
#         1) Punch it into ibm704/SourceDeck.cbn
#         2) Run the compiler (Sim704 + chosen config)
#         3) The compiler outputs PunchedObj.cbn -> rename to <basename>.cbn
##############################################################################
OBJDECKS=""
INDEX=1
for SRC in "$@"; do
  if [ ! -f "$SRC" ]; then
    echo "Error: file '$SRC' not found."
    exit 1
  fi

  # Derive an .cbn name from the source file name
  BASENAME="${SRC%.*}"
  OBJDECK="${BASENAME}.cbn"

  echo "[INFO] Compiling '$SRC' -> '$OBJDECK'"

  # Clean up old decks
  rm -f ibm704/SourceDeck.cbn ibm704/Punched.cbn ibm704/PunchedObj.cbn ibm704/*.drm

  # Punch the source into "SourceDeck.cbn" for the emulator
  wine tools/Punch.exe "$SRC" ibm704/SourceDeck.cbn

  # Invoke the IBM 704 Fortran II compiler + whichever config
  (
    cd ibm704
    wine Sim704.exe "$IBM704_CONFIG"
  )

  # If compilation succeeded, we should have PunchedObj.cbn
  if [ -f ibm704/PunchedObj.cbn ]; then
    wine tools/CleanDeck.exe ibm704/PunchedObj.cbn "$OBJDECK"
    OBJDECKS="$OBJDECKS $OBJDECK"
  else
    echo "[WARN] No PunchedObj.cbn produced for $SRC"
  fi

  INDEX=$((INDEX + 1))
done

# Display the compiled object decks we have so far
echo "[INFO] Compiled object decks: $OBJDECKS"

##############################################################################
# 3) IF NO SUBROUTINES, WE'RE DONE
#    You end up with one or more .cbn "object decks." If you *really* want
#    to combine them anyway, you can do so, but typically you only needed a
#    single main deck if there's no subroutine usage.
##############################################################################
if [ $NEEDS_SUBR -eq 0 ]; then
  echo "[INFO] Subroutines not used, so no link step required."
  echo "      Each file produced its own .cbn: $OBJDECKS"
  echo "[DONE] Exiting."
  exit 0
fi

##############################################################################
# 4) LINK STEP (IF SUBROUTINES ARE USED)
#    We'll treat the FIRST object deck in OBJDECKS as the "main" deck (which
#    should contain the final TRANSFER card). We'll do the standard approach:
#    - Split off the last card (transfer.cbn) from the main deck
#    - Append all subsequent object decks
#    - Re-append transfer.cbn at the end
#    - Write the result to "output.cbn"
#
#    You can adapt the naming to suit your workflow.
##############################################################################
MAINOBJ=$(echo "$OBJDECKS" | awk '{print $1}')   # First item
OTHERS=$(echo "$OBJDECKS" | cut -d ' ' -f2-)

if [ -z "$MAINOBJ" ]; then
  echo "[ERROR] No main object deck found? Something went wrong."
  exit 1
fi

echo "[INFO] Linking subroutines with main deck '$MAINOBJ'"

rm -f main_stripped.cbn transfer.cbn output.cbn

# (A) Split MAINOBJ into "all but last card" and "the last card (transfer)"
wine tools/SplitDeck.exe "$MAINOBJ" -1 main_stripped.cbn transfer.cbn

# (B) Build up a chain starting with main_stripped, then the other decks
CARDCHAIN="main_stripped.cbn"
for deck in $OTHERS; do
  if [ "$deck" != "$MAINOBJ" ]; then
    CARDCHAIN="$CARDCHAIN+$deck"
  fi
done

# (C) Finally re-append the transfer card
CARDCHAIN="$CARDCHAIN+transfer.cbn"

# (D) Merge everything into "output.cbn"
wine tools/CopyCards.exe "$CARDCHAIN" output.cbn

echo "[INFO] Final linked deck with subroutines: output.cbn"

# (E) Clean up
rm -f main_stripped.cbn transfer.cbn

echo "[DONE] All steps complete. Use 'output.cbn' to run your program."

