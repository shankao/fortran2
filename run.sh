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

cp "$1" ibm704/PunchedInput.cbn

# Check if the second parameter is provided and overwrite with combined input
if [ ! -z "$2" ]; then
	wine tools/Punch.exe "$2" ibm704/InputData.cbn
	wine tools/CopyCards.exe "$1"+ibm704/InputData.cbn ibm704/PunchedInput.cbn
	rm ibm704/InputData.cbn
fi 

# Run the object on the cards on the IBM 704 emulator
(cd ibm704 && wine Sim704.exe Run.xml)
