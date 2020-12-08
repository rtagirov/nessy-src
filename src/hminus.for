      program hminus

      use MOD_WRSTART
      use MOD_STEAL
      use MOD_WRCONT
      use MOD_COMO
      use MOD_ETL
      use MOD_TICTOC

      use auxhminus
      use common_block
      use file_operations
!      use varhminus

      implicit none

      integer itemp
      integer itsw
      integer lblaon, inew, ipmax, nbmax
      integer timer,timer2
      integer nbinw
      real*8  almin, almax

      real*8 :: cycle_start, cycle_finish

      COMMON /LIBLPAR/ ALMIN, ALMAX, LBLAON, IPMAX, NBMAX, NBINW

      character*7 :: JOB

      LOGICAL :: VEL_FIELD_FILE_EXISTS

      real*8, allocatable, dimension(:, :)    :: xjcind
      real*8, allocatable, dimension(:, :, :) :: U2

      LTE_RUN =             .FALSE.
      VEL_FIELD_FROM_FILE = .FALSE.

      INQUIRE(FILE = VEL_FIELD_FILE, EXIST = VEL_FIELD_FILE_EXISTS)

      IF (VEL_FIELD_FILE_EXISTS) THEN 

         VEL_FIELD_FROM_FILE = .TRUE.

         WRITE(*, '(A,1x,A,A,/)') 'Attention: the velocity field will be taken from the file', VEL_FIELD_FILE, '!'

      ENDIF

      itsw=0
      itemp=0
      ALMIN=0.    !***  default values for lineblanketing
      ALMAX=0.
      LBLAON=0

      call TIC(timer)
      call TIC()

  100 CONTINUE

      REWIND 99; READ (99,'(A7)') JOB

      WRITE(*, '(A,A)') 'JOB = ', JOB

      SELECTCASE(JOB)

        CASE('tmpcor');            GOTO 1
        CASE('wrcont');            GOTO 1
        CASE('repeat', 'newline'); GOTO 10
        CASE('wrstart');           CONTINUE
        CASE('lte')

             CALL HMINUS_LTE(); STOP

      CASE DEFAULT

          PRINT *,' OPTION NOT KNOWN; JOB=',JOB
          REWIND 99; WRITE (99,'(A4)') 'abort'
          PRINT *,' Elapsed time for total wind-job:',toc(timer),' sec'
          STOP 'ABORT'

      ENDSELECT

      CALL SYSTEM("echo '\n'START OF THE RUN - $(date)'\n'")

      CALL SYSTEM("echo DIRECTORY: $(pwd)'\n'")

      CALL tic(timer2)

      call rm_file('BROYDEN',          '-vf')
      call rm_file('NEWBROYDEN',       '-vf')

      call rm_file('wall_time.etl',    '-vf')
      call rm_file('wall_time.como',   '-vf')
      call rm_file('wall_time.steal',  '-vf')
      call rm_file('wall_time.linpop', '-vf')
      call rm_file('wall_time.cycle',  '-vf')
      call rm_file('wall_time.wrcont', '-vf')

      call rm_file('cpu_time.etl',     '-vf')
      call rm_file('cpu_time.como',    '-vf')
      call rm_file('cpu_time.steal',   '-vf')
      call rm_file('cpu_time.linpop',  '-vf')
      call rm_file('cpu_time.cycle',   '-vf')
      call rm_file('cpu_time.wrcont',  '-vf')

      call rm_file('linop.out', '-vf')
      call rm_file('conv.out',  '-vf')
!      call rm_file('inine.out', '-vf')

      CALL WRSTART; call finish('WRSTART', timer2, .true.)

      CALL STEAL(JOB); call finish('STEAL', timer2)

      IF (JOB.NE.'wrcont') THEN
        PRINT *,'HMINUS: NO NEW JOB TO BE ROUTED; JOB=',JOB
        REWIND 99
        WRITE (99,'(A4)') 'exit'

        print *,' Elapsed time for total wind-job:',toc(timer),' sec'
        STOP 'EXIT'
      ENDIF

    1 continue

      call tic(timer2)

      CALL WRCONT(JOB)

      itemp = itemp + 1

      if (itemp .ge. 2) itsw = 1

      call finish('WRCONT',timer2)

      IF (JOB.NE.'repeat'.AND.JOB.NE.'newline') THEN
         PRINT *,' NO NEW JOB TO BE ROUTED; JOB=',JOB
         REWIND 99
         WRITE (99,'(A4)') 'exit'
         print *,'HMINUS: Elapsed time for total wind-job:', toc(timer), ' sec'
         STOP 'EXIT'
      ENDIF

   10 continue

      IF (JOB .eq. 'newline') INEW = 1

      if (itsw .eq. 1) itsw = 0

      print*, 'HMINUS: CYCLE STARTED'

      call cpu_time(cycle_start)

!      call system("echo -n $(date +%s) >> wall_time.cycle")

      call tic(timer2)

      CALL COMO;       call finish('COMO',  timer2)

      CALL ETL(JOB, U2, xjcind);   call finish('ETL',   timer2)

!      print*, 'xjcind'
!      print*, xjcind

      CALL STEAL(JOB); call finish('STEAL', timer2)

!      call system("echo ' '$(date +%s) >> wall_time.cycle")

      call cpu_time(cycle_finish)

      print*, 'HMINUS: TIME USED FOR CYCLE: '//writeTOC(timer2)

!      call open_to_append(231, 'cpu_time.cycle'); write(231, '(F6.3)') cycle_finish - cycle_start; close(231)

      IF (INEW .EQ. 1) THEN

         print*, 'HMINUS: TIME FOR CYCLE INCLUDING LINE BACKGROUND '//
     &           'RADIATION FIELD, JOB = '//JOB
        INEW = 0

      ENDIF

      selectcase(JOB)

        case('wrcont','extrap') ; goto 1;
        case('repeat')          ; goto 10;

      endselect
      
      call WRCONT(JOB); call finish('WRCONT', timer2)

      PRINT*, 'HMINUS: NO NEW JOB TO BE ROUTED; JOB = ', JOB

      REWIND 99; WRITE (99,'(A4)') 'exit'

      print*,'HMINUS: Elapsed time for total job: '//writeTOC(timer)

      CALL SYSTEM("echo '\n'END OF THE RUN - $(date)'\n'")

      end program
