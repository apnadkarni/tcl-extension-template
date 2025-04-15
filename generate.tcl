#!/usr/bin/env/tclsh

# Instantiates the Tcl extension template by prompting user.
# See README.md for details.

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
    global overwriteAll
    if {$overwriteAll eq "A" || ![file exists $path]} {
        return 1
    }
    set overwriteAll [yesnoall "File $path exists. Overwrite?"]
    if {$overwriteAll ne "N"} {
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

# Main script

set overwriteAll ""
set savedPaths [list ]
set sourceRoot [fnormalize [file dirname [info script]]]
set sourceFiles {
    configure.ac
    Makefile.in
    pkgIndex.tcl.in
    license.terms
    generic/myExtension.c
    generic/myExtension.h
    generic/myExtensionBuildInfo.c
    tests/build-info.test
    win/makefile.vc
    .gitattributes
    .github/workflows/mac.yml
    .github/workflows/mingw.yml
    .github/workflows/msvc.yml
    .github/workflows/ubuntu.yml
}

if {[llength $argv] > 3} {
    abort "Syntax: [file dirname [info nameofexecutable]] $argv0 ?PACKAGENAME? ?COPYRIGHTHOLDER? ?DIRECTORY?"
}
lassign $argv packageName ownerName targetRoot

if {$targetRoot eq ""} {
    set targetRoot [pwd]
} else {
    set targetRoot [fnormalize $targetRoot]
}
if {$targetRoot eq $sourceRoot} {
    abort "Target directory and template directory are the same ($targetRoot)."
}

if {[file exists $targetRoot] && ![file isdirectory $targetRoot]} {
    abort "$targetRoot exists but is not a directory."
    break
}

if {$packageName eq ""} {
    set packageName [prompt "Enter package name"]
}
if {![string is alnum -strict $packageName]} {
    abort "Package name \"$packageName\" is not alphanumeric."
}

if {$ownerName eq ""} {
    set ownerName [prompt "Enter copyright owner name"]
}

if {![yesno "Package \"$packageName\" will be created in directory $targetRoot. Continue?"]} {
    abort "Cancelled by user."
}

set sourcePaths [lmap path $sourceFiles {
    file join $sourceRoot $path
}]
set targetPaths [lmap path $sourceFiles {
    file join $targetRoot $path
}]

file mkdir $targetRoot
if {[catch {
    foreach fromPath $sourcePaths toPath $targetPaths {
        file mkdir [file dirname $toPath]
        if {![overwrite? $toPath]} {
            continue
        }
        writeFile $toPath \
            [string map [list \
                             Myextension [string totitle $packageName] \
                             myExtension $packageName \
                             myextension $packageName \
                             MYEXTENSION [string toupper $packageName] \
                             myName $ownerName \
                             "Ashok P. Nadkarni" $ownerName \
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
    # Note targetRoot is the directory for both source and destination
    set fromPath [file join $targetRoot $path]
    set toPath [file join $targetRoot [string map [list myExtension $packageName] $path]]
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

file copy -force -- [file join $sourceRoot README.md] [file join $targetRoot README-template.md]
writeFile [file join $targetRoot README.md] "# README for $packageName\n"

puts ""
puts "Extension skeleton created in $targetRoot."
puts "Remember this is only a template. At the very least"
puts "  - If using autoconf, modify configure.ac, and Makefile.in (including targets)"
puts "    as appropriate and regenerate the configure script."
puts "  - If using nmake, make analogous changes to win/makefile.vc as well."
cleanup
exit 0
