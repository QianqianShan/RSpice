
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .C calls */
extern void AlterParameter(void *, void *);
extern void CircuitLoad(void *, void *);
extern void ExportResults(void *, void *);
extern void GetLength(void *);
extern void GetPlotNames(void *);
extern void GetVectorLength(void *);
extern void InitializeSpice(void *, void *);
extern void RunSpice(void *);
extern void SpiceCommand(void *, void *);
extern void UnloadNgspice();

static const R_CMethodDef CEntries[] = {
    {"AlterParameter",  (DL_FUNC) &AlterParameter,  2},
    {"CircuitLoad",     (DL_FUNC) &CircuitLoad,     2},
    {"ExportResults",   (DL_FUNC) &ExportResults,   2},
    {"GetLength",       (DL_FUNC) &GetLength,       1},
    {"GetPlotNames",    (DL_FUNC) &GetPlotNames,    1},
    {"GetVectorLength", (DL_FUNC) &GetVectorLength, 1},
    {"InitializeSpice", (DL_FUNC) &InitializeSpice, 2},
    {"RunSpice",        (DL_FUNC) &RunSpice,        1},
    {"SpiceCommand",    (DL_FUNC) &SpiceCommand,    2},
    {"UnloadNgspice",   (DL_FUNC) &UnloadNgspice,   0},
    {NULL, NULL, 0}
};

void R_init_RSpice(DllInfo *dll)
{
    R_registerRoutines(dll, CEntries, NULL, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
