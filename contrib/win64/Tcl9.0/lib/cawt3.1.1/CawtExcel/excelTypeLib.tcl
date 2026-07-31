# Automatically generated type library interface
# File:    Excel.exe
# Name:    Excel
# GUID:    {00020813-0000-0000-C000-000000000046}
# Version: 1.9
# LCID:    0

package require twapi_com

namespace eval ExcelTypeLib {

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
            
    # Coclass QueryTable
    set ::twapi::_coclass_idispatch_guids({59191DA1-EA47-11CE-A51F-00AA0061507F}) "{00024428-0000-0000-C000-000000000046}"

    set _coclass_guids(QueryTable) "{59191DA1-EA47-11CE-A51F-00AA0061507F}"
    twapi::class create QueryTable {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{59191DA1-EA47-11CE-A51F-00AA0061507F}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{59191DA1-EA47-11CE-A51F-00AA0061507F}"]
            if {[string length "{00024428-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00024428-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Application
    set ::twapi::_coclass_idispatch_guids({00024500-0000-0000-C000-000000000046}) "{000208D5-0000-0000-C000-000000000046}"

    set _coclass_guids(Application) "{00024500-0000-0000-C000-000000000046}"
    twapi::class create Application {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00024500-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00024500-0000-0000-C000-000000000046}"]
            if {[string length "{000208D5-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000208D5-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Chart
    set ::twapi::_coclass_idispatch_guids({00020821-0000-0000-C000-000000000046}) "{000208D6-0000-0000-C000-000000000046}"

    set _coclass_guids(Chart) "{00020821-0000-0000-C000-000000000046}"
    twapi::class create Chart {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00020821-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00020821-0000-0000-C000-000000000046}"]
            if {[string length "{000208D6-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000208D6-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Worksheet
    set ::twapi::_coclass_idispatch_guids({00020820-0000-0000-C000-000000000046}) "{000208D8-0000-0000-C000-000000000046}"

    set _coclass_guids(Worksheet) "{00020820-0000-0000-C000-000000000046}"
    twapi::class create Worksheet {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00020820-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00020820-0000-0000-C000-000000000046}"]
            if {[string length "{000208D8-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000208D8-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Global
    set ::twapi::_coclass_idispatch_guids({00020812-0000-0000-C000-000000000046}) "{000208D9-0000-0000-C000-000000000046}"

    set _coclass_guids(Global) "{00020812-0000-0000-C000-000000000046}"
    twapi::class create Global {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00020812-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00020812-0000-0000-C000-000000000046}"]
            if {[string length "{000208D9-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000208D9-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Workbook
    set ::twapi::_coclass_idispatch_guids({00020819-0000-0000-C000-000000000046}) "{000208DA-0000-0000-C000-000000000046}"

    set _coclass_guids(Workbook) "{00020819-0000-0000-C000-000000000046}"
    twapi::class create Workbook {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00020819-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00020819-0000-0000-C000-000000000046}"]
            if {[string length "{000208DA-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000208DA-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OLEObject
    set ::twapi::_coclass_idispatch_guids({00020818-0000-0000-C000-000000000046}) "{000208A2-0000-0000-C000-000000000046}"

    set _coclass_guids(OLEObject) "{00020818-0000-0000-C000-000000000046}"
    twapi::class create OLEObject {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00020818-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00020818-0000-0000-C000-000000000046}"]
            if {[string length "{000208A2-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000208A2-0000-0000-C000-000000000046}"
            }
        }
    }
}

