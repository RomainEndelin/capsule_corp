/* config.h.  Generated from config.h.in by configure.  */

#include "parms.h"

/* are we using gcc */
#define HAVE_GCC 1

/* should we use gcc threaded code (i.e. goto *adrs) */
#define USE_THREADED_CODE 1

/* Should we use lib readline ? 	*/
/* #undef HAVE_LIBREADLINE */

/* Should we use lib readline ? 	*/
/* #undef HAVE_LIBSOCKET */
/* #undef HAVE_LIBNSL */

/* Should we use gmp ? 	*/
#define HAVE_LIBGMP 1

/* What MPI libraries are there? */
#define HAVE_LIBMPI 0
#define HAVE_LIBMPICH 0

/* Should we use MPI ? */
#if HAVE_LIBMPI || HAVE_LIBMPICH
#define HAVE_MPI 1
#else
#define HAVE_MPI 0
#endif

/* Is there an MPE library? */
#define HAVE_LIBMPE 0

/* Should we use MPE ? */
#if HAVE_LIBMPE &&  HAVE_MPI
#define HAVE_MPE 1
#else
#define HAVE_MPE 0
#endif

/* does the compiler support inline ? */
/* #undef inline */

/* Do we have Ansi headers ?		*/
/* #undef STDC_HEADERS */

/* Host Name ?				*/
#define HOST_ALIAS "i686-pc-mingw32"

/* #undef SUPPORT_CONDOR */
/* #undef SUPPORT_THREADS */
/* #undef USE_PTHREAD_LOCKING */

/* #undef HAVE_SYS_WAIT_H */
#define NO_UNION_WAIT 1

/* #undef HAVE_ALLOCA_H */
/* #undef HAVE_ARPA_INET_H */
#define HAVE_CTYPE_H 1
/* #undef HAVE_CRYPT_H */
/* #undef HAVE_CUDD_H */
#define HAVE_DIRECT_H 1
#define HAVE_DIRENT_H 1
/* #undef HAVE_DLFCN_H */
#define HAVE_ERRNO_H 1
/* #undef HAVE_EXECINFO_H */
#define HAVE_FCNTL_H 1
#define HAVE_FENV_H 1
#define HAVE_FLOAT_H 1
/* #undef HAVE_FPU_CONTROL_H */
#define HAVE_GMP_H 1
/* #undef HAVE_IEEEFP_H */
#define HAVE_IO_H 1
#define HAVE_LIMITS_H 1
#define HAVE_LOCALE_H 1
/* #undef HAVE_MACH_O_DYLD_H */
#define HAVE_MALLOC_H 1
#define HAVE_MATH_H 1
#define HAVE_MEMORY_H 1
/* #undef HAVE_MPE_H */
/* #undef HAVE_MPI_H */
/* #undef HAVE_NETDB_H */
/* #undef HAVE_NETINET_IN_H */
/* #undef HAVE_NETINET_TCP_H */
/* #undef HAVE_PTHREAD_H */
/* #undef HAVE_PWD_H */
/* #undef HAVE_READLINE_READLINE_H */
/* #undef HAVE_REGEX_H */
/* #undef HAVE_SIGINFO_H */
#define HAVE_SIGNAL_H 1
#define HAVE_STDARG_H 1
#define HAVE_STRING_H 1
/* #undef HAVE_STROPTS_H */
/* #undef HAVE_SYS_CONF_H */
/* #undef HAVE_SYS_DIR_H */
#define HAVE_SYS_FILE_H 1
/* #undef HAVE_SYS_MMAN_H */
/* #undef HAVE_SYS_NDIR_H */
#define HAVE_SYS_PARAM_H 1
/* #undef HAVE_SYS_RESOURCE_H */
/* #undef HAVE_SYS_SELECT_H */
/* #undef HAVE_SYS_SHM_H */
/* #undef HAVE_SYS_SOCKET_H */
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TIME_H 1
/* #undef HAVE_SYS_TIMES_H */
#define HAVE_SYS_TYPES_H 1
/* #undef HAVE_SYS_UCONTEXT_H */
/* #undef HAVE_SYS_UN_H */
/* #undef HAVE_SYS_WAIT_H */
#define HAVE_TIME_H 1
#define HAVE_UNISTD_H 1
#define HAVE_UTIME_H 1
#define HAVE_WCTYPE_H 1
#define HAVE_WINSOCK_H 1
#define HAVE_WINSOCK2_H 1

