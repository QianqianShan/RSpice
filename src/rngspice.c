/* NOTE *** Must credit ngspice.dll example ***/

#include <R.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <ctype.h>
//#include <errno.h>

/*WIN32 is defined on windows operating systems (32-bit and 64-bit)*/
#ifdef WIN32
#include <windows.h>
#else /* not WINDOWS */

#include <dlfcn.h>
#include <unistd.h>
#include <pthread.h>
#endif


#ifdef WIN32
/*Define a CONSTANT variable*/
#define RTLD_NOW	2

typedef FARPROC funptr_t;

/* *dlopen,dlsym,dlclose,*dlerror are functions used by NgSpice initialization and error handling*/
void *dlopen(const char *, int);
funptr_t dlsym(void *, const char *);
int dlclose(void *);
char *dlerror(void);
#define strdup _strdup
#define PATH_SEPARATOR "\\"
#define LIB_PREFIX ""

static inline void usleep(int us)
{
    if (us >= 1000) Sleep(us/1000);
    else Sleep(1);
}

/*typedef is a facility to create new data type names,
typedef FARPROC funptr_t makes the name funptr_t a
synonym for FARPROC. */

/* In WIN32, the FARPROC declaration indicates a callback
function that has an unspecified parameter list. */

//typedef FARPROC funptr_t;

#else /* not WIN32 */

static inline void Sleep(int ms)
{
    usleep(ms*1000);
}

#define PATH_SEPARATOR "/"

#define LIB_PREFIX "lib"

typedef int *(*funptr_t)();


#endif /* WIN32 */

typedef int bool;
#define true 1
#define false 0


/*Declare the memory for error string, which will be useful for error handling
when initiazing ngspice and when loading the dll  */
static char errstr[1280];

/*Declare and initialize global variables
  (These don't seem to be used anymore  */
bool will_unload = false;
//bool error_ngspice = false;
//static bool has_break = false;


/* The header file sharedspice.h contains the sources for ngspice
shared library API, and must be included (Chapter 19.3 of NgSpice User Manual) */
#include "sharedspice.h"


/* Condition variable handling: */
volatile bool no_bg = true;  /* no_bg set indicates nothing is running in the background */

#ifdef WIN32

CONDITION_VARIABLE cv;
SRWLOCK lock; /* locks cv and no_bg */

void _stdcall InitializeConditionVariable(PCONDITION_VARIABLE ConditionVariable);
void _stdcall InitializeSRWLock(PSRWLOCK);


/*
static void initialize_cond_variable(void)
{
    InitializeConditionVariable(&cv);
    InitializeSRWLock(&lock);
}
*/


void _stdcall AcquireSRWLockShared(PSRWLOCK SRWLock);
BOOL _stdcall SleepConditionVariableSRW(PCONDITION_VARIABLE ConditionVariable,
                                        PSRWLOCK SRWLock, DWORD dwMilliseconds, ULONG Flags);

void _stdcall ReleaseSRWLockShared(PSRWLOCK SRWLock);

static inline void wait_no_bg(void)
{
    AcquireSRWLockShared(&lock);
    while (!no_bg)
    {
        SleepConditionVariableSRW(&cv,&lock,INFINITE,CONDITION_VARIABLE_LOCKMODE_SHARED);
    }
    ReleaseSRWLockShared(&lock);
}


void _stdcall AcquireSRWLockExclusive(PSRWLOCK SRWLock);
void _stdcall ReleaseSRWLockExclusive(PSRWLOCK SRWLock);

void _stdcall WakeAllConditionVariable(PCONDITION_VARIABLE ConditionVariable);

static inline void set_no_bg(bool val)
{
    AcquireSRWLockExclusive(&lock);
    no_bg=val;

    ReleaseSRWLockExclusive(&lock);
    WakeAllConditionVariable(&cv);
}


#else /* Everything except windows */

pthread_mutex_t lock;
pthread_cond_t cv;

/*
static void initialize_cond_variable(void)
{
    pthread_mutex_init(&lock,NULL);
    pthread_cond_init(&cv,NULL);
}
*/
static inline void wait_no_bg(void)
{
    pthread_mutex_lock(&lock);
    while (!no_bg)
    {
        pthread_cond_wait(&cv,&lock);
    }
    pthread_mutex_unlock(&lock);
}

