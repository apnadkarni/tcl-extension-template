/*
 * myExtension.h --
 *
 *	Common header file for the extension.
 *
 * Copyright (c) myName
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#ifndef _MYEXTENSION_H
#define _MYEXTENSION_H

#include <tcl.h>
/* #include <tclInt.h> */
/* #include <tk.h> */
/* #include <tkInt.h> */

#if (TCL_MAJOR_VERSION < 8) || (TCL_MAJOR_VERSION == 8 && TCL_MINOR_VERSION < 7)
# undef Tcl_Size
  typedef int Tcl_Size;
# define Tcl_GetSizeIntFromObj Tcl_GetIntFromObj
# define Tcl_NewSizeIntObj Tcl_NewIntObj
# define TCL_SIZE_MAX      INT_MAX
# define TCL_SIZE_MODIFIER ""
# ifndef TCL_INDEX_NONE
#  define TCL_INDEX_NONE ((Tcl_Size) -1)
# endif
#endif


/* Extension data structures */

/* Function prototypes */

#ifdef __cplusplus
extern "C" {
#endif

/* Add other command implementing functions here. */
Tcl_ObjCmdProc MyCmdObjCmd;
Tcl_ObjCmdProc BuildInfoObjCmd;

DLLEXPORT int Myextension_Init(Tcl_Interp* interp);

#ifdef __cplusplus
}
#endif

#endif /* _MYEXTENSION_H */
