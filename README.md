Linux scripts to ease running the Fortran II compiler for the IBM 704

All this is based on the work from rhobbie (https://github.com/rhobbie), but focusing on Fortran II "development"

- Sim704 emulator is used to run the compiler and generated binaries: https://github.com/rhobbie/Sim704
- Tools used to prepare, move cards, etc.: https://github.com/rhobbie/tool704
- Fortran II tape pre-compiled from the code: https://github.com/rhobbie/Mkf2


Requirements:
--------------
- The emulator and tools are Windows executables, so you will need wine to compile and run your programs
- They also use the .NET runtime, so you'll need to have it installed and configured under wine


Added features:
-----------------
- Fortran II tapes precompiled for an IBM 704 machine with 4K of core memory
- Single compiler script (f2.sh):
  - Transparent compilation of Fortran II programs with and without subroutines
  - Automatic "linking" of programs from different sources
  - Automatic sorting of output punched cards (i.e. transfer card)

Examples:
----------
- Compiling: ./f2.sh main.f square.f
- Running: ./run.sh output.cbn
