#!/usr/bin/env/tclsh

# Instantiates the Tcl extension template by prompting user.
# See README.md for details.

package require Tcl 9
source [file join [file dirname [info script]] getopt.tcl]

proc prompt {prompt {default ""}} {
    if {$default ne ""} {
        append prompt { [} $default {]}
    }
    while {1} {
        puts -nonewline "$prompt: " ; flush stdout
        set response [gets stdin]
        if {$response ne ""} {
            return $response
        }
        if {[eof stdin]} {
            abort "End of file on input."
        }
        if {$default ne ""} {
            return $default
        }
    }
}

proc yesno {prompt {default Y}} {
    while {1} {
        set response [prompt "$prompt (Y, N)" $default]
        if {$response in "y Y n N"} {
            return [string toupper $response]
        }
        puts "Please respond with Y(es) or N(o)."
    }
}

proc yesnoall {prompt {default Y}} {
    while {1} {
        set response [prompt "$prompt (Y, N, A)" $default]
        if {$response in "a A n N y Y"} {
            return [string toupper $response]
        }
        puts "Please respond with Y(es), N(o) or A(ll)."
    }
}

proc overwrite? {path} {
    global options
    if {$options(overwrite) eq "A" || ![file exists $path]} {
        return 1
    }
    set options(overwrite) [yesnoall "File $path exists. Overwrite?"]
    if {$options(overwrite) ne "N"} {
        backup $path
        return 1
    }
    return 0
}

proc abort {message} {
    puts stderr $message
    exit 1
}

proc fnormalize {path} {
    return [file dirname [file normalize [file join $path ...]]]
}

proc cleanup {} {
    global savedPaths
    foreach path $savedPaths {
        if {[file exists $path.backup]} {
            file delete $path.backup
        }
    }
}

proc backup {path} {
    global savedPaths
    if {[file exists $path]} {
        file rename -force $path $path.backup
        lappend savedPaths $path
    }
}

proc restore {} {
    global savedPaths
    foreach path $savedPaths {
        if {[catch {file rename -force $path.backup $path} result]} {
            puts stderr "Failed to restore $path."
        }
    }
}

proc uncomment_symbols {lines symbols} {
    regsub -all -line "^(\s*)#([join $symbols |]\\s)" $lines \\1\\2
}

proc parse_options {argv} {
    global options

    set options(owner) ""
    set options(package) ""
    set options(overwrite) ""; # Not boolean. Empty string -> uninitialized
    set options(tk) no
    set options(privateheaders) no

    # NOTE: the comments in the code below are also used by getopt
    # for generating help text. CAREFUL modifying them.
    getopt::getopt opt arg $argv {
        -c: - --copyright:OWNER {
            # Copyright owner. Will prompt if unspecified.
            set options(owner) $arg
        }
        -p: - --package:PACKAGE {
            # Package name. Will prompt if unspecified.
            set options(package) $arg
        }
        -d: - --directory:DIR {
            # Output directory. Defaults to current directory.
            set options(targetDir) $arg
        }
        --overwrite {
            # Overwrite files without prompting. Default false.
            set options(overwrite) A
        }
        --tk {
            # Tk extension. Default false.
            set options(tk) yes
        }
        --private-headers {
            # Need Tcl and Tk private headers. Default false.
            set options(privateheaders) yes
        }
    }

    if {$options(package) eq ""} {
        set options(package) [prompt "Enter package name"]
    }
    if {![string is alnum -strict $options(package)]} {
        abort "Package name \"$options(package)\" is not alphanumeric."
    }

    if {$options(owner) eq ""} {
        set options(owner) [prompt "Enter copyright owner name"]
    }

    if {![info exists options(targetDir)] || $options(targetDir) eq ""} {
        set options(targetDir) [pwd]
    } else {
        set options(targetDir) [fnormalize $options(targetDir)]
        if {[file exists $options(targetDir)] &&
            ![file isdirectory $options(targetDir)]} {
            abort "$options(targetDir) exists but is not a directory."
        }
    }
}

