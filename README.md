# Tcl extension template

This is a template that should serve as a starting point for new Tcl extensions.
It is *not* a tutorial and *not* an illustrative sample. It is meant to create
the layout used for extensions built using the standard Tcl Extension Architecture
([TEA](https://wiki.tcl-lang.org/page/TEA)) and assumes familiarity with
the same.

As a bonus, it also includes CI workflows for Github actions. These may be
used independently as well - see below.

The template does not include direct support for Tk extensions although of course
you could modify the generated files appropriately.

## Creating a Tcl extension skeleton

To use:

1. Download a [release](https://github.com/apnadkarni/tcl-extension-template/releases)

2. Extract files to an empty directory where you will develop the extension.

3. Run `tclsh generate.tcl` and answer the prompts.

4. Run autoconf to generate the configure script.

5. Build and test as per TEA and / or nmake procedures.

6. Add your sources: modify `configure.ac`, `Makefile.in` (remember to
regenerate configure!), `makefile.vc` etc. and build the next great Tcl
extension!

NOTE: Also edit the .gitignore and .gitattributes files to ensure they meet
your project needs.

The template includes a `build-info` command analogous to the Tcl `build-info`
command. This should work without modifications. Delete if not desired.

## Github action workflows

This repository also holds Github action workflows for testing Tcl extensions.
Even if not using the entire template, these workflows may be copied to
the `.github/workflows` directory in your extension repository. The workflows
are set up as "on-demand" workflows and manual triggering. They permit extensions
to be tested across any combination of Tcl and operating system version on
Linux, macOS and both 32- and 64-bit Windows. The combination(s) to be tested
are selected with dropdowns when triggering the workflow.

The workflows wrap the [tcl-setup](https://github.com/apnadkarni/tcl-setup)
and [tcl-build-extension](https://github.com/apnadkarni/tcl-build-extension)
actions.

For many extensions, no modifications should be required to the workflows. The
[tcl-csv]https://github.com/apnadkarni/tcl-csv/.github/workflows) repository,
for example, uses them without any modification. Extensions that have special
needs, such as building or installing additional thirdparty libraries, need to
modify the workflows. For an example, see the
[tcl-cffi]https://github.com/apnadkarni/tcl-cffi/.github/workflows).
