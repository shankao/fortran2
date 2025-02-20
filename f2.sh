#!/bin/sh
set -e

# Configuration file for "simple" jobs (no subroutines)
IBM704_CONFIG_SIMPLE="f2_simple.xml"
# Configuration file for jobs with subroutines
IBM704_CONFIG_SUBR="f2_subroutines.xml"

# 1) Check if the first parameter (input Fortran file) is provided
if [ -z "$1" ]; then
    echo "Error: No input file provided."
    echo "Usage: $0 <input.f>"
    exit 1
fi

# 2) Verify the input file actually exists
if [ ! -f "$1" ]; then
    echo "Error: Input file '$1' does not exist."
    exit 1
fi

# 3) Detect subroutine usage by searching for SUBROUTINE, FUNCTION, or CALL
#    (case-insensitive check for safety, but you can remove -i if not needed)
if grep -Ei 'SUBROUTINE|FUNCTION|CALL' "$1" >/dev/null 2>&1; then
    IBM704_CONFIG="$IBM704_CONFIG_SUBR"
    echo "Detected subroutine/function usage; using config: $IBM704_CONFIG"
else
    IBM704_CONFIG="$IBM704_CONFIG_SIMPLE"
    echo "No subroutine usage detected; using config: $IBM704_CONFIG"
fi

# 4) Remove existing output files if present
rm -f ibm704/SourceDeck.cbn ibm704/Punched.cbn ibm704/PunchedObj.cbn LP.txt \
      ibm704/*.drm "${1%.*}.cbn"

# 5) Punch the input file into a card-image deck (SourceDeck.cbn)
wine tools/Punch.exe "$1" ibm704/SourceDeck.cbn

# 6) Run the Fortran II compiler on the IBM 704 emulator
#    We assume you want to pass F2.xml and the chosen config, in that order.
#    (Adjust arguments as your emulator requires.)
(cd ibm704 && wine Sim704.exe "$IBM704_CONFIG")

# 7) If the compiler produced PunchedObj.cbn, clean it up and rename
if [ -f ibm704/PunchedObj.cbn ]; then
    wine tools/CleanDeck.exe ibm704/PunchedObj.cbn "${1%.*}.cbn"
fi

# 8) Remove any leftover .drm files if needed
rm -f ibm704/*.drm

echo "Compilation finished. Output deck: ${1%.*}.cbn"