static inline void set_no_bg(bool val)
{
    pthread_mutex_lock(&lock);
    no_bg=val;

    pthread_cond_signal(&cv);
    pthread_mutex_unlock(&lock);
}

#endif



/*Declarations of functions which will be called by R

Functions need to be 'void' type in order to be called by R. */

/*Function to load the Ngspice shared library, and initialize the handles to be used */
void InitializeSpice(char *dllpath,char *dllname);

/* Function to return the length of vector names returned from Ngspice */
void GetVectorLength(int *length);

/*Function to ask for the variable names which will be returned from NgSpice */
void GetPlotNames(char **name);

/*Function to find the length of the output data.*/
void GetLength(int *size);

/* Function to load the circuit*/
void CircuitLoad(char **circarray, int *len, int *list);

/* Function to alter model parameters*/
void AlterParameter(int *nalter, char **parameter);

/* Function to pass a pointer to ngspice and record the results in the pointed memory location*/
void ExportResults(int *number, double *data);

/*Function to send 'run' or 'bg_run' command to ngspice.*/
void RunSpice(int *bg);

/*Function to unload spice when simulation is done*/
void UnloadNgspice();





/*Function to compare the strings *p and *s, return 1 if equal
and 0 if not, used in error handling. Note that the comparison is done
after converting both strings to lowercases. */
int ciprefix(const char *p, const char *s);

/* Callback functions used by ngspice */
int
ng_getchar(char* outputreturn, int ident, void* userdata);

int
ng_getstat(char* outputreturn, int ident, void* userdata);

int
ng_thread_runs(bool noruns, int ident, void* userdata);


/* Defined for convention */
ControlledExit ng_exit;
SendData ng_data;
SendInitData ng_initdata;


/* functions exported by ngspice */
funptr_t ngSpice_Init_handle = NULL;
int(*ngSpice_Command_handle)(char*) = NULL;
int(*ngSpice_Circ_handle)(char **) = NULL;
funptr_t ngSpice_CurPlot_handle = NULL;
funptr_t ngSpice_AllVecs_handle = NULL;
funptr_t ngSpice_GVI_handle = NULL;
funptr_t ngSpice_AllPlots_handle = NULL;
void *ngdllhandle = NULL;




/* Function to initialize NgSpice */
void InitializeSpice(char *dllpath,char *dllname)
{
    char *errmsg = NULL;
    char *fulldllname;


    fulldllname=calloc(((dllpath != NULL) ? strlen(dllpath):0)+strlen(dllname)+20,1);
    if (dllpath)
    {
        strcat(fulldllname,dllpath);
        strcat(fulldllname,PATH_SEPARATOR);
    }
    //strcat(fulldllname,LIB_PREFIX);
    strcat(fulldllname,dllname);

    Rprintf("Start loading %s\n",fulldllname);
    ngdllhandle = dlopen(fulldllname, RTLD_NOW);
    errmsg = dlerror();
    if (errmsg)
        Rprintf("%s\n", errmsg);
    /* Rprintf("Value of errno: %d\n ", errno);
     Rprintf("The error message is : %s\n",
                     strerror(errno)); */

    if (ngdllhandle)
        Rprintf("%s loaded successfully. \n",fulldllname);
    else
    {
        Rprintf("%s not loaded !\n",fulldllname);
        //exit(1);
        //      error();
    }
    ngSpice_Init_handle = dlsym(ngdllhandle, "ngSpice_Init");
    errmsg = dlerror();
    if (errmsg)
        Rprintf("%s",errmsg);
    ngSpice_Command_handle = (int(*)(char*))dlsym(ngdllhandle, "ngSpice_Command");
    errmsg = dlerror();
    if (errmsg)
        Rprintf("%s",errmsg);
    ngSpice_Circ_handle = (int(*)(char**))dlsym(ngdllhandle, "ngSpice_Circ");
    errmsg = dlerror();
    if (errmsg)
        Rprintf("%s",errmsg);
    ngSpice_CurPlot_handle = dlsym(ngdllhandle, "ngSpice_CurPlot");
    errmsg = dlerror();
    if (errmsg)
        Rprintf("%s",errmsg);
    ngSpice_AllVecs_handle = dlsym(ngdllhandle, "ngSpice_AllVecs");
    errmsg = dlerror();
    if (errmsg)
        Rprintf("%s",errmsg);
    ngSpice_GVI_handle = dlsym(ngdllhandle, "ngGet_Vec_Info");
    errmsg = dlerror();
    if (errmsg)
        Rprintf("%s",errmsg);
    ngSpice_AllPlots_handle = dlsym(ngdllhandle, "ngSpice_AllPlots");
    errmsg = dlerror();
    if (errmsg)
        Rprintf("%s",errmsg);
    /*When ngspice.dll/.so is loaded, initialize the simulator by calling ngSpice_Init_handle,
    address pointers of callback functions such as SendChar*, SendStat* are sent to ngspice.dll .*/
    ((int * (*)(SendChar*, SendStat*, ControlledExit*, SendData*, SendInitData*,
                BGThreadRunning*, void*)) ngSpice_Init_handle)(ng_getchar, ng_getstat,
                        ng_exit, NULL, ng_initdata, ng_thread_runs, NULL);
}



