# Instantiates the Tcl extension template by prompting user.

proc prompt {prompt} {
    puts -nonewline $prompt; flush stdout
}

prompt "Enter package name: "
set packageName [gets stdin]
prompt "Enter copyright owner name: "
set owner [gets stdin]

if {![string is alnum -strict $packageName]} {
    puts stderr "Package name must be alphanumeric"
    exit 1
}

set root [file dirname [info script]]
if {[catch {
    foreach path [lmap f {
        configure.ac
        Makefile.in
        pkgIndex.tcl.in
        license.terms
        generic/myExtension.c
        generic/myExtension.h
        generic/myExtensionInfo.c
        win/makefile.vc
    } {
        file join $root $f
    }] {
        if {![file exists $path]} continue
        file copy -force $path $path.backup
        writeFile $path \
            [string map [list \
                             Myextension [string totitle $packageName] \
                             myExtension $packageName \
                             myextension $packageName \
                             MYEXTENSION [string toupper $packageName] \
                            ] [readFile $path]]
    }
} result]} {
    puts stderr "Error instantiating extension template: $result"
    puts stderr "Restoring template files"
    foreach path [glob -nocomplain -directory $root *.backup] {
        if {[catch {file rename $path [file rootname $path]} result]} {
            puts stderr "Failed to restore [file rootname $path]"
        }
    }
    exit 1
}

foreach path [lmap f {
        generic/myExtension.c
        generic/myExtension.h
        generic/myExtensionInfo.c
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