#if __MINGW32__
#define __WINDOWS__ 1
#endif

/* Do we have restartable syscalls */
/* #undef HAVE_RESTARTABLE_SYSCALLS */

/* is 'tms' defined in <sys/time.h> ? */
/* #undef TM_IN_SYS_TIME */

/* define type of prt returned by malloc: char or void */
#define MALLOC_T void *

/* Define byte order			*/
/* #undef WORDS_BIGENDIAN */

/* Define sizes of some basic types	*/
#define SIZEOF_INT_P 4
#define SIZEOF_INT 4
#define SIZEOF_SHORT_INT 2
#define SIZEOF_LONG_INT 4
#define SIZEOF_LONG_LONG_INT 8
#define SIZEOF_FLOAT 4
#define SIZEOF_DOUBLE 8

/* Define representation of floats      */
/* only one of the following shoud be set */
/* to add a new representation you must edit FloatOfTerm and MkFloatTerm
  in adtdefs.c
*/
#define FFIEEE 1
/*manual */
/* #undef FFVAX */

/* Define the standard type of a float argument to a function */
/*manual */
#define  FAFloat double	

/* Set the minimum and default heap, trail and stack size */
#define MinTrailSpace ( 48*SIZEOF_INT_P)
#define MinStackSpace (300*SIZEOF_INT_P)
#define MinHeapSpace (1000*SIZEOF_INT_P)

#define DefTrailSpace 0
#define DefStackSpace 0
#define DefHeapSpace 0


/* Define return type for signal	*/
#define RETSIGTYPE void

/* #undef HAVE__NSGETENVIRON */
#define HAVE_ACCESS 1
#define HAVE_ACOSH 1
/* #undef HAVE_ALARM */
/* #undef HAVE_ALLOCA */
#define HAVE_ASINH 1
#define HAVE_ATANH 1
#define HAVE_CHDIR 1
#define HAVE_CTIME 1
/* #undef HAVE_DLOPEN */
#define HAVE_DUP2 1
#define HAVE_ERF 1
#define HAVE_FECLEAREXCEPT 1
/* #undef HAVE_FESETTRAPENABLE */
/* #undef HAVE_FETESTEXCEPT */
#define HAVE_FGETPOS 1
#define HAVE_FINITE 1
#define HAVE_FPCLASS 1
#define HAVE_FTIME 1
#define HAVE_GETCWD 1
#define HAVE_GETENV 1
/* #undef HAVE_GETHOSTBYNAME */
/* #undef HAVE_GETHOSTENT */
/* #undef HAVE_GETHOSTID */
/* #undef HAVE_GETHOSTNAME */
/* #undef HAVE_GETHRTIME */
#define HAVE_GETPAGESIZE 1
/* #undef HAVE_GETPWNAM */
/* #undef HAVE_GETRUSAGE */
#define HAVE_GETTIMEOFDAY 1
/* #undef HAVE_GETWD */
#define HAVE_ISATTY 1
/* #undef HAVE_ISINF */
#define HAVE_ISNAN 1
/* #undef HAVE_KILL */
#define HAVE_LABS 1
#define HAVE_LGAMMA 1
/* #undef HAVE_LINK */
#define HAVE_LOCALTIME 1
/* #undef HAVE_LSTAT */
/* #undef HAVE_MALLINFO */
/* #undef HAVE_MBSNRTOWCS */
#define HAVE_MEMCPY 1
#define HAVE_MEMMOVE 1
/* #undef HAVE_MKSTEMP */
#define HAVE_MKTEMP 1
#define HAVE_MKTIME 1
/* #undef HAVE_MMAP */
/* #undef HAVE_NANOSLEEP */
/* #undef HAVE_NSLINKMODULE */
#define HAVE_OPENDIR 1
#define HAVE_POPEN 1
/* #undef HAVE_PTHREAD_MUTEXATTR_SETKIND_NP */
/* #undef HAVE_PTHREAD_MUTEXATTR_SETTYPE */
#define HAVE_PUTENV 1
#define HAVE_RAND 1
/* #undef HAVE_RANDOM */
/* #undef HAVE_READLINK */
/* #undef HAVE_REGEXEC */
#define HAVE_RENAME 1
#define HAVE_RINT 1
/* #undef HAVE_RL_SET_PROMPT */
/* #undef HAVE_SBRK */
/* #undef HAVE_SELECT */
#define HAVE_SETBUF 1
/* #undef HAVE_SETITIMER */
/* #undef HAVE_SETLINEBUF */
/* #undef HAVE_SETLOCALE */
/* #undef HAVE_SETSID */
/* #undef HAVE_SHMAT */
/* #undef HAVE_SIGACTION */
/* #undef HAVE_SIGGETMASK */
/* #undef HAVE_SIGINTERRUPT */
#define HAVE_SIGNAL 1
/* #undef HAVE_SIGPROCMASK */
#define HAVE_SIGSETJMP 0
/* #undef HAVE_SLEEP */
/* #undef HAVE_SNPRINTF */
/* #undef HAVE_SOCKET */
#define HAVE_STAT 1
#define HAVE_STRCHR 1
#define HAVE_STRERROR 1
#define HAVE_STRICMP 1
#define HAVE_STRNCAT 1
#define HAVE_STRNCPY 1
#define HAVE_STRTOD 1
#define HAVE_SYSTEM 1
#define HAVE_TIME 1
/* #undef HAVE_TIMES */
#define HAVE_TMPNAM 1
/* #undef HAVE_TTYNAME */
#define HAVE_USLEEP 1
#define HAVE_VSNPRINTF 1
/* #undef HAVE_WAITPID */
#define HAVE_MPZ_XOR 1

