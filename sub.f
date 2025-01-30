      I = 1
      PRINT 10, I
10    FORMAT(I2)
      CALL SUB(I)
      STOP
      END (2,2,2,2,2)

      SUBROUTINE SUB(I)
      I = 1
      RETURN
      END (2,2,2,2,2)
