      module MOD_JSTART
      contains
      SUBROUTINE JSTART (NF,XLAMBDA,AKEY,ND,R,T,XJC,XJL,
     $                   HTOT,GTOT,XTOT,ETOT,EMFLUX,TOTIN,TOTOUT,
     $                   NCHARG,ELEVEL,EDDI,WCHARM,NOM,N,EINST,NDIM,  ! renamed WRCHARM to WCHARM 
     $                   MODHEAD,JOBNUM,TEFF)
C******************************************************************************
C***  CALLED BY WRSTART
C***  READ THE RADIATION FIELD
C***  XJC: CONTINUUM RADIATION FIELD
C***  XJL: LINE RADIATION FIELD
C******************************************************************************
! IF you change this file you have to change the following files, too:
!	readrad.for, writradc
      use MOD_WRITMS,only: WRITMS1,WRITMS
      use MOD_WRITMSI,only: WRITMSI1
      use MOD_BNUE,only:BNUE
      use MOD_ERROR,only:ERROR
      use MOD_FORMATS,only:FMT_KEY
      !IMPLICIT REAL*8(A-H,O-Z)
      IMPLICIT NONE
      real*8,PARAMETER ::  ONE = 1.D+0, TWO = 2.D+0 

C***  TRANSFER OF THE LTE-OPTION FROM SUBR. DECSTAR
      COMMON /COMLTE/ LTE
      real*8,  intent(inout),dimension(ND)  :: XJC,XJL ! Continuum and Line Radiation Field
      integer, intent(in   ) :: NF, ND, N, NDIM
      integer, intent(in   ) :: NCHARG(NDIM), NOM(N),JOBNUM
      real*8,  intent(in   ) :: TOTIN, TOTOUT
      real*8,  intent(in   ) :: ELEVEL(NDIM),EINST(NDIM,NDIM),EDDI(3,ND)
      real*8,  intent(in   ),dimension(ND)   :: R,T
      real*8,  intent(in   ),dimension(NF)   :: XLAMBDA,AKEY
      real*8,  intent(in   ),dimension(ND,NF):: WCHARM
      real*8,  intent(in   ),dimension(:)    :: HTOT, GTOT,XTOT, ETOT,EMFLUX
      character,intent(in  ) :: MODHEAD*104
      real*8  ::SQRT,XLAM, BTEFF, TEFF, W, ARG
      integer :: IFL,IERR, K, L, J, I,IND
      LOGICAL LTE
      CHARACTER CNAME*10
! micha: Added dimensions to be able to use modules
C***  CONTINUUM RADIATION FIELD XJC  *****************************************
C***  LOOP OVER ALL CONTINUUM FREQUENCY POINTS
C***  ( DEPTH VEKTOR AT EACH FREQUENCY POINT )
      IFL=2
      open (IFL,file='RADIOC',STATUS='UNKNOWN')
      write (ifl,'(A)')  'MODHEAD'
	write (ifl,'(A104)') MODHEAD 
c      CALL WRITMSC(IFL,MODHEAD,104,CNAME,-1,IERR)
      CALL WRITMSI1(IFL,JOBNUM,  'JOBNUM',-1,IERR)
      CALL WRITMSI1(IFL,NF,      'NF'    ,-1,IERR)
      CALL WRITMS1 (IFL,TOTIN,   'TOTIN' ,-1,IERR)
      CALL WRITMS1 (IFL,TOTOUT,  'TOTOUT',-1,IERR)
      CALL WRITMS (IFL,EMFLUX,NF,'EMFLUX',-1,IERR)
      CALL WRITMS (IFL,HTOT,ND,  'HTOT'  ,-1,IERR)
      CALL WRITMS (IFL,GTOT,ND,  'GTOT'  ,-1,IERR)
      CALL WRITMS (IFL,XTOT,ND,  'XTOT'  ,-1,IERR)
      CALL WRITMS (IFL,ETOT,ND,  'ETOT'  ,-1,IERR)

      DO 6 K=1,NF
      XLAM=XLAMBDA(K)
     
C***  BRANCH FOR LTE
      IF (LTE) THEN
        DO 2 L=1,ND
    2    XJC(L)=BNUE(XLAM,T(L))
      ELSE
C***   BRANCH FOR GEOMETRICAL DILUTION OF BLACKBODY FIELD
        BTEFF=BNUE(XLAM,TEFF)
        DO L=1,ND
          IF (T(L) .LT. TEFF) THEN
            W=0.5
            ARG=1.-1./R(L)/R(L)
            IF (ARG .GT. .0) W=0.5*(1.-SQRT(ARG))
            XJC(L)=BTEFF*W
          ELSE
            XJC(L)=BNUE(XLAM,T(L))
          ENDIF
        ENDDO
      ENDIF
     
      WRITE(CNAME,FMT_KEY) 'XJC ',K
      CALL WRITMS (IFL,XJC,ND,CNAME,-1,IERR)
      !***  EDDI IS A DUMMY-WRITE
      WRITE(CNAME,FMT_KEY) 'EDDI',K
      CALL WRITMS (IFL,EDDI,3*ND,CNAME,-1,IERR)
      WRITE(CNAME,FMT_KEY) 'WCHA',K
      CALL WRITMS (IFL,WCHARM(:,K),ND,CNAME,-1,IERR)
    6 CONTINUE
      close (IFL)
C******************************************************************************
     
C***  LINE RADIATION FIELD XJL  ***********************************************
C***  ( DEPTH VEKTOR FOR EACH LINE TRANSITION LABELLED WITH IND )
      IFL=4
      open (IFL,file='RADIOL',STATUS='UNKNOWN')

      CNAME='MODHEAD'
      write (ifl,'(A10)')  cname
      write (ifl,'(A104)') MODHEAD 
      CALL WRITMSI1(IFL,jobnum,'JOBNUM',-1,IERR)

      IND=0
      DO 99 J=2,N
      DO 99 I=1,J-1
      IF ((NOM(I) .NE. NOM(J)) .OR. (NCHARG(I) .NE. NCHARG(J))) GOTO 99
      IND=IND+1
      IF (EINST(I,J) .EQ. - TWO) GOTO 99
      XLAM=1.d8*ONE/(ELEVEL(J)-ELEVEL(I))
C***  THIS VERSION: SAME APPROXIMATION AS FOR CONTINUUM
C***  BRANCH FOR LTE

      IF (LTE) THEN
        DO L=1,ND
          XJL(L)=BNUE(XLAM,T(L))
        enddo
      ELSE
C***  BRANCH FOR GEOMETRICAL DILUTION OF BLACKBODY FIELD
        BTEFF=BNUE(XLAM,TEFF)
        DO L=1,ND
          IF (T(L) .LT. TEFF) THEN
            W=0.5_8
            ARG=ONE-ONE/R(L)/R(L)
            IF (ARG .GT. .0) W=0.5_8*(ONE-SQRT(ARG))
            XJL(L)=BTEFF*W
          ELSE
            XJL(L)=BNUE(XLAM,T(L))
          ENDIF
        ENDDO
      ENDIF
      WRITE(CNAME,FMT_KEY) 'XJL ',IND
      CALL WRITMS (IFL,XJL,ND,CNAME,-1,IERR)
   99 CONTINUE
      close (IFL)
C*****************************************************************************
      RETURN
      END subroutine
      end module