#define HAVE_SIGINFO 0
#define HAVE_SIGSEGV 1
#define HAVE_SIGPROF 1

#define HAVE_ENVIRON 1

#define HAVE_VAR_TIMEZONE 1

/* #undef HAVE_STRUCT_TIME_TM_GMTOFF */

#define  SELECT_TYPE_ARG1    
#define  SELECT_TYPE_ARG234  
#define  SELECT_TYPE_ARG5    

#define  TYPE_SELECT_
#define  MYTYPE(X) MYTYPE1#X

/* define how to pass the address of a function */
#define FunAdr(Fn)  Fn

#define  ALIGN_LONGS 1
#define  LOW_ABSMI 0

#define  MSHIFTOFFS 1

#define USE_DL_MALLOC 1
/* #undef USE_MALLOC */
/* #undef USE_SYSTEM_MALLOC */
#define USE_MMAP    (HAVE_MMAP  & !USE_MALLOC & !USE_SYSTEM_MALLOC)
#define USE_SHM	    (HAVE_SHMAT & !HAVE_MMAP & !USE_MALLOC & !USE_SYSTEM_MALLOC)
#define USE_SBRK    (HAVE_SBRK  & !HAVE_MMAP & !HAVE_SHMAT & !USE_MALLOC & !USE_SYSTEM_MALLOC)

/* for OSes that do not allow user access to the first
   quadrant of the memory space */
/* #undef FORCE_SECOND_QUADRANT */

#if (HAVE_SOCKET || defined(__MINGW32__)) && !defined(SIMICS)
#define USE_SOCKET 1
#endif

#if defined(__hpux)
/* HP-UX requires extra definitions for X/Open networking */
/* #undef _XOPEN_SOURCE */
#define _XOPEN_SOURCE_EXTENDED 0
#endif

#if HAVE_GMP_H && HAVE_LIBGMP
#define USE_GMP 1
#endif

/* Should we use MPI ? */
#if defined(HAVE_MPI_H) && (HAVE_LIBMPI || HAVE_LIBMPICH)
 #define HAVE_MPI 1
#else
 #define HAVE_MPI 0
#endif

/* Should we use MPE ? */
#if defined(HAVE_MPI_H) && HAVE_LIBMPE &&  HAVE_MPI
 #define HAVE_MPE 1
#else
 #define HAVE_MPE 0
#endif

/* should we avoid realloc() in mpi.c? */
#define MPI_AVOID_REALLOC 0

/* Is fflush(NULL) clobbering input streams? */
#define BROKEN_FFLUSH_NULL 1

/* sunpro cc */
#ifdef __SUNPRO_CC
#ifdef HAVE_GCC
#define HAVE_GCC 1
#endif
#endif

#define GC_NO_TAGS 1

#define MAX_WORKERS (8*SIZEOF_INT_P)

#define MAX_THREADS 1



