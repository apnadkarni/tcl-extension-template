#!/usr/bin/env/tclsh

# Instantiates the Tcl extension template by prompting user.

proc prompt {prompt} {
    puts -nonewline $prompt; flush stdout
}

prompt "Enter package name: "
set packageName [gets stdin]
prompt "Enter copyright owner name: "
set ownerName [gets stdin]

if {![string is alnum -strict $packageName]} {
    puts stderr "Package name must be alphanumeric"
    exit 1
}

set root [file dirname [info script]]
set paths [lmap f {
    configure.ac
    Makefile.in
    pkgIndex.tcl.in
    license.terms
    generic/myExtension.c
    generic/myExtension.h
    generic/myExtensionBuildInfo.c
    tests/build-info.test
    win/makefile.vc
} {
    file join $root $f
}]

proc cleanup_backups {} {
    foreach path $::paths {
        if {[file exists $path.backup]} {
            file delete $path.backup
        }
    }
}

proc restore_backups {} {
    foreach path $::paths {
        if {[file exists $path.backup]} {
            file rename $path.backup
        }
        if {[catch {file rename $path.backup $path} result]} {
            puts stderr "Failed to restore [file rootname $path]"
        }
    }
}

if {[catch {
    foreach path $paths {
        if {![file exists $path]} continue
        file copy -force $path $path.backup
        writeFile $path \
            [string map [list \
                             Myextension [string totitle $packageName] \
                             myExtension $packageName \
                             myextension $packageName \
                             MYEXTENSION [string toupper $packageName] \
                             myName $ownerName \
                             "Ashok P. Nadkarni" $ownerName \
                            ] [readFile $path]]
    }
} result]} {
    puts stderr "Error instantiating extension template: $result"
    puts stderr "Restoring template files"
    restore_backups
    exit 1
}

foreach path [lmap f {
        generic/myExtension.c
        generic/myExtension.h
        generic/myExtensionBuildInfo.c
    } {
        file join $root $f
    }] {
    if {![file exists $path]} continue
    set newPath [string map [list myExtension $packageName] $path]
    if {[file exists $newPath]} {
        puts stderr "$newPath exists. Skipping rename of $path."
    }
    if {[catch {
        file rename $path $newPath
    } result]} {
        puts stderr "Could not rename $path to $newPath."
    }
}

file mkdir library

file rename -force -- [file join $root README.md] [file join $root README-template.md]
writeFile [file join $root README.md] "# README for $packageName\n"

puts "Remember this is only a template. At the very least ..."
puts ""
puts "If using autoconf, modify configure.ac, and Makefile.in (including targets)"
puts "as appropriate and regenerate the configure script."
puts ""

puts "If using nmake, make analogous changes to win/makefile.vc as well."
cleanup_backups
exit 0
