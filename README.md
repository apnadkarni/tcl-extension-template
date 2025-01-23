# Tcl extension template

This is a template that should serve as a starting point for new Tcl extensions.
It is *not* a tutorial and *not* an illustrative sample. It is meant to create
the layout used for extensions built using the standard Tcl Extension Architecture
([TEA](https://wiki.tcl-lang.org/page/TEA)) and assumes familiarity with
the same. In addition, it also includes CI workflows for Github actions.

The template does not include direct support for Tk extensions although of course
you could modify the generated files appropriately.

To use:

1. Download a [release](https://github.com/apnadkarni/tcl-extension-template/releases)

2. Extract files to an empty directory where you will develop the extension.

3. Run `tclsh instantiate.tcl` and answer the prompts.

4. Run autoconf to generate the configure script.

5. Build and test as per TEA and / or nmake procedures.

6. Add your sources, modify `configure.ac`, `Makefile.in` (remember to
regenerate configure!), `makefile.vc` etc. and build the next great Tcl
extension!

NOTE: Also edit the .gitignore and .gitattributes files to ensure they meet
your project needs.

The template includes a `build-info` command analogous to the Tcl `build-info`
command. This should work without modifications. Delete if not wanted.
