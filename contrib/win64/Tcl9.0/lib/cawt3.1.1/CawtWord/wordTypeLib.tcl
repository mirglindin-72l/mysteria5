# Automatically generated type library interface
# File:    msword.olb
# Name:    Word
# GUID:    {00020905-0000-0000-C000-000000000046}
# Version: 8.7
# LCID:    0

package require twapi_com

namespace eval WordTypeLib {

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
            
    # Coclass Global
    set ::twapi::_coclass_idispatch_guids({000209F0-0000-0000-C000-000000000046}) "{000209B9-0000-0000-C000-000000000046}"

    set _coclass_guids(Global) "{000209F0-0000-0000-C000-000000000046}"
    twapi::class create Global {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000209F0-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000209F0-0000-0000-C000-000000000046}"]
            if {[string length "{000209B9-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000209B9-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Application
    set ::twapi::_coclass_idispatch_guids({000209FF-0000-0000-C000-000000000046}) "{00020970-0000-0000-C000-000000000046}"

    set _coclass_guids(Application) "{000209FF-0000-0000-C000-000000000046}"
    twapi::class create Application {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000209FF-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000209FF-0000-0000-C000-000000000046}"]
            if {[string length "{00020970-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00020970-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Document
    set ::twapi::_coclass_idispatch_guids({00020906-0000-0000-C000-000000000046}) "{0002096B-0000-0000-C000-000000000046}"

    set _coclass_guids(Document) "{00020906-0000-0000-C000-000000000046}"
    twapi::class create Document {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00020906-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00020906-0000-0000-C000-000000000046}"]
            if {[string length "{0002096B-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0002096B-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Font
    set ::twapi::_coclass_idispatch_guids({000209F5-0000-0000-C000-000000000046}) "{00020952-0000-0000-C000-000000000046}"

    set _coclass_guids(Font) "{000209F5-0000-0000-C000-000000000046}"
    twapi::class create Font {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000209F5-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000209F5-0000-0000-C000-000000000046}"]
            if {[string length "{00020952-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00020952-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ParagraphFormat
    set ::twapi::_coclass_idispatch_guids({000209F4-0000-0000-C000-000000000046}) "{00020953-0000-0000-C000-000000000046}"

    set _coclass_guids(ParagraphFormat) "{000209F4-0000-0000-C000-000000000046}"
    twapi::class create ParagraphFormat {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000209F4-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000209F4-0000-0000-C000-000000000046}"]
            if {[string length "{00020953-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00020953-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OLEControl
    set ::twapi::_coclass_idispatch_guids({000209F2-0000-0000-C000-000000000046}) "{000209A4-0000-0000-C000-000000000046}"

    set _coclass_guids(OLEControl) "{000209F2-0000-0000-C000-000000000046}"
    twapi::class create OLEControl {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000209F2-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000209F2-0000-0000-C000-000000000046}"]
            if {[string length "{000209A4-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000209A4-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass LetterContent
    set ::twapi::_coclass_idispatch_guids({000209F1-0000-0000-C000-000000000046}) "{000209A1-0000-0000-C000-000000000046}"

    set _coclass_guids(LetterContent) "{000209F1-0000-0000-C000-000000000046}"
    twapi::class create LetterContent {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000209F1-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000209F1-0000-0000-C000-000000000046}"]
            if {[string length "{000209A1-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000209A1-0000-0000-C000-000000000046}"
            }
        }
    }
}

