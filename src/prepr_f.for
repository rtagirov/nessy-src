      module MOD_PREPR_F

      contains

      SUBROUTINE PREPR_F(Z,P,ND,NP,JP,LTOT,LMAX,W,CORE,VDU,R,
     $                   IRIND,IBACK,RRAY,ZRAY,XCMF,NDADDIM)

C***  DEFINING WHOLE RAYS INCLUDING THE BACKWARD HALF-SPHERE

      implicit real*8(a-h,o-z)
     
      DIMENSION ZRAY(NDADDIM),XCMF(NDADDIM),RRAY(NDADDIM)
      DIMENSION VDU(ND),R(ND)
      DIMENSION Z(ND),P(NP)
      INTEGER   IRIND(NDADDIM)
      INTEGER   IBACK(ND,NP)
      LOGICAL   CORE
    
      LMAX=MIN0(NP+1-JP,ND)
      CORE=LMAX.EQ.ND
      LTOT=2*LMAX-1
      IF (CORE) LTOT=LMAX*2-1
     
c*** front side - blue velocities ==> negative XCMF
c                                 ==> positive Z
      DO 1 L=1,LMAX
      VRAD=VDU(L)
      zl = sqrt((r(l) - p(jp)) * (r(l) + p(jp)))
      XCMF(L)= -VRAD*ZL/R(L)
      RRAY(L)=R(L)
      ZRAY(L)=Z(L)
      IRIND(L)=L
    1 CONTINUE
     
c*** rear side - red velocities ==> positive velocities
      DO 12 L=1,LMAX
      LL=2*LMAX-L
      VRAD=VDU(L)
      zl = sqrt((r(l) - p(jp)) * (r(l) + p(jp)))
      XCMF(LL)= +VRAD*ZL/R(L)
      RRAY(LL)=R(L)
      ZRAY(LL)=-Z(L)
      IRIND(LL)=L
      IBACK(L,JP)=LL
   12 CONTINUE
   
   11 CONTINUE
     
C***  W = WEIGHTS FOR THE FLUX INTEGRAL
      IF (JP.EQ.1) W=P(2)*P(2)/3.d0
      IF (JP.NE.1) W=(P(JP-1)+P(JP)+P(JP+1))*(P(JP+1)-P(JP-1))/3.d0
      RETURN
      END subroutine
      end module
