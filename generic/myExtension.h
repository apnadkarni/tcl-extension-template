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
