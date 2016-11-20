      module MOD_FUNSCH
      contains
C**********  MODULNAME: FUNSCH    ******* 24/03/87  21.09.28.******    12 KARTEN
      FUNCTION FUNSCH (X)
      use MOD_ERF_INF
C***  THIS FUNCTION IS USED TO ESTIMATE THE SCHARMER LINE CORES IN THE
C***  BOUNDARY ZONES
C***  --  USED AS FORMAL PARAMETER FOR "REGULA"
C***  REGULA IS CALLED BY SUBROUTINE "COFREQ"
C***   COMMON / COMFUN / IS ALSO DEFINED IN CORFREQ

      implicit real*8(a-h,o-z)

      COMMON / COMFUN / DELTAV,XMIN

      XA=DMAX1(X-DELTAV,XMIN)
      FUNSCH=ERF_INF(X)-ERF_INF(XA)
      RETURN
      END function
      end module