# -*- tcl -*-
#
# Tcl package index file - generated from pkgIndex.tcl.in
#

package ifneeded netcdf 0.1 \
    [list apply [list {dir} {
        package require platform
        set package_ns ::netcdf
        set initName [string totitle netcdf]
        if {[package vsatisfies [package require Tcl] 9]} {
            set fileName "tcl9netcdf01.dll"
        } else {
            set fileName "netcdf01t.dll"
        }
        set platformId [platform::identify]
        set searchPaths [list [file join $dir $platformId] \
                             {*}[lmap platformId [platform::patterns $platformId] {
                                 file join $dir $platformId
                             }] \
                             $dir]
        foreach path $searchPaths {
            set lib [file join $path $fileName]
            if {[file exists $lib]} {
                uplevel #0 [list load $lib $initName]
                # Load was successful
                set ${package_ns}::dll_path $lib
                set ${package_ns}::package_dir $dir
                return
            }
        }
        error "Could not locate $fileName in directories [join $searchPaths {, }]"
    }] $dir]