proc copy_tcl_files {} {
    global options
    global savedPaths

    set sourceDir [fnormalize [file dirname [info script]]]
    if {$options(targetDir) eq $sourceDir} {
        abort "Target directory and template directory are the same ($options(targetDir))."
    }
    set savedPaths [list ]
    set sourceFiles {
        aclocal.m4
        configure.ac
        license.terms
        Makefile.in
        pkgIndex.tcl.in
        generic/myExtension.c
        generic/myExtension.h
        generic/myExtensionBuildInfo.c
        tests/all.tcl
        tests/build-info.test
        win/makefile.vc
        win/nmakehlp.c
        win/rules-ext.vc
        win/rules.vc
        win/targets.vc
        tclconfig/README.txt
        tclconfig/install-sh
        tclconfig/license.terms
        tclconfig/tcl.m4
        .gitattributes
        .github/workflows/mac.yml
        .github/workflows/mingw.yml
        .github/workflows/msvc.yml
        .github/workflows/ubuntu.yml
    }

    set sourcePaths [lmap path $sourceFiles {
        file join $sourceDir $path
    }]
    set targetPaths [lmap path $sourceFiles {
        file join $options(targetDir) $path
    }]

    file mkdir $options(targetDir)
    if {[catch {
        foreach fromPath $sourcePaths toPath $targetPaths {
            file mkdir [file dirname $toPath]
            if {![overwrite? $toPath]} {
                continue
            }
            writeFile $toPath \
                [string map [list \
                                 Myextension [string totitle $options(package)] \
                                 myExtension $options(package) \
                                 myextension $options(package) \
                                 MYEXTENSION [string toupper $options(package)] \
                                 myName $options(owner) \
                                 "Ashok P. Nadkarni" $options(owner) \
                                ] [readFile $fromPath]]
        }
    } result]} {
        puts stderr "Error instantiating extension template: $result"
        puts stderr "Restoring files."
        restore
        exit 1
    }

    # Rename template file to package names
    foreach path {
        generic/myExtension.c
        generic/myExtension.h
        generic/myExtensionBuildInfo.c
    } {
        # Note options(targetDir) is the directory for both source and destination
        set fromPath [file join $options(targetDir) $path]
        set toPath [file join $options(targetDir) [string map [list myExtension $options(package)] $path]]
        if {![overwrite? $toPath]} {
            continue
        }
        if {[catch {
            file rename -force $fromPath $toPath
        } result]} {
            puts stderr "Could not rename $fromPath to $toPath."
        }
    }

    file mkdir library

    file copy -force -- [file join $sourceDir README.md] [file join $options(targetDir) README-template.md]
    writeFile [file join $options(targetDir) README.md] "# README for $options(package)\n"

    if {$options(privateheaders)} {
        set path [file join $options(targetDir) configure.ac]
        writeFile $path [uncomment_symbols [readFile $path] [list TEA_PRIVATE_TCL_HEADERS]]
        set path [file join $options(targetDir) win makefile.vc]
        writeFile $path [uncomment_symbols [readFile $path] [list NEED_TCL_SOURCE]]

        set path [file join $options(targetDir) generic $options(package).h]
        writeFile $path [regsub {/{1,1}?\*\s*#include\s+<tclInt.h>.*\*/} [readFile $path] "#include <tclInt.h>"]
    }
}

proc make_tk_edits {} {
    global options

    # Note: these substitutions partly work based on the Tk optional defines coming
    # AFTER the non-Tk defines.
    foreach {fn symbols private} {
        configure.ac {
            TEA_PATH_TKCONFIG
            TEA_LOAD_TKCONFIG
            TEA_PUBLIC_TK_HEADERS
            TEA_PATH_X
        } {TEA_PRIVATE_TK_HEADERS}
        Makefile.in {
            TK_BIN_DIR
            TK_SRC_DIR
            EXTRA_PATH
            WISH_ENV
            WISH_PROG
            WISH
            INCLUDES
        } {}
        win/makefile.vc {
            NEED_TK
        } {NEED_TK_SOURCE}
    } {
        set path [file join $options(targetDir) $fn]
        if {$options(privateheaders)} {
            lappend symbols {*}$private
        }
        writeFile $path [uncomment_symbols [readFile $path] $symbols]
    }

    set path [file join $options(targetDir) generic $options(package).h]
    set text [readFile $path]
    set text [regsub {/{1,1}?\*\s*#include\s+<tk.h>.*\*/} $text "#include <tk.h>"]
    if {$options(privateheaders)} {
        set text [regsub {/{1,1}?\*\s*#include\s+<tkInt.h>.*\*/} $text "#include <tkInt.h>"]
    }
    writeFile $path $text

    set path [file join $options(targetDir) generic $options(package).c]

}

# Main script

parse_options $argv
if {![yesno "Package \"$options(package)\" will be created in directory $options(targetDir). Continue?"]} {
    abort "Cancelled by user."
}

copy_tcl_files

if {$options(tk)} {
    make_tk_edits
}


puts ""
puts "Extension skeleton created in $options(targetDir)."
puts "Remember this is only a template. At the very least"
puts "  - If using autoconf, modify configure.ac, and Makefile.in (including targets)"
puts "    as appropriate and regenerate the configure script."
puts "  - If using nmake, make analogous changes to win/makefile.vc as well."
cleanup
exit 0
