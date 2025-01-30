      PRINT 1
1     FORMAT(25H LOADING INPUT FROM CARD:)
C Read the input number (X) from a card
      READ 10, I
      J = I * I
C      CALL SQUARE(X, Y)
      PRINT 20, I, J
C Input format: Read a single integer (5 digits max)
10    FORMAT(I5)
C Output format: "RESULT: " followed by the integer
20    FORMAT(8H RESULT: , I5, I5)
      STOP
      END (2,2,2,2,2)

C Switch 6 must be down (true) to allow subroutines compiling
C      SUBROUTINE SQUARE(A, B)
C      B = A * A
C      RETURN
C      END (2,2,2,2,2)
