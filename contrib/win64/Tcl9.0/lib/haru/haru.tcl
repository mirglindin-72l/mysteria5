# Copyright (c) 2022-2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# haru - Tcl bindings for libharu (http://libharu.org/) PDF library.

# 10-Feb-2022 : v1.0   Initial release
# 12-Jun-2022 : v1.1
               # Fixes u3d_demo.tcl, to make it work with libharu 2.3.
               # Ignore some functions if not available. (Windows OS)
# 24-May-2023 : v1.2
               # Bumped libharu to v2.4.3.
               # Cosmetic changes.
               # Tested on Windows and MacOS.
# 19-Jun-2025 : v2.0
               # Bumped libharu to `v2.4.5`.
               # Bumped package `tcl-cffi` to v2.*.
               # Support for Tcl9.
               # Try checking several places for the location of `libharu` lib.
               # Tested on Windows and MacOS.
               # Incompatibility with previous versions of this package :
               #   - Use `cffi::enum` instead of global variables 
               #    (see haru_enum.tcl : HPDF_TRUE, HPDF_COMP_ALL, etc...).
               # Cosmetic changes.
# 08-Jul-2025 : v2.1
               # Enhanced cross-platform library search functionality.
               # The minimum supported libharu version is now `2.4.3`.
               # Support for multiple versions of libharu until `2.4.5`.


package require Tcl 8.6-
package require cffi 2.0

namespace eval haru {
    variable hpdfMinVersion "2.4.3"
    variable version 2.1
    variable packageDirectory [file dirname [file normalize [info script]]]
    variable supportedHpdfVersions [list 2.4.3 2.4.4 2.4.5]

    proc load_hpdf {} {
        # Locates and loads the hpdf shared library
        #
        # Tries in order
        #   - the system default search path
        #   - platform specific subdirectories under the package directory
        #   - the toplevel package directory
        #   - the directory where the main program is installed
        # If all fail, simply tries the name as is in which case the
        # system will look up in the standard shared library search path.
        #
        # On success, creates the HPDF cffi::Wrapper object in the global
        # namespace.

        variable packageDirectory
        variable supportedHpdfVersions

        # First make up list of possible shared library names depending
        # on platform and supported shared library versions.
        set ext [info sharedlibextension]
        if {$::tcl_platform(platform) eq "windows"} {
            # Names depend on compiler (mingw/vc). VC -> hpdf, mingw -> libhpdf
            # Examples: hpdf.dll, libhpdf.dll, hpdfVERSION.dll, hpdf-VERSION.dll
            foreach baseName {hpdf libhpdf} {
                foreach hpdfVersion $supportedHpdfVersions {
                    lappend fileNames $baseName$hpdfVersion$ext \
                        $baseName-$hpdfVersion$ext
                }
                lappend fileNames $baseName$ext
            }
        } else {
            # Unix: libhpdf.so, libhpdfVERSION.so, libhpdf-VERSION.so, libhpdf.so.VERSION
            foreach hpdfVersion $supportedHpdfVersions {
                lappend fileNames libhpdf$hpdfVersion$ext \
                    libhpdf.$hpdfVersion$ext \
                    libhpdf-$hpdfVersion$ext
            }
            lappend fileNames libhpdf$ext
        }

        set attempts {}

        # First try the system default search paths by no explicitly
        # specifying the full path
        foreach fileName $fileNames {
            if {![catch {
                cffi::Wrapper create ::HPDF $fileName
            } err]} {
                return
            }
            append attempts $fileName : $err \n
        }

        # Not on default search path. Look under platform specific directories
        # under the package directory.
        package require platform
        set searchPaths [lmap platform [platform::patterns [platform::identify]] {
            if {$platform eq "tcl"} {
                continue
            }
            file join $packageDirectory $platform
        }]
        # Also look in package directory and location of main executable.
        # On Windows, the latter is probably redundant but...
        lappend searchPaths $packageDirectory
        lappend searchPaths [file dirname [info nameofexecutable]]
        # Specific case for macOS where the shared library is installed
        # under '/usr/local/lib'.
        if {$::tcl_platform(platform) eq "unix"} {
            set searchPaths [linsert $searchPaths 0 "/usr/local/lib"]
        }
        # Now do the actual search over search path for each possible name
        foreach searchPath $searchPaths {
            foreach fileName $fileNames {
                set path [file join $searchPath $fileName]
                if {![catch {
                    cffi::Wrapper create ::HPDF $path
                } err]} {
                    return
                }
                append attempts $path : $err \n
            }
        }
        return -code error "Failed to load libhpdf:\n$attempts"
    }
}

haru::load_hpdf

# Gets hpdf version.
HPDF stdcall HPDF_GetVersion string {}

if {[package vcompare [HPDF_GetVersion] $::haru::hpdfMinVersion] < 0} {
    error "libhpdf version '[HPDF_GetVersion]' is\
           unsupported. Need '$::haru::hpdfMinVersion' or later."
}

package provide haru $::haru::version
