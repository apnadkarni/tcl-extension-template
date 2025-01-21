/*
 * myExtension.c --
 *
 * Main file for the myExtension Tcl extension.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include "myExtension.h"

/*
 * Metainfo for a pkgconfig command for the extension via Tcl_RegisterConfig
 * Must only have const static UTF-8 encoded char pointers.
 */
Tcl_Config myExtensionConfig[] = {
    {"version", PACKAGE_VERSION},
    /* Add additional configuration or feature information if relevant */
    {NULL, NULL}
};

/*
 * MyCmdObjCmd --
 *
 *	 Description of the command.
 *
 * Results:
 *	A standard Tcl result
 *
 * Side effects:
 *	None.
 */

int
MyCmdObjCmd(
    void *dummy,	/* Not used. */
    Tcl_Interp *interp,		/* Current interpreter */
    int objc,			/* Number of arguments */
    Tcl_Obj *const objv[]	/* Argument strings */
    )
{
    /* Your code here */

    return TCL_OK;
}

/*
 * MyExtension_Init --
 *
 *	Initialize the extension etc.
 *
 * Results:
 *	A standard Tcl result
 *
 * Side effects:
 *	The package is registered with the interpreter.
 *	Commands ... are added to the interpreter.
 */

DLLEXPORT int
Myextension_Init(
    Tcl_Interp* interp)		/* Tcl interpreter */
{
    /*
     * Support any Tcl version compatible with the version against which the
     * extension is being built.
     */
    if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
	return TCL_ERROR;
    }

    /*
     * Do any required package initialization.
     */

    /*
     * Register the commands added by the package.
     */
    Tcl_CreateObjCommand(interp, PACKAGE_NAME "::" "mycmd", MyCmdObjCmd, NULL, NULL);
    Tcl_CreateObjCommand(interp, PACKAGE_NAME "::" "build-info", BuildInfoObjCmd, NULL, NULL);

    /* Register feature configuration  */
    Tcl_RegisterConfig(interp, PACKAGE_NAME, myExtensionConfig, "utf-8");


    /*
     * Inform Tcl the package is available. PACKAGE_NAME and PACKAGE_VERSION
     * are set by the build system (autoconf or nmake)
     */
    if (Tcl_PkgProvideEx(interp, PACKAGE_NAME, PACKAGE_VERSION, NULL) != TCL_OK) {
	return TCL_ERROR;
    }

    return TCL_OK;
}
