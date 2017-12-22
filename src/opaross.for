      module MOD_OPAROSS

      contains

      SUBROUTINE OPAROSS(OPARL,EN,TL,RNEL,ENTOTL,RSTAR,N,
     $                   LEVEL,NCHARG,WEIGHT,ELEVEL,EION,EINST,
     $                   ALPHA,SEXPO,AGAUNT,NF,NFDIM,XLAMBDA,FWEIGHT,NOM,
     $                   WAVARR,SIGARR)

C***  CALLED BY GREYM
C***  COMPUTATION OF THE ROSSELAND MEAN OPACITY AT DEPTH POINT L
c***  AND FREQUENCY POINT K=1,NF
C***  FOR GIVEN POPNUMBERS

      use MOD_COOP

      IMPLICIT REAL*8(A - H, O - Z)

      real*8, dimension(NF, N) :: DUMMY2

      DIMENSION EINST(N, N)
      DIMENSION EN(N)
      DIMENSION NCHARG(N),WEIGHT(N),ELEVEL(N),EION(N),ALPHA(N),SEXPO(N)
      DIMENSION NOM(N)
      DIMENSION XLAMBDA(NF),FWEIGHT(NF)
      CHARACTER*10 LEVEL(N)

      character*8, dimension(N) :: AGAUNT

      real*8       :: OPA, ETA, THOMSON
      integer      :: IWARN
      character*10 :: MAINPRO, MAINLEV

	  DIMENSION WAVARR(N, NFDIM), SIGARR(N, NFDIM)

!     CONSTANTS :  C1 = H * C / K (DIMENSION ANGSTROEM * KELVIN)
!                  C2 = 2 * H * C
      DATA C1, C2 /1.4388E8, 3.9724E+8/

!     STEBOL = STEFAN-BOLTZMANN CONSTANT / PI (ERG/CM**2/S/STERAD/KELVIN**4)
      DATA STEBOL /1.8046E-5/
     
!     FREQUENCY INTEGRATION
      SUM = 0.0

      DO 1 K = 1, NF

      XLAM = XLAMBDA(K)

      CALL COOP_OPAROSS(XLAM,TL,RNEL,EN,ENTOTL,RSTAR,OPA,ETA,
     $                  THOMSON,IWARN,MAINPRO,MAINLEV,NOM,N,LEVEL,NCHARG,WEIGHT,
     $                  ELEVEL,EION,EINST,ALPHA,SEXPO,AGAUNT,0,DUMMY2,
     $                  WAVARR,SIGARR,NF,NFDIM)

C***  DERIVATIVE OF THE PLANCK FUNCTION WITH RESPECT TO T
C***  FOR SMALL VALUES OF TL (I.E. FOR LARGE VALUES OF RMAX IN CASE OF A
C***  SPHERICAL TEMPERATURE STRUCTURE): PREVENTION OF AR004 (BAD SCALAR
C***  ARGUMENT TO ARLIB MATH ROUTINE)

      HNUEKT=C1/XLAM/TL

      IF (HNUEKT .GT. 5000.) THEN

          DBDT=C1*C2/XLAM/XLAM/XLAM/XLAM/TL/TL

      ELSE

          EXFAC=EXP(HNUEKT)

          DBDT=C1*C2/XLAM/XLAM/XLAM/XLAM/TL/TL/(EXFAC+1./EXFAC-2.)

      ENDIF

      SUM=SUM+DBDT*FWEIGHT(K)/OPA

    1 CONTINUE

      OPARL=4.*STEBOL*TL*TL*TL/SUM

      return

      end subroutine

      end module