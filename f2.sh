#!/bin/sh
set -e

# Check if the first parameter is provided
if [ -z "$1" ]; then
    echo "Error: No input file provided."
    exit 1
fi

# Check if the input file exists
if [ ! -f "$1" ]; then
    echo "Error: Input file '$1' does not exist."
    exit 1
fi

# Remove existing files if they exist
rm -f SourceDeck.cbn Punched.cbn LP.txt "${1%.*}.cbn"

# Punch the input file to create SourceDeck.cbn
wine tools/Punch.exe "$1" ibm704/SourceDeck.cbn

# Run the Fortran II compiler on the IBM 704 emulator
# Output is a set of cards on Punched.cbn
(cd ibm704 && wine Sim704.exe F2.xml)

# If PunchedObj.cbn exists, clean it and rename to match the input file's base name
if [ -f ibm704/PunchedObj.cbn ]; then
    wine tools/CleanDeck.exe ibm704/PunchedObj.cbn "${1%.*}.cbn"
fi

# Remove any remaining .drm files
rm -f ibm704/*.drm