/* Function to load the circuit */
void CircuitLoad(char **circarray, int *len, int *list)
{
    if (ngdllhandle != NULL)
    {
        /* Convert the last entry of the circarray to NULL(required by NgSpice)
        which can be recognized in C, not the character string "NULL"
        we sent down from R */
        circarray[(*len - 1)] = NULL;
        /*Send the circuit to ngspice */
        ((int * (*)(char**)) ngSpice_Circ_handle)(circarray);
        /* Change the last entry back to a string so R can copy it back without error message*/
        circarray[(*len - 1)] = "NULL";

   if (*list == 1) {
            ((int * (*)(char*)) ngSpice_Command_handle)("listing");
}

    }
    else
    {
        Rprintf("Ngspice shared library or the exported functions not found. \n Use initializeSpice() function to load and initialize the handles first. \n");
    }


}

/* Function to first check if the simulation is done and pass a pointer to
   ngspice and record the results in the pointed memory location*/
void ExportResults(int *number, double *data)
{  if (ngdllhandle != NULL)
   // if ( (ngSpice_AllVecs_handle != NULL) & (ngSpice_CurPlot_handle != NULL) & (ngSpice_AllPlots_handle != NULL) )
    {
        char  *curplot, *vecname;
        int cnt;
        char **vecarray, **plotnames;

        wait_no_bg();

        /* read current plot while simulation continues */
        curplot = ((char * (*)()) ngSpice_CurPlot_handle)();
        vecarray = ((char ** (*)(char*)) ngSpice_AllVecs_handle)(curplot);
        plotnames = ((char ** (*)(char*)) ngSpice_AllPlots_handle)(curplot);
        for (cnt = 0; plotnames[cnt] != NULL; cnt++)
        {
        }

        /* get length of the vector */
        char plotvec[256];
        pvector_info myvec;
        int veclength;
        vecname = vecarray[(*number)];
        /*export the number-th plot data */
        sprintf(plotvec, "%s.%s", curplot, vecname); /*write formatted data into a string*/
        //Rprintf("plotvec is : %s \n", plotvec);
        myvec = ((pvector_info(*)(char*)) ngSpice_GVI_handle)(plotvec);
        veclength = myvec->v_length;
        /*printf("\nActual length of vector %s is %d\n\n", plotvec, veclength); */

        for (cnt = 0; cnt < veclength; cnt++)
        {
            data[cnt] = (myvec->v_realdata)[cnt];
        }
    }
    else
    {
        Rprintf("Ngspice shared library or the exported functions not found. \n Use initializeSpice() function to load and initialize the handles first. \n");
    }

}

/* AlterParameter function is used to alter the parameter of the circuit
for multiple times and for multiple parameters at one time*/
void AlterParameter(int *nalter, char **parameter)
{   if (ngdllhandle != NULL)
   // if (ngSpice_Command_handle != NULL)
    {
        int i;
        char *ptr;
        for (i = 0; i < (*nalter); i++)
        {
            ptr = parameter[i];
            ((int * (*)(char*)) ngSpice_Command_handle)(ptr);
#ifdef DEBUG
            Rprintf("Alter command sent to ngspice\n");
#endif
        }
    }
    else
    {
        Rprintf("Ngspice shared library or the exported functions not found. \n Use initializeSpice() function to load and initialize the handles first. \n");
    }
}



