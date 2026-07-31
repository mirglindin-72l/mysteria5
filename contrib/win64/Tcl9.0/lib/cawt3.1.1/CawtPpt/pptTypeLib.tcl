# Automatically generated type library interface
# File:    msppt.olb
# Name:    PowerPoint
# GUID:    {91493440-5A91-11CF-8700-00AA0060263B}
# Version: 2.12
# LCID:    0

package require twapi_com

namespace eval PptTypeLib {

    # Array mapping coclass names to their guids
    variable _coclass_guids

    # Array mapping dispatch interface names to their guids
    variable _dispatch_guids

    # Returns the GUID for a coclass or empty string if not found
    proc coclass_guid {coclass_name} {
        variable _coclass_guids
        if {[info exists _coclass_guids($coclass_name)]} {
            return $_coclass_guids($coclass_name)
        }
        return ""
    }
    # Returns the GUID for a dispatch name or empty string if not found
    proc dispatch_guid {dispatch_name} {
        variable _dispatch_guids
        if {[info exists _dispatch_guids($dispatch_name)]} {
            return $_dispatch_guids($dispatch_name)
        }
        return ""
    }
    # Marks the specified object to be of a specific dispatch/coclass type
    proc declare {typename comobj} {
        # First check if it is the name of a dispatch interface
        set guid [dispatch_guid $typename]
        if {$guid ne ""} {
            $comobj -interfaceguid $guid
            return
        }

        # If not, check if it is the name of a coclass with a dispatch interface
        set guid [coclass_guid $typename]
        if {$guid ne ""} {
            if {[info exists ::twapi::_coclass_idispatch_guids($guid)]} {
                $comobj -interfaceguid $::twapi::_coclass_idispatch_guids($guid)
                return
            }
        }

        error "Could not resolve interface for $typename."
    }
            
    # Coclass Application
    set ::twapi::_coclass_idispatch_guids({91493441-5A91-11CF-8700-00AA0060263B}) "{91493442-5A91-11CF-8700-00AA0060263B}"

    set _coclass_guids(Application) "{91493441-5A91-11CF-8700-00AA0060263B}"
    twapi::class create Application {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{91493441-5A91-11CF-8700-00AA0060263B}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{91493441-5A91-11CF-8700-00AA0060263B}"]
            if {[string length "{91493442-5A91-11CF-8700-00AA0060263B}"]} {
                my -interfaceguid "{91493442-5A91-11CF-8700-00AA0060263B}"
            }
        }
    }

    # Coclass Global
    set ::twapi::_coclass_idispatch_guids({91493443-5A91-11CF-8700-00AA0060263B}) "{91493451-5A91-11CF-8700-00AA0060263B}"

    set _coclass_guids(Global) "{91493443-5A91-11CF-8700-00AA0060263B}"
    twapi::class create Global {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{91493443-5A91-11CF-8700-00AA0060263B}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{91493443-5A91-11CF-8700-00AA0060263B}"]
            if {[string length "{91493451-5A91-11CF-8700-00AA0060263B}"]} {
                my -interfaceguid "{91493451-5A91-11CF-8700-00AA0060263B}"
            }
        }
    }

    # Coclass Presentation
    set ::twapi::_coclass_idispatch_guids({91493444-5A91-11CF-8700-00AA0060263B}) "{9149349D-5A91-11CF-8700-00AA0060263B}"

    set _coclass_guids(Presentation) "{91493444-5A91-11CF-8700-00AA0060263B}"
    twapi::class create Presentation {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{91493444-5A91-11CF-8700-00AA0060263B}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{91493444-5A91-11CF-8700-00AA0060263B}"]
            if {[string length "{9149349D-5A91-11CF-8700-00AA0060263B}"]} {
                my -interfaceguid "{9149349D-5A91-11CF-8700-00AA0060263B}"
            }
        }
    }

    # Coclass Slide
    set ::twapi::_coclass_idispatch_guids({91493445-5A91-11CF-8700-00AA0060263B}) "{9149346A-5A91-11CF-8700-00AA0060263B}"

    set _coclass_guids(Slide) "{91493445-5A91-11CF-8700-00AA0060263B}"
    twapi::class create Slide {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{91493445-5A91-11CF-8700-00AA0060263B}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{91493445-5A91-11CF-8700-00AA0060263B}"]
            if {[string length "{9149346A-5A91-11CF-8700-00AA0060263B}"]} {
                my -interfaceguid "{9149346A-5A91-11CF-8700-00AA0060263B}"
            }
        }
    }

    # Coclass OLEControl
    set ::twapi::_coclass_idispatch_guids({91493446-5A91-11CF-8700-00AA0060263B}) "{914934C0-5A91-11CF-8700-00AA0060263B}"

    set _coclass_guids(OLEControl) "{91493446-5A91-11CF-8700-00AA0060263B}"
    twapi::class create OLEControl {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{91493446-5A91-11CF-8700-00AA0060263B}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{91493446-5A91-11CF-8700-00AA0060263B}"]
            if {[string length "{914934C0-5A91-11CF-8700-00AA0060263B}"]} {
                my -interfaceguid "{914934C0-5A91-11CF-8700-00AA0060263B}"
            }
        }
    }

    # Coclass Master
    set ::twapi::_coclass_idispatch_guids({91493447-5A91-11CF-8700-00AA0060263B}) "{9149346C-5A91-11CF-8700-00AA0060263B}"

    set _coclass_guids(Master) "{91493447-5A91-11CF-8700-00AA0060263B}"
    twapi::class create Master {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{91493447-5A91-11CF-8700-00AA0060263B}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{91493447-5A91-11CF-8700-00AA0060263B}"]
            if {[string length "{9149346C-5A91-11CF-8700-00AA0060263B}"]} {
                my -interfaceguid "{9149346C-5A91-11CF-8700-00AA0060263B}"
            }
        }
    }

    # Coclass PowerRex
    set ::twapi::_coclass_idispatch_guids({91493448-5A91-11CF-8700-00AA0060263B}) "{914934D3-5A91-11CF-8700-00AA0060263B}"

    set _coclass_guids(PowerRex) "{91493448-5A91-11CF-8700-00AA0060263B}"
    twapi::class create PowerRex {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{91493448-5A91-11CF-8700-00AA0060263B}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{91493448-5A91-11CF-8700-00AA0060263B}"]
            if {[string length "{914934D3-5A91-11CF-8700-00AA0060263B}"]} {
                my -interfaceguid "{914934D3-5A91-11CF-8700-00AA0060263B}"
            }
        }
    }
}