/* AlterParameter function is used to alter the parameter of the circuit
for multiple times and for multiple parameters at one time*/
void SpiceCommand(int *n, char **cmd)
{  if (ngdllhandle != NULL)
   // if (ngSpice_Command_handle != NULL)
    {
        int i;
        char *ptr;
        for (i = 0; i < (*n); i++)
        {
            ptr = cmd[i];
            ((int * (*)(char*)) ngSpice_Command_handle)(ptr);
#ifdef DEBUG
            Rprintf("Commands sent to ngspice successfully.\n");
#endif
        }
    }
    else
    {
        Rprintf("Ngspice shared library or the exported functions not found. \n Use initializeSpice() function to load and initialize the handles first. \n");
    }
}


/*RunSpice: function to get the circuit or the circuit with altered parameter(s) started for new simulation */
void RunSpice(int *bg)
{ if (ngdllhandle != NULL)
   // if (ngSpice_Command_handle != NULL)
    {
        /* Throw out any existing results first */
        ((int * (*)(char*)) ngSpice_Command_handle)("destroy all");
        /* Now start the new run */
        if (*bg == 1)
        {
            ((int * (*)(char*)) ngSpice_Command_handle)("bg_run");
        }
        else
        {
            ((int * (*)(char*)) ngSpice_Command_handle)("run");
        }
    }
    else
    {
        Rprintf("Ngspice shared library or the exported functions not found. \n Use initializeSpice() function to load and initialize the handles first. \n");
    }
}

/*Function to return the length of the vector names from Ngspice */
void GetVectorLength(int *length)
{ if (ngdllhandle != NULL)
   // if ( (ngSpice_Command_handle != NULL) & (ngSpice_CurPlot_handle != NULL) & (ngSpice_AllVecs_handle != NULL))
    {
        char  *curplot;
        char **vecarray;

        /* read current plot while simulation continues */
        curplot = ((char * (*)()) ngSpice_CurPlot_handle)();
        vecarray = ((char ** (*)(char*)) ngSpice_AllVecs_handle)(curplot);
        int cnt;
        for (cnt = 0; vecarray[cnt] != NULL; cnt++)
        {
        }
        *length = cnt;
    }
    else
    {
        Rprintf("Ngspice shared library or the exported functions not found. \n Use initializeSpice() function to load and initialize the handles first. \n");
    }
}


/*Function to return the vector names of the data we want to save */
void GetPlotNames(char **name)
{ if (ngdllhandle != NULL)
   // if ((ngSpice_CurPlot_handle != NULL) & (ngSpice_AllVecs_handle != NULL))
    {
        char  *curplot;
        char **vecarray;

        /* read current plot while simulation continues */
        curplot = ((char * (*)()) ngSpice_CurPlot_handle)();
        vecarray = ((char ** (*)(char*)) ngSpice_AllVecs_handle)(curplot);
        int cnt;
        for (cnt = 0; vecarray[cnt] != NULL; cnt++)
        {
            name[cnt] = vecarray[cnt];
        }
        // printf("Number of vectors: %d\n", cnt);
    }
    else
    {
        Rprintf("Ngspice shared library or the exported functions not found. \n Use initializeSpice() function to load and initialize the handles first. \n");
    }
}


/*Function to return the length of data we want to save */
void GetLength(int *size)
{   if (ngdllhandle != NULL)
  //  if ((ngSpice_CurPlot_handle != NULL) & (ngSpice_AllVecs_handle != NULL) & (ngSpice_GVI_handle != NULL))
    {
        char  *curplot, *vecname;
        char **vecarray;

        wait_no_bg();
        // printf("Ready to extract the size of the data \n");

        /* read current plot while simulation continues */
        curplot = ((char * (*)()) ngSpice_CurPlot_handle)();
        vecarray = ((char ** (*)(char*)) ngSpice_AllVecs_handle)(curplot);
      //  int cnt;
        /*for (cnt = 0; vecarray[cnt] != NULL; cnt++) {
        	printf("Vector name: %s\n", vecarray[cnt]);
        }

        printf("Number of vectors: %d\n", cnt);
        */
        /* get length of first vector */
        char plotvec[256];
        pvector_info myvec;
        vecname = vecarray[0];
        sprintf(plotvec, "%s.%s", curplot, vecname); /*write formatted data into a string*/
        myvec = ((pvector_info(*)(char*)) ngSpice_GVI_handle)(plotvec);
        *size = myvec->v_length;
    }
    else
    {
        Rprintf("Ngspice shared library or the exported functions not found. \n Use initializeSpice() function to load and initialize the handles first. \n");
    }
}


/*Function to unload NgSpice*/
void UnloadNgspice()
{
    //int *ret;
    if (ngdllhandle)
    {
      //  Rprintf("Unload ngspice now\n");
        //ret = ( (int * (*)(char*)) ngSpice_Command_handle)("quit");
        //((int * (*)(char*)) ngSpice_Command_handle)("quit");
        //Rprintf("Quit successfully\n");
        dlclose(ngdllhandle);
        Rprintf("Unloaded\n\n");
        ngdllhandle = NULL;
      //  funptr_t ngSpice_Init_handle = NULL;
       // int(*ngSpice_Command_handle)(char*) = NULL;
//int(*ngSpice_Circ_handle)(char **) = NULL;
      //  funptr_t ngSpice_CurPlot_handle = NULL;
       // funptr_t ngSpice_AllVecs_handle = NULL;
      //  funptr_t ngSpice_GVI_handle = NULL;
      //  funptr_t ngSpice_AllPlots_handle = NULL;
    }
    else
    {
        Rprintf("Ngspice shared library not loaded.\n");
    }
}


/* Callback function called from bg thread in ngspice once upon intialization
   of the simulation vectors)*/
int
ng_initdata(pvecinfoall intdata, int ident, void* userdata)
{

#ifdef DEBUG
    int i;
    int vn = intdata->veccount;
    for (i = 0; i < vn; i++)
    {
        printf("Vector: %s\n", intdata->vecs[i]->vecname);
    }
#endif
    return 0;
}

/* Callback function in ngspice to transfer any string created by printf.

Output to stdout in ngspice is preceded by token stdout, same with stderr.*/
int
ng_getchar(char* outputreturn, int indent, void* userdata)
{
//#ifdef DEBUG
    Rprintf("%s\n", outputreturn);
//#endif
    /* set a flag if an error message occurred */
    if (ciprefix("stderr Error:", outputreturn))
        // error_ngspice = true;
        Rprintf("Error in Ngspice.\n");
    return 0;
}

/* Callback function in ngspice to transfer
simulation status (type and progress in percent). */
int ng_getstat(char* outputreturn, int ident, void* userdata)
{
//#ifdef DEBUG
    Rprintf("%s\n", outputreturn);
//#endif
    return 0;
}

/* Callback function called from ngspice upon starting (returns true) or
leaving (returns false) the bg thread. */
int
ng_thread_runs(bool noruns, int ident, void* userdata)
{
    set_no_bg(noruns);
#ifdef DEBUG
    if (!noruns || !has_break)
        Rprintf("bg running\n");
    else
        Rprintf("All done!\n");
#endif
    return 0;
}


/* Callback function called from bg thread in ngspice if funtion controlled_exit()
is hit. Do not exit, but unload ngspice. */
int
ng_exit(int exitstatus, bool immediate, bool quitexit, int ident, void* userdata)
{

    if (quitexit)
    {
        Rprintf("DNote: Returned from quit with exit status %d\n", exitstatus);
    }
    if (immediate)
    {
        Rprintf("DNote: Unload ngspice\n");
        ((int * (*)(char*)) ngSpice_Command_handle)("quit");
        dlclose(ngdllhandle);
    }

    else
    {
        Rprintf("DNote: Prepare unloading ngspice\n");
        will_unload = true;
    }

    return exitstatus;

}


#ifdef WIN32

void *dlopen(const char *name, int type)
{
    return LoadLibrary((LPCSTR)name);
}


funptr_t dlsym(void *hDll, const char *funcname)
{
    return GetProcAddress(hDll, funcname);
}



char *dlerror(void)
{
    LPVOID lpMsgBuf;
    char * testerr;
    DWORD dw = GetLastError();

    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dw,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR)&lpMsgBuf,
        0,
        NULL
    );
    testerr = (char*)lpMsgBuf;
    strcpy(errstr, lpMsgBuf);
    LocalFree(lpMsgBuf);
    if (ciprefix("Der Vorgang wurde erfolgreich beendet.", errstr))
        return NULL;
    else
        return errstr;
}

int dlclose(void *lhandle)
{
    return (int)FreeLibrary(lhandle);
}

#endif

/*Case insensitive prefix. */
int
ciprefix(const char *p, const char *s)
{
    while (*p)
    {
        if ((isupper(*p) ? tolower(*p) : *p) !=
                (isupper(*s) ? tolower(*s) : *s))
            return(false);
        p++;
        s++;
    }
    return (true);
}

