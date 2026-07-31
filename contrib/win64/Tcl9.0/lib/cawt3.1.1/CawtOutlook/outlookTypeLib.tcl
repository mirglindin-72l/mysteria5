# Automatically generated type library interface
# File:    msoutl.olb
# Name:    Outlook
# GUID:    {00062FFF-0000-0000-C000-000000000046}
# Version: 9.6
# LCID:    0

package require twapi_com

namespace eval OutlookTypeLib {

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
            
    # Coclass _RecipientControl
    set ::twapi::_coclass_idispatch_guids({0006F023-0000-0000-C000-000000000046}) "{0006F025-0000-0000-C000-000000000046}"

    set _coclass_guids(_RecipientControl) "{0006F023-0000-0000-C000-000000000046}"
    twapi::class create _RecipientControl {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F023-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F023-0000-0000-C000-000000000046}"]
            if {[string length "{0006F025-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006F025-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass _DocSiteControl
    set ::twapi::_coclass_idispatch_guids({0006F024-0000-0000-C000-000000000046}) "{0006F026-0000-0000-C000-000000000046}"

    set _coclass_guids(_DocSiteControl) "{0006F024-0000-0000-C000-000000000046}"
    twapi::class create _DocSiteControl {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F024-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F024-0000-0000-C000-000000000046}"]
            if {[string length "{0006F026-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006F026-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkTextBox
    set ::twapi::_coclass_idispatch_guids({0006F068-0000-0000-C000-000000000046}) "{000672DA-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkTextBox) "{0006F068-0000-0000-C000-000000000046}"
    twapi::class create OlkTextBox {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F068-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F068-0000-0000-C000-000000000046}"]
            if {[string length "{000672DA-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672DA-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkLabel
    set ::twapi::_coclass_idispatch_guids({0006F067-0000-0000-C000-000000000046}) "{000672D9-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkLabel) "{0006F067-0000-0000-C000-000000000046}"
    twapi::class create OlkLabel {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F067-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F067-0000-0000-C000-000000000046}"]
            if {[string length "{000672D9-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672D9-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkCommandButton
    set ::twapi::_coclass_idispatch_guids({0006F04A-0000-0000-C000-000000000046}) "{000672DB-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkCommandButton) "{0006F04A-0000-0000-C000-000000000046}"
    twapi::class create OlkCommandButton {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F04A-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F04A-0000-0000-C000-000000000046}"]
            if {[string length "{000672DB-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672DB-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkCheckBox
    set ::twapi::_coclass_idispatch_guids({0006F04C-0000-0000-C000-000000000046}) "{000672DD-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkCheckBox) "{0006F04C-0000-0000-C000-000000000046}"
    twapi::class create OlkCheckBox {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F04C-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F04C-0000-0000-C000-000000000046}"]
            if {[string length "{000672DD-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672DD-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkOptionButton
    set ::twapi::_coclass_idispatch_guids({0006F04B-0000-0000-C000-000000000046}) "{000672DC-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkOptionButton) "{0006F04B-0000-0000-C000-000000000046}"
    twapi::class create OlkOptionButton {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F04B-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F04B-0000-0000-C000-000000000046}"]
            if {[string length "{000672DC-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672DC-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkComboBox
    set ::twapi::_coclass_idispatch_guids({0006F04D-0000-0000-C000-000000000046}) "{000672DE-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkComboBox) "{0006F04D-0000-0000-C000-000000000046}"
    twapi::class create OlkComboBox {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F04D-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F04D-0000-0000-C000-000000000046}"]
            if {[string length "{000672DE-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672DE-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkListBox
    set ::twapi::_coclass_idispatch_guids({0006F04E-0000-0000-C000-000000000046}) "{000672DF-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkListBox) "{0006F04E-0000-0000-C000-000000000046}"
    twapi::class create OlkListBox {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F04E-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F04E-0000-0000-C000-000000000046}"]
            if {[string length "{000672DF-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672DF-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkInfoBar
    set ::twapi::_coclass_idispatch_guids({0006F054-0000-0000-C000-000000000046}) "{000672F6-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkInfoBar) "{0006F054-0000-0000-C000-000000000046}"
    twapi::class create OlkInfoBar {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F054-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F054-0000-0000-C000-000000000046}"]
            if {[string length "{000672F6-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672F6-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkContactPhoto
    set ::twapi::_coclass_idispatch_guids({0006F04F-0000-0000-C000-000000000046}) "{000672EB-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkContactPhoto) "{0006F04F-0000-0000-C000-000000000046}"
    twapi::class create OlkContactPhoto {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F04F-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F04F-0000-0000-C000-000000000046}"]
            if {[string length "{000672EB-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672EB-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkBusinessCardControl
    set ::twapi::_coclass_idispatch_guids({0006F050-0000-0000-C000-000000000046}) "{000672ED-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkBusinessCardControl) "{0006F050-0000-0000-C000-000000000046}"
    twapi::class create OlkBusinessCardControl {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F050-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F050-0000-0000-C000-000000000046}"]
            if {[string length "{000672ED-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672ED-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkPageControl
    set ::twapi::_coclass_idispatch_guids({0006F055-0000-0000-C000-000000000046}) "{000672F8-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkPageControl) "{0006F055-0000-0000-C000-000000000046}"
    twapi::class create OlkPageControl {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F055-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F055-0000-0000-C000-000000000046}"]
            if {[string length "{000672F8-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672F8-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkDateControl
    set ::twapi::_coclass_idispatch_guids({0006F056-0000-0000-C000-000000000046}) "{000672FA-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkDateControl) "{0006F056-0000-0000-C000-000000000046}"
    twapi::class create OlkDateControl {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F056-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F056-0000-0000-C000-000000000046}"]
            if {[string length "{000672FA-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672FA-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkTimeControl
    set ::twapi::_coclass_idispatch_guids({0006F051-0000-0000-C000-000000000046}) "{000672EF-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkTimeControl) "{0006F051-0000-0000-C000-000000000046}"
    twapi::class create OlkTimeControl {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F051-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F051-0000-0000-C000-000000000046}"]
            if {[string length "{000672EF-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672EF-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkCategory
    set ::twapi::_coclass_idispatch_guids({0006F053-0000-0000-C000-000000000046}) "{000672F4-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkCategory) "{0006F053-0000-0000-C000-000000000046}"
    twapi::class create OlkCategory {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F053-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F053-0000-0000-C000-000000000046}"]
            if {[string length "{000672F4-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000672F4-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkFrameHeader
    set ::twapi::_coclass_idispatch_guids({0006F057-0000-0000-C000-000000000046}) "{00067352-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkFrameHeader) "{0006F057-0000-0000-C000-000000000046}"
    twapi::class create OlkFrameHeader {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F057-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F057-0000-0000-C000-000000000046}"]
            if {[string length "{00067352-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00067352-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkSenderPhoto
    set ::twapi::_coclass_idispatch_guids({0006F058-0000-0000-C000-000000000046}) "{00067355-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkSenderPhoto) "{0006F058-0000-0000-C000-000000000046}"
    twapi::class create OlkSenderPhoto {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F058-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F058-0000-0000-C000-000000000046}"]
            if {[string length "{00067355-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00067355-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass PropertyAccessor
    set ::twapi::_coclass_idispatch_guids({0006102D-0000-0000-C000-000000000046}) "{0006302D-0000-0000-C000-000000000046}"

    set _coclass_guids(PropertyAccessor) "{0006102D-0000-0000-C000-000000000046}"
    twapi::class create PropertyAccessor {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006102D-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006102D-0000-0000-C000-000000000046}"]
            if {[string length "{0006302D-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006302D-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NavigationModule
    set ::twapi::_coclass_idispatch_guids({000610E8-0000-0000-C000-000000000046}) "{000630E8-0000-0000-C000-000000000046}"

    set _coclass_guids(NavigationModule) "{000610E8-0000-0000-C000-000000000046}"
    twapi::class create NavigationModule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610E8-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610E8-0000-0000-C000-000000000046}"]
            if {[string length "{000630E8-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E8-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NavigationModules
    set ::twapi::_coclass_idispatch_guids({000610E7-0000-0000-C000-000000000046}) "{000630E7-0000-0000-C000-000000000046}"

    set _coclass_guids(NavigationModules) "{000610E7-0000-0000-C000-000000000046}"
    twapi::class create NavigationModules {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610E7-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610E7-0000-0000-C000-000000000046}"]
            if {[string length "{000630E7-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E7-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Store
    set ::twapi::_coclass_idispatch_guids({000610C7-0000-0000-C000-000000000046}) "{000630C7-0000-0000-C000-000000000046}"

    set _coclass_guids(Store) "{000610C7-0000-0000-C000-000000000046}"
    twapi::class create Store {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610C7-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610C7-0000-0000-C000-000000000046}"]
            if {[string length "{000630C7-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630C7-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Rules
    set ::twapi::_coclass_idispatch_guids({000610CC-0000-0000-C000-000000000046}) "{000630CC-0000-0000-C000-000000000046}"

    set _coclass_guids(Rules) "{000610CC-0000-0000-C000-000000000046}"
    twapi::class create Rules {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610CC-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610CC-0000-0000-C000-000000000046}"]
            if {[string length "{000630CC-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630CC-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass RuleActions
    set ::twapi::_coclass_idispatch_guids({000610CE-0000-0000-C000-000000000046}) "{000630CE-0000-0000-C000-000000000046}"

    set _coclass_guids(RuleActions) "{000610CE-0000-0000-C000-000000000046}"
    twapi::class create RuleActions {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610CE-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610CE-0000-0000-C000-000000000046}"]
            if {[string length "{000630CE-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630CE-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass MoveOrCopyRuleAction
    set ::twapi::_coclass_idispatch_guids({000610D0-0000-0000-C000-000000000046}) "{000630D0-0000-0000-C000-000000000046}"

    set _coclass_guids(MoveOrCopyRuleAction) "{000610D0-0000-0000-C000-000000000046}"
    twapi::class create MoveOrCopyRuleAction {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D0-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D0-0000-0000-C000-000000000046}"]
            if {[string length "{000630D0-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D0-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass RuleAction
    set ::twapi::_coclass_idispatch_guids({000610CF-0000-0000-C000-000000000046}) "{000630CF-0000-0000-C000-000000000046}"

    set _coclass_guids(RuleAction) "{000610CF-0000-0000-C000-000000000046}"
    twapi::class create RuleAction {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610CF-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610CF-0000-0000-C000-000000000046}"]
            if {[string length "{000630CF-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630CF-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass SendRuleAction
    set ::twapi::_coclass_idispatch_guids({000610D1-0000-0000-C000-000000000046}) "{000630D1-0000-0000-C000-000000000046}"

    set _coclass_guids(SendRuleAction) "{000610D1-0000-0000-C000-000000000046}"
    twapi::class create SendRuleAction {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D1-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D1-0000-0000-C000-000000000046}"]
            if {[string length "{000630D1-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D1-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass AssignToCategoryRuleAction
    set ::twapi::_coclass_idispatch_guids({000610D4-0000-0000-C000-000000000046}) "{000630D4-0000-0000-C000-000000000046}"

    set _coclass_guids(AssignToCategoryRuleAction) "{000610D4-0000-0000-C000-000000000046}"
    twapi::class create AssignToCategoryRuleAction {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D4-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D4-0000-0000-C000-000000000046}"]
            if {[string length "{000630D4-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D4-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass PlaySoundRuleAction
    set ::twapi::_coclass_idispatch_guids({000610D5-0000-0000-C000-000000000046}) "{000630D5-0000-0000-C000-000000000046}"

    set _coclass_guids(PlaySoundRuleAction) "{000610D5-0000-0000-C000-000000000046}"
    twapi::class create PlaySoundRuleAction {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D5-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D5-0000-0000-C000-000000000046}"]
            if {[string length "{000630D5-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D5-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass MarkAsTaskRuleAction
    set ::twapi::_coclass_idispatch_guids({000610D6-0000-0000-C000-000000000046}) "{000630D6-0000-0000-C000-000000000046}"

    set _coclass_guids(MarkAsTaskRuleAction) "{000610D6-0000-0000-C000-000000000046}"
    twapi::class create MarkAsTaskRuleAction {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D6-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D6-0000-0000-C000-000000000046}"]
            if {[string length "{000630D6-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D6-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NewItemAlertRuleAction
    set ::twapi::_coclass_idispatch_guids({000610D7-0000-0000-C000-000000000046}) "{000630D7-0000-0000-C000-000000000046}"

    set _coclass_guids(NewItemAlertRuleAction) "{000610D7-0000-0000-C000-000000000046}"
    twapi::class create NewItemAlertRuleAction {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D7-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D7-0000-0000-C000-000000000046}"]
            if {[string length "{000630D7-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D7-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass RuleConditions
    set ::twapi::_coclass_idispatch_guids({000610D8-0000-0000-C000-000000000046}) "{000630D8-0000-0000-C000-000000000046}"

    set _coclass_guids(RuleConditions) "{000610D8-0000-0000-C000-000000000046}"
    twapi::class create RuleConditions {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D8-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D8-0000-0000-C000-000000000046}"]
            if {[string length "{000630D8-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D8-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass RuleCondition
    set ::twapi::_coclass_idispatch_guids({000610D9-0000-0000-C000-000000000046}) "{000630D9-0000-0000-C000-000000000046}"

    set _coclass_guids(RuleCondition) "{000610D9-0000-0000-C000-000000000046}"
    twapi::class create RuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D9-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D9-0000-0000-C000-000000000046}"]
            if {[string length "{000630D9-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D9-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ImportanceRuleCondition
    set ::twapi::_coclass_idispatch_guids({000610DA-0000-0000-C000-000000000046}) "{000630DA-0000-0000-C000-000000000046}"

    set _coclass_guids(ImportanceRuleCondition) "{000610DA-0000-0000-C000-000000000046}"
    twapi::class create ImportanceRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610DA-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610DA-0000-0000-C000-000000000046}"]
            if {[string length "{000630DA-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630DA-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass AccountRuleCondition
    set ::twapi::_coclass_idispatch_guids({000610DB-0000-0000-C000-000000000046}) "{000630DB-0000-0000-C000-000000000046}"

    set _coclass_guids(AccountRuleCondition) "{000610DB-0000-0000-C000-000000000046}"
    twapi::class create AccountRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610DB-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610DB-0000-0000-C000-000000000046}"]
            if {[string length "{000630DB-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630DB-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Account
    set ::twapi::_coclass_idispatch_guids({000610C5-0000-0000-C000-000000000046}) "{000630C5-0000-0000-C000-000000000046}"

    set _coclass_guids(Account) "{000610C5-0000-0000-C000-000000000046}"
    twapi::class create Account {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610C5-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610C5-0000-0000-C000-000000000046}"]
            if {[string length "{000630C5-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630C5-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TextRuleCondition
    set ::twapi::_coclass_idispatch_guids({000610E0-0000-0000-C000-000000000046}) "{000630E0-0000-0000-C000-000000000046}"

    set _coclass_guids(TextRuleCondition) "{000610E0-0000-0000-C000-000000000046}"
    twapi::class create TextRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610E0-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610E0-0000-0000-C000-000000000046}"]
            if {[string length "{000630E0-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E0-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass CategoryRuleCondition
    set ::twapi::_coclass_idispatch_guids({000610DC-0000-0000-C000-000000000046}) "{000630DC-0000-0000-C000-000000000046}"

    set _coclass_guids(CategoryRuleCondition) "{000610DC-0000-0000-C000-000000000046}"
    twapi::class create CategoryRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610DC-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610DC-0000-0000-C000-000000000046}"]
            if {[string length "{000630DC-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630DC-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass FormNameRuleCondition
    set ::twapi::_coclass_idispatch_guids({000610DD-0000-0000-C000-000000000046}) "{000630DD-0000-0000-C000-000000000046}"

    set _coclass_guids(FormNameRuleCondition) "{000610DD-0000-0000-C000-000000000046}"
    twapi::class create FormNameRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610DD-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610DD-0000-0000-C000-000000000046}"]
            if {[string length "{000630DD-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630DD-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ToOrFromRuleCondition
    set ::twapi::_coclass_idispatch_guids({000610DE-0000-0000-C000-000000000046}) "{000630DE-0000-0000-C000-000000000046}"

    set _coclass_guids(ToOrFromRuleCondition) "{000610DE-0000-0000-C000-000000000046}"
    twapi::class create ToOrFromRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610DE-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610DE-0000-0000-C000-000000000046}"]
            if {[string length "{000630DE-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630DE-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass AddressRuleCondition
    set ::twapi::_coclass_idispatch_guids({000610FA-0000-0000-C000-000000000046}) "{000630FA-0000-0000-C000-000000000046}"

    set _coclass_guids(AddressRuleCondition) "{000610FA-0000-0000-C000-000000000046}"
    twapi::class create AddressRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610FA-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610FA-0000-0000-C000-000000000046}"]
            if {[string length "{000630FA-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630FA-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass SenderInAddressListRuleCondition
    set ::twapi::_coclass_idispatch_guids({000610DF-0000-0000-C000-000000000046}) "{000630DF-0000-0000-C000-000000000046}"

    set _coclass_guids(SenderInAddressListRuleCondition) "{000610DF-0000-0000-C000-000000000046}"
    twapi::class create SenderInAddressListRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610DF-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610DF-0000-0000-C000-000000000046}"]
            if {[string length "{000630DF-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630DF-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass FromRssFeedRuleCondition
    set ::twapi::_coclass_idispatch_guids({000610FB-0000-0000-C000-000000000046}) "{000630FB-0000-0000-C000-000000000046}"

    set _coclass_guids(FromRssFeedRuleCondition) "{000610FB-0000-0000-C000-000000000046}"
    twapi::class create FromRssFeedRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610FB-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610FB-0000-0000-C000-000000000046}"]
            if {[string length "{000630FB-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630FB-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass SensitivityRuleCondition
    set ::twapi::_coclass_idispatch_guids({00061108-0000-0000-C000-000000000046}) "{00063108-0000-0000-C000-000000000046}"

    set _coclass_guids(SensitivityRuleCondition) "{00061108-0000-0000-C000-000000000046}"
    twapi::class create SensitivityRuleCondition {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061108-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061108-0000-0000-C000-000000000046}"]
            if {[string length "{00063108-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063108-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Rule
    set ::twapi::_coclass_idispatch_guids({000610CD-0000-0000-C000-000000000046}) "{000630CD-0000-0000-C000-000000000046}"

    set _coclass_guids(Rule) "{000610CD-0000-0000-C000-000000000046}"
    twapi::class create Rule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610CD-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610CD-0000-0000-C000-000000000046}"]
            if {[string length "{000630CD-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630CD-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Categories
    set ::twapi::_coclass_idispatch_guids({000610E4-0000-0000-C000-000000000046}) "{000630E4-0000-0000-C000-000000000046}"

    set _coclass_guids(Categories) "{000610E4-0000-0000-C000-000000000046}"
    twapi::class create Categories {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610E4-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610E4-0000-0000-C000-000000000046}"]
            if {[string length "{000630E4-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E4-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Category
    set ::twapi::_coclass_idispatch_guids({000610E3-0000-0000-C000-000000000046}) "{000630E3-0000-0000-C000-000000000046}"

    set _coclass_guids(Category) "{000610E3-0000-0000-C000-000000000046}"
    twapi::class create Category {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610E3-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610E3-0000-0000-C000-000000000046}"]
            if {[string length "{000630E3-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E3-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Table
    set ::twapi::_coclass_idispatch_guids({000610D2-0000-0000-C000-000000000046}) "{000630D2-0000-0000-C000-000000000046}"

    set _coclass_guids(Table) "{000610D2-0000-0000-C000-000000000046}"
    twapi::class create Table {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D2-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D2-0000-0000-C000-000000000046}"]
            if {[string length "{000630D2-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D2-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Row
    set ::twapi::_coclass_idispatch_guids({000610D3-0000-0000-C000-000000000046}) "{000630D3-0000-0000-C000-000000000046}"

    set _coclass_guids(Row) "{000610D3-0000-0000-C000-000000000046}"
    twapi::class create Row {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610D3-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610D3-0000-0000-C000-000000000046}"]
            if {[string length "{000630D3-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630D3-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Columns
    set ::twapi::_coclass_idispatch_guids({000610E1-0000-0000-C000-000000000046}) "{000630E1-0000-0000-C000-000000000046}"

    set _coclass_guids(Columns) "{000610E1-0000-0000-C000-000000000046}"
    twapi::class create Columns {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610E1-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610E1-0000-0000-C000-000000000046}"]
            if {[string length "{000630E1-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E1-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Column
    set ::twapi::_coclass_idispatch_guids({000610E5-0000-0000-C000-000000000046}) "{000630E5-0000-0000-C000-000000000046}"

    set _coclass_guids(Column) "{000610E5-0000-0000-C000-000000000046}"
    twapi::class create Column {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610E5-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610E5-0000-0000-C000-000000000046}"]
            if {[string length "{000630E5-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E5-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass CalendarSharing
    set ::twapi::_coclass_idispatch_guids({000610E2-0000-0000-C000-000000000046}) "{000630E2-0000-0000-C000-000000000046}"

    set _coclass_guids(CalendarSharing) "{000610E2-0000-0000-C000-000000000046}"
    twapi::class create CalendarSharing {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610E2-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610E2-0000-0000-C000-000000000046}"]
            if {[string length "{000630E2-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E2-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass MailItem
    set ::twapi::_coclass_idispatch_guids({00061033-0000-0000-C000-000000000046}) "{00063034-0000-0000-C000-000000000046}"

    set _coclass_guids(MailItem) "{00061033-0000-0000-C000-000000000046}"
    twapi::class create MailItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061033-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061033-0000-0000-C000-000000000046}"]
            if {[string length "{00063034-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063034-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ContactItem
    set ::twapi::_coclass_idispatch_guids({00061031-0000-0000-C000-000000000046}) "{00063021-0000-0000-C000-000000000046}"

    set _coclass_guids(ContactItem) "{00061031-0000-0000-C000-000000000046}"
    twapi::class create ContactItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061031-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061031-0000-0000-C000-000000000046}"]
            if {[string length "{00063021-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063021-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass SimpleItems
    set ::twapi::_coclass_idispatch_guids({00061102-0000-0000-C000-000000000046}) "{00063102-0000-0000-C000-000000000046}"

    set _coclass_guids(SimpleItems) "{00061102-0000-0000-C000-000000000046}"
    twapi::class create SimpleItems {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061102-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061102-0000-0000-C000-000000000046}"]
            if {[string length "{00063102-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063102-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass UserDefinedProperties
    set ::twapi::_coclass_idispatch_guids({00061047-0000-0000-C000-000000000046}) "{00063047-0000-0000-C000-000000000046}"

    set _coclass_guids(UserDefinedProperties) "{00061047-0000-0000-C000-000000000046}"
    twapi::class create UserDefinedProperties {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061047-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061047-0000-0000-C000-000000000046}"]
            if {[string length "{00063047-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063047-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass UserDefinedProperty
    set ::twapi::_coclass_idispatch_guids({0006105C-0000-0000-C000-000000000046}) "{0006305C-0000-0000-C000-000000000046}"

    set _coclass_guids(UserDefinedProperty) "{0006105C-0000-0000-C000-000000000046}"
    twapi::class create UserDefinedProperty {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006105C-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006105C-0000-0000-C000-000000000046}"]
            if {[string length "{0006305C-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006305C-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ExchangeUser
    set ::twapi::_coclass_idispatch_guids({000610C9-0000-0000-C000-000000000046}) "{000630C9-0000-0000-C000-000000000046}"

    set _coclass_guids(ExchangeUser) "{000610C9-0000-0000-C000-000000000046}"
    twapi::class create ExchangeUser {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610C9-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610C9-0000-0000-C000-000000000046}"]
            if {[string length "{000630C9-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630C9-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ExchangeDistributionList
    set ::twapi::_coclass_idispatch_guids({000610CA-0000-0000-C000-000000000046}) "{000630CA-0000-0000-C000-000000000046}"

    set _coclass_guids(ExchangeDistributionList) "{000610CA-0000-0000-C000-000000000046}"
    twapi::class create ExchangeDistributionList {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610CA-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610CA-0000-0000-C000-000000000046}"]
            if {[string length "{000630CA-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630CA-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass SyncObject
    set ::twapi::_coclass_idispatch_guids({00063084-0000-0000-C000-000000000046}) "{00063083-0000-0000-C000-000000000046}"

    set _coclass_guids(SyncObject) "{00063084-0000-0000-C000-000000000046}"
    twapi::class create SyncObject {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063084-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063084-0000-0000-C000-000000000046}"]
            if {[string length "{00063083-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063083-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Accounts
    set ::twapi::_coclass_idispatch_guids({000610C4-0000-0000-C000-000000000046}) "{000630C4-0000-0000-C000-000000000046}"

    set _coclass_guids(Accounts) "{000610C4-0000-0000-C000-000000000046}"
    twapi::class create Accounts {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610C4-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610C4-0000-0000-C000-000000000046}"]
            if {[string length "{000630C4-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630C4-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Stores
    set ::twapi::_coclass_idispatch_guids({000610C6-0000-0000-C000-000000000046}) "{000630C6-0000-0000-C000-000000000046}"

    set _coclass_guids(Stores) "{000610C6-0000-0000-C000-000000000046}"
    twapi::class create Stores {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610C6-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610C6-0000-0000-C000-000000000046}"]
            if {[string length "{000630C6-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630C6-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass SelectNamesDialog
    set ::twapi::_coclass_idispatch_guids({000610C8-0000-0000-C000-000000000046}) "{000630C8-0000-0000-C000-000000000046}"

    set _coclass_guids(SelectNamesDialog) "{000610C8-0000-0000-C000-000000000046}"
    twapi::class create SelectNamesDialog {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610C8-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610C8-0000-0000-C000-000000000046}"]
            if {[string length "{000630C8-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630C8-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass SharingItem
    set ::twapi::_coclass_idispatch_guids({00061067-0000-0000-C000-000000000046}) "{0006302F-0000-0000-C000-000000000046}"

    set _coclass_guids(SharingItem) "{00061067-0000-0000-C000-000000000046}"
    twapi::class create SharingItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061067-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061067-0000-0000-C000-000000000046}"]
            if {[string length "{0006302F-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006302F-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Explorer
    set ::twapi::_coclass_idispatch_guids({00063050-0000-0000-C000-000000000046}) "{00063003-0000-0000-C000-000000000046}"

    set _coclass_guids(Explorer) "{00063050-0000-0000-C000-000000000046}"
    twapi::class create Explorer {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063050-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063050-0000-0000-C000-000000000046}"]
            if {[string length "{00063003-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063003-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Inspector
    set ::twapi::_coclass_idispatch_guids({00063058-0000-0000-C000-000000000046}) "{00063005-0000-0000-C000-000000000046}"

    set _coclass_guids(Inspector) "{00063058-0000-0000-C000-000000000046}"
    twapi::class create Inspector {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063058-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063058-0000-0000-C000-000000000046}"]
            if {[string length "{00063005-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063005-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TimeZones
    set ::twapi::_coclass_idispatch_guids({000610FC-0000-0000-C000-000000000046}) "{000630FC-0000-0000-C000-000000000046}"

    set _coclass_guids(TimeZones) "{000610FC-0000-0000-C000-000000000046}"
    twapi::class create TimeZones {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610FC-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610FC-0000-0000-C000-000000000046}"]
            if {[string length "{000630FC-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630FC-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OlkTimeZoneControl
    set ::twapi::_coclass_idispatch_guids({0006F059-0000-0000-C000-000000000046}) "{00067367-0000-0000-C000-000000000046}"

    set _coclass_guids(OlkTimeZoneControl) "{0006F059-0000-0000-C000-000000000046}"
    twapi::class create OlkTimeZoneControl {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F059-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F059-0000-0000-C000-000000000046}"]
            if {[string length "{00067367-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00067367-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass AppointmentItem
    set ::twapi::_coclass_idispatch_guids({00061030-0000-0000-C000-000000000046}) "{00063033-0000-0000-C000-000000000046}"

    set _coclass_guids(AppointmentItem) "{00061030-0000-0000-C000-000000000046}"
    twapi::class create AppointmentItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061030-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061030-0000-0000-C000-000000000046}"]
            if {[string length "{00063033-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063033-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass MeetingItem
    set ::twapi::_coclass_idispatch_guids({00061036-0000-0000-C000-000000000046}) "{00063062-0000-0000-C000-000000000046}"

    set _coclass_guids(MeetingItem) "{00061036-0000-0000-C000-000000000046}"
    twapi::class create MeetingItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061036-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061036-0000-0000-C000-000000000046}"]
            if {[string length "{00063062-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063062-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass AttachmentSelection
    set ::twapi::_coclass_idispatch_guids({000610F9-0000-0000-C000-000000000046}) "{000630F9-0000-0000-C000-000000000046}"

    set _coclass_guids(AttachmentSelection) "{000610F9-0000-0000-C000-000000000046}"
    twapi::class create AttachmentSelection {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610F9-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610F9-0000-0000-C000-000000000046}"]
            if {[string length "{000630F9-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630F9-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Folder
    set ::twapi::_coclass_idispatch_guids({000610F7-0000-0000-C000-000000000046}) "{00063006-0000-0000-C000-000000000046}"

    set _coclass_guids(Folder) "{000610F7-0000-0000-C000-000000000046}"
    twapi::class create Folder {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610F7-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610F7-0000-0000-C000-000000000046}"]
            if {[string length "{00063006-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063006-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ColumnFormat
    set ::twapi::_coclass_idispatch_guids({0006109E-0000-0000-C000-000000000046}) "{0006309E-0000-0000-C000-000000000046}"

    set _coclass_guids(ColumnFormat) "{0006109E-0000-0000-C000-000000000046}"
    twapi::class create ColumnFormat {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006109E-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006109E-0000-0000-C000-000000000046}"]
            if {[string length "{0006309E-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006309E-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ViewField
    set ::twapi::_coclass_idispatch_guids({0006F09F-0000-0000-C000-000000000046}) "{000630A0-0000-0000-C000-000000000046}"

    set _coclass_guids(ViewField) "{0006F09F-0000-0000-C000-000000000046}"
    twapi::class create ViewField {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F09F-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F09F-0000-0000-C000-000000000046}"]
            if {[string length "{000630A0-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630A0-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OrderFields
    set ::twapi::_coclass_idispatch_guids({0006109A-0000-0000-C000-000000000046}) "{0006309A-0000-0000-C000-000000000046}"

    set _coclass_guids(OrderFields) "{0006109A-0000-0000-C000-000000000046}"
    twapi::class create OrderFields {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006109A-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006109A-0000-0000-C000-000000000046}"]
            if {[string length "{0006309A-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006309A-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OrderField
    set ::twapi::_coclass_idispatch_guids({0006109B-0000-0000-C000-000000000046}) "{0006309B-0000-0000-C000-000000000046}"

    set _coclass_guids(OrderField) "{0006109B-0000-0000-C000-000000000046}"
    twapi::class create OrderField {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006109B-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006109B-0000-0000-C000-000000000046}"]
            if {[string length "{0006309B-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006309B-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ViewFields
    set ::twapi::_coclass_idispatch_guids({000610A1-0000-0000-C000-000000000046}) "{000630A1-0000-0000-C000-000000000046}"

    set _coclass_guids(ViewFields) "{000610A1-0000-0000-C000-000000000046}"
    twapi::class create ViewFields {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610A1-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610A1-0000-0000-C000-000000000046}"]
            if {[string length "{000630A1-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630A1-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ViewFont
    set ::twapi::_coclass_idispatch_guids({0006109D-0000-0000-C000-000000000046}) "{0006309D-0000-0000-C000-000000000046}"

    set _coclass_guids(ViewFont) "{0006109D-0000-0000-C000-000000000046}"
    twapi::class create ViewFont {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006109D-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006109D-0000-0000-C000-000000000046}"]
            if {[string length "{0006309D-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006309D-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass AutoFormatRules
    set ::twapi::_coclass_idispatch_guids({0006F0A2-0000-0000-C000-000000000046}) "{00063094-0000-0000-C000-000000000046}"

    set _coclass_guids(AutoFormatRules) "{0006F0A2-0000-0000-C000-000000000046}"
    twapi::class create AutoFormatRules {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F0A2-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F0A2-0000-0000-C000-000000000046}"]
            if {[string length "{00063094-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063094-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass AutoFormatRule
    set ::twapi::_coclass_idispatch_guids({0006F0A1-0000-0000-C000-000000000046}) "{00063093-0000-0000-C000-000000000046}"

    set _coclass_guids(AutoFormatRule) "{0006F0A1-0000-0000-C000-000000000046}"
    twapi::class create AutoFormatRule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F0A1-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F0A1-0000-0000-C000-000000000046}"]
            if {[string length "{00063093-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063093-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NavigationFolders
    set ::twapi::_coclass_idispatch_guids({000610F1-0000-0000-C000-000000000046}) "{000630F1-0000-0000-C000-000000000046}"

    set _coclass_guids(NavigationFolders) "{000610F1-0000-0000-C000-000000000046}"
    twapi::class create NavigationFolders {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610F1-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610F1-0000-0000-C000-000000000046}"]
            if {[string length "{000630F1-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630F1-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NavigationFolder
    set ::twapi::_coclass_idispatch_guids({000610F2-0000-0000-C000-000000000046}) "{000630F2-0000-0000-C000-000000000046}"

    set _coclass_guids(NavigationFolder) "{000610F2-0000-0000-C000-000000000046}"
    twapi::class create NavigationFolder {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610F2-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610F2-0000-0000-C000-000000000046}"]
            if {[string length "{000630F2-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630F2-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NavigationGroup
    set ::twapi::_coclass_idispatch_guids({000610F0-0000-0000-C000-000000000046}) "{000630F0-0000-0000-C000-000000000046}"

    set _coclass_guids(NavigationGroup) "{000610F0-0000-0000-C000-000000000046}"
    twapi::class create NavigationGroup {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610F0-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610F0-0000-0000-C000-000000000046}"]
            if {[string length "{000630F0-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630F0-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass FormRegion
    set ::twapi::_coclass_idispatch_guids({0006315A-0000-0000-C000-000000000046}) "{0006305A-0000-0000-C000-000000000046}"

    set _coclass_guids(FormRegion) "{0006315A-0000-0000-C000-000000000046}"
    twapi::class create FormRegion {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006315A-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006315A-0000-0000-C000-000000000046}"]
            if {[string length "{0006305A-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006305A-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass MobileItem
    set ::twapi::_coclass_idispatch_guids({000610FE-0000-0000-C000-000000000046}) "{000630FE-0000-0000-C000-000000000046}"

    set _coclass_guids(MobileItem) "{000610FE-0000-0000-C000-000000000046}"
    twapi::class create MobileItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610FE-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610FE-0000-0000-C000-000000000046}"]
            if {[string length "{000630FE-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630FE-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TaskItem
    set ::twapi::_coclass_idispatch_guids({00061032-0000-0000-C000-000000000046}) "{00063035-0000-0000-C000-000000000046}"

    set _coclass_guids(TaskItem) "{00061032-0000-0000-C000-000000000046}"
    twapi::class create TaskItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061032-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061032-0000-0000-C000-000000000046}"]
            if {[string length "{00063035-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063035-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Application
    set ::twapi::_coclass_idispatch_guids({0006F03A-0000-0000-C000-000000000046}) "{00063001-0000-0000-C000-000000000046}"

    set _coclass_guids(Application) "{0006F03A-0000-0000-C000-000000000046}"
    twapi::class create Application {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F03A-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F03A-0000-0000-C000-000000000046}"]
            if {[string length "{00063001-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063001-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass DistListItem
    set ::twapi::_coclass_idispatch_guids({0006103C-0000-0000-C000-000000000046}) "{00063081-0000-0000-C000-000000000046}"

    set _coclass_guids(DistListItem) "{0006103C-0000-0000-C000-000000000046}"
    twapi::class create DistListItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006103C-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006103C-0000-0000-C000-000000000046}"]
            if {[string length "{00063081-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063081-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass DocumentItem
    set ::twapi::_coclass_idispatch_guids({00061061-0000-0000-C000-000000000046}) "{00063020-0000-0000-C000-000000000046}"

    set _coclass_guids(DocumentItem) "{00061061-0000-0000-C000-000000000046}"
    twapi::class create DocumentItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061061-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061061-0000-0000-C000-000000000046}"]
            if {[string length "{00063020-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063020-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Explorers
    set ::twapi::_coclass_idispatch_guids({00063053-0000-0000-C000-000000000046}) "{0006300A-0000-0000-C000-000000000046}"

    set _coclass_guids(Explorers) "{00063053-0000-0000-C000-000000000046}"
    twapi::class create Explorers {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063053-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063053-0000-0000-C000-000000000046}"]
            if {[string length "{0006300A-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006300A-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Inspectors
    set ::twapi::_coclass_idispatch_guids({00063054-0000-0000-C000-000000000046}) "{00063008-0000-0000-C000-000000000046}"

    set _coclass_guids(Inspectors) "{00063054-0000-0000-C000-000000000046}"
    twapi::class create Inspectors {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063054-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063054-0000-0000-C000-000000000046}"]
            if {[string length "{00063008-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063008-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Folders
    set ::twapi::_coclass_idispatch_guids({00063051-0000-0000-C000-000000000046}) "{00063040-0000-0000-C000-000000000046}"

    set _coclass_guids(Folders) "{00063051-0000-0000-C000-000000000046}"
    twapi::class create Folders {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063051-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063051-0000-0000-C000-000000000046}"]
            if {[string length "{00063040-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063040-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Items
    set ::twapi::_coclass_idispatch_guids({00063052-0000-0000-C000-000000000046}) "{00063041-0000-0000-C000-000000000046}"

    set _coclass_guids(Items) "{00063052-0000-0000-C000-000000000046}"
    twapi::class create Items {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063052-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063052-0000-0000-C000-000000000046}"]
            if {[string length "{00063041-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063041-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass JournalItem
    set ::twapi::_coclass_idispatch_guids({00061037-0000-0000-C000-000000000046}) "{00063022-0000-0000-C000-000000000046}"

    set _coclass_guids(JournalItem) "{00061037-0000-0000-C000-000000000046}"
    twapi::class create JournalItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061037-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061037-0000-0000-C000-000000000046}"]
            if {[string length "{00063022-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063022-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NameSpace
    set ::twapi::_coclass_idispatch_guids({0006308B-0000-0000-C000-000000000046}) "{00063002-0000-0000-C000-000000000046}"

    set _coclass_guids(NameSpace) "{0006308B-0000-0000-C000-000000000046}"
    twapi::class create NameSpace {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006308B-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006308B-0000-0000-C000-000000000046}"]
            if {[string length "{00063002-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063002-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NoteItem
    set ::twapi::_coclass_idispatch_guids({00061034-0000-0000-C000-000000000046}) "{00063025-0000-0000-C000-000000000046}"

    set _coclass_guids(NoteItem) "{00061034-0000-0000-C000-000000000046}"
    twapi::class create NoteItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061034-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061034-0000-0000-C000-000000000046}"]
            if {[string length "{00063025-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063025-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OutlookBarGroups
    set ::twapi::_coclass_idispatch_guids({00063056-0000-0000-C000-000000000046}) "{00063072-0000-0000-C000-000000000046}"

    set _coclass_guids(OutlookBarGroups) "{00063056-0000-0000-C000-000000000046}"
    twapi::class create OutlookBarGroups {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063056-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063056-0000-0000-C000-000000000046}"]
            if {[string length "{00063072-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063072-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OutlookBarPane
    set ::twapi::_coclass_idispatch_guids({00063055-0000-0000-C000-000000000046}) "{00063070-0000-0000-C000-000000000046}"

    set _coclass_guids(OutlookBarPane) "{00063055-0000-0000-C000-000000000046}"
    twapi::class create OutlookBarPane {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063055-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063055-0000-0000-C000-000000000046}"]
            if {[string length "{00063070-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063070-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass OutlookBarShortcuts
    set ::twapi::_coclass_idispatch_guids({00063057-0000-0000-C000-000000000046}) "{00063074-0000-0000-C000-000000000046}"

    set _coclass_guids(OutlookBarShortcuts) "{00063057-0000-0000-C000-000000000046}"
    twapi::class create OutlookBarShortcuts {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00063057-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00063057-0000-0000-C000-000000000046}"]
            if {[string length "{00063074-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063074-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass PostItem
    set ::twapi::_coclass_idispatch_guids({0006103A-0000-0000-C000-000000000046}) "{00063024-0000-0000-C000-000000000046}"

    set _coclass_guids(PostItem) "{0006103A-0000-0000-C000-000000000046}"
    twapi::class create PostItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006103A-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006103A-0000-0000-C000-000000000046}"]
            if {[string length "{00063024-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063024-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass RemoteItem
    set ::twapi::_coclass_idispatch_guids({00061060-0000-0000-C000-000000000046}) "{00063023-0000-0000-C000-000000000046}"

    set _coclass_guids(RemoteItem) "{00061060-0000-0000-C000-000000000046}"
    twapi::class create RemoteItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061060-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061060-0000-0000-C000-000000000046}"]
            if {[string length "{00063023-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063023-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ReportItem
    set ::twapi::_coclass_idispatch_guids({00061035-0000-0000-C000-000000000046}) "{00063026-0000-0000-C000-000000000046}"

    set _coclass_guids(ReportItem) "{00061035-0000-0000-C000-000000000046}"
    twapi::class create ReportItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061035-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061035-0000-0000-C000-000000000046}"]
            if {[string length "{00063026-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063026-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TaskRequestAcceptItem
    set ::twapi::_coclass_idispatch_guids({00061052-0000-0000-C000-000000000046}) "{00063038-0000-0000-C000-000000000046}"

    set _coclass_guids(TaskRequestAcceptItem) "{00061052-0000-0000-C000-000000000046}"
    twapi::class create TaskRequestAcceptItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061052-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061052-0000-0000-C000-000000000046}"]
            if {[string length "{00063038-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063038-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TaskRequestDeclineItem
    set ::twapi::_coclass_idispatch_guids({00061053-0000-0000-C000-000000000046}) "{00063039-0000-0000-C000-000000000046}"

    set _coclass_guids(TaskRequestDeclineItem) "{00061053-0000-0000-C000-000000000046}"
    twapi::class create TaskRequestDeclineItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061053-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061053-0000-0000-C000-000000000046}"]
            if {[string length "{00063039-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063039-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TaskRequestItem
    set ::twapi::_coclass_idispatch_guids({00061050-0000-0000-C000-000000000046}) "{00063036-0000-0000-C000-000000000046}"

    set _coclass_guids(TaskRequestItem) "{00061050-0000-0000-C000-000000000046}"
    twapi::class create TaskRequestItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061050-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061050-0000-0000-C000-000000000046}"]
            if {[string length "{00063036-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063036-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TaskRequestUpdateItem
    set ::twapi::_coclass_idispatch_guids({00061051-0000-0000-C000-000000000046}) "{00063037-0000-0000-C000-000000000046}"

    set _coclass_guids(TaskRequestUpdateItem) "{00061051-0000-0000-C000-000000000046}"
    twapi::class create TaskRequestUpdateItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061051-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061051-0000-0000-C000-000000000046}"]
            if {[string length "{00063037-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063037-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Results
    set ::twapi::_coclass_idispatch_guids({00061039-0000-0000-C000-000000000046}) "{0006300C-0000-0000-C000-000000000046}"

    set _coclass_guids(Results) "{00061039-0000-0000-C000-000000000046}"
    twapi::class create Results {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061039-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061039-0000-0000-C000-000000000046}"]
            if {[string length "{0006300C-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006300C-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Views
    set ::twapi::_coclass_idispatch_guids({0006F027-0000-0000-C000-000000000046}) "{0006308D-0000-0000-C000-000000000046}"

    set _coclass_guids(Views) "{0006F027-0000-0000-C000-000000000046}"
    twapi::class create Views {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F027-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F027-0000-0000-C000-000000000046}"]
            if {[string length "{0006308D-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006308D-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Reminder
    set ::twapi::_coclass_idispatch_guids({0006F028-0000-0000-C000-000000000046}) "{000630B0-0000-0000-C000-000000000046}"

    set _coclass_guids(Reminder) "{0006F028-0000-0000-C000-000000000046}"
    twapi::class create Reminder {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F028-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F028-0000-0000-C000-000000000046}"]
            if {[string length "{000630B0-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630B0-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Reminders
    set ::twapi::_coclass_idispatch_guids({0006F029-0000-0000-C000-000000000046}) "{000630B1-0000-0000-C000-000000000046}"

    set _coclass_guids(Reminders) "{0006F029-0000-0000-C000-000000000046}"
    twapi::class create Reminders {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F029-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F029-0000-0000-C000-000000000046}"]
            if {[string length "{000630B1-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630B1-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass StorageItem
    set ::twapi::_coclass_idispatch_guids({000610CB-0000-0000-C000-000000000046}) "{000630CB-0000-0000-C000-000000000046}"

    set _coclass_guids(StorageItem) "{000610CB-0000-0000-C000-000000000046}"
    twapi::class create StorageItem {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610CB-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610CB-0000-0000-C000-000000000046}"]
            if {[string length "{000630CB-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630CB-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NavigationPane
    set ::twapi::_coclass_idispatch_guids({000610F3-0000-0000-C000-000000000046}) "{000630E6-0000-0000-C000-000000000046}"

    set _coclass_guids(NavigationPane) "{000610F3-0000-0000-C000-000000000046}"
    twapi::class create NavigationPane {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610F3-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610F3-0000-0000-C000-000000000046}"]
            if {[string length "{000630E6-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E6-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NavigationGroups
    set ::twapi::_coclass_idispatch_guids({000610F4-0000-0000-C000-000000000046}) "{000630EF-0000-0000-C000-000000000046}"

    set _coclass_guids(NavigationGroups) "{000610F4-0000-0000-C000-000000000046}"
    twapi::class create NavigationGroups {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610F4-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610F4-0000-0000-C000-000000000046}"]
            if {[string length "{000630EF-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630EF-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass DoNotUseMeFolder
    set ::twapi::_coclass_idispatch_guids({000610F8-0000-0000-C000-000000000046}) "{00063006-0000-0000-C000-000000000046}"

    set _coclass_guids(DoNotUseMeFolder) "{000610F8-0000-0000-C000-000000000046}"
    twapi::class create DoNotUseMeFolder {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610F8-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610F8-0000-0000-C000-000000000046}"]
            if {[string length "{00063006-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063006-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TimelineView
    set ::twapi::_coclass_idispatch_guids({00062001-0000-0000-C000-000000000046}) "{0006309C-0000-0000-C000-000000000046}"

    set _coclass_guids(TimelineView) "{00062001-0000-0000-C000-000000000046}"
    twapi::class create TimelineView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00062001-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00062001-0000-0000-C000-000000000046}"]
            if {[string length "{0006309C-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{0006309C-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass MailModule
    set ::twapi::_coclass_idispatch_guids({000610E9-0000-0000-C000-000000000046}) "{000630E9-0000-0000-C000-000000000046}"

    set _coclass_guids(MailModule) "{000610E9-0000-0000-C000-000000000046}"
    twapi::class create MailModule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610E9-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610E9-0000-0000-C000-000000000046}"]
            if {[string length "{000630E9-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630E9-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass CalendarModule
    set ::twapi::_coclass_idispatch_guids({000610EA-0000-0000-C000-000000000046}) "{000630EA-0000-0000-C000-000000000046}"

    set _coclass_guids(CalendarModule) "{000610EA-0000-0000-C000-000000000046}"
    twapi::class create CalendarModule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610EA-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610EA-0000-0000-C000-000000000046}"]
            if {[string length "{000630EA-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630EA-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ContactsModule
    set ::twapi::_coclass_idispatch_guids({000610EB-0000-0000-C000-000000000046}) "{000630EB-0000-0000-C000-000000000046}"

    set _coclass_guids(ContactsModule) "{000610EB-0000-0000-C000-000000000046}"
    twapi::class create ContactsModule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610EB-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610EB-0000-0000-C000-000000000046}"]
            if {[string length "{000630EB-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630EB-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TasksModule
    set ::twapi::_coclass_idispatch_guids({000610EC-0000-0000-C000-000000000046}) "{000630EC-0000-0000-C000-000000000046}"

    set _coclass_guids(TasksModule) "{000610EC-0000-0000-C000-000000000046}"
    twapi::class create TasksModule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610EC-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610EC-0000-0000-C000-000000000046}"]
            if {[string length "{000630EC-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630EC-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass JournalModule
    set ::twapi::_coclass_idispatch_guids({000610ED-0000-0000-C000-000000000046}) "{000630ED-0000-0000-C000-000000000046}"

    set _coclass_guids(JournalModule) "{000610ED-0000-0000-C000-000000000046}"
    twapi::class create JournalModule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610ED-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610ED-0000-0000-C000-000000000046}"]
            if {[string length "{000630ED-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630ED-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass NotesModule
    set ::twapi::_coclass_idispatch_guids({000610EE-0000-0000-C000-000000000046}) "{000630EE-0000-0000-C000-000000000046}"

    set _coclass_guids(NotesModule) "{000610EE-0000-0000-C000-000000000046}"
    twapi::class create NotesModule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610EE-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610EE-0000-0000-C000-000000000046}"]
            if {[string length "{000630EE-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630EE-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TableView
    set ::twapi::_coclass_idispatch_guids({00062000-0000-0000-C000-000000000046}) "{00063096-0000-0000-C000-000000000046}"

    set _coclass_guids(TableView) "{00062000-0000-0000-C000-000000000046}"
    twapi::class create TableView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00062000-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00062000-0000-0000-C000-000000000046}"]
            if {[string length "{00063096-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063096-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass IconView
    set ::twapi::_coclass_idispatch_guids({00062004-0000-0000-C000-000000000046}) "{00063097-0000-0000-C000-000000000046}"

    set _coclass_guids(IconView) "{00062004-0000-0000-C000-000000000046}"
    twapi::class create IconView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00062004-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00062004-0000-0000-C000-000000000046}"]
            if {[string length "{00063097-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063097-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass CardView
    set ::twapi::_coclass_idispatch_guids({00062002-0000-0000-C000-000000000046}) "{00063098-0000-0000-C000-000000000046}"

    set _coclass_guids(CardView) "{00062002-0000-0000-C000-000000000046}"
    twapi::class create CardView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00062002-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00062002-0000-0000-C000-000000000046}"]
            if {[string length "{00063098-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063098-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass CalendarView
    set ::twapi::_coclass_idispatch_guids({00062003-0000-0000-C000-000000000046}) "{00063099-0000-0000-C000-000000000046}"

    set _coclass_guids(CalendarView) "{00062003-0000-0000-C000-000000000046}"
    twapi::class create CalendarView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00062003-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00062003-0000-0000-C000-000000000046}"]
            if {[string length "{00063099-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063099-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass BusinessCardView
    set ::twapi::_coclass_idispatch_guids({0006200B-0000-0000-C000-000000000046}) "{000630A2-0000-0000-C000-000000000046}"

    set _coclass_guids(BusinessCardView) "{0006200B-0000-0000-C000-000000000046}"
    twapi::class create BusinessCardView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006200B-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006200B-0000-0000-C000-000000000046}"]
            if {[string length "{000630A2-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630A2-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass FormRegionStartup
    set ::twapi::_coclass_idispatch_guids({00061059-0000-0000-C000-000000000046}) "{00063059-0000-0000-C000-000000000046}"

    set _coclass_guids(FormRegionStartup) "{00061059-0000-0000-C000-000000000046}"
    twapi::class create FormRegionStartup {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061059-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061059-0000-0000-C000-000000000046}"]
            if {[string length "{00063059-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063059-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass TimeZone
    set ::twapi::_coclass_idispatch_guids({000610FD-0000-0000-C000-000000000046}) "{000630FD-0000-0000-C000-000000000046}"

    set _coclass_guids(TimeZone) "{000610FD-0000-0000-C000-000000000046}"
    twapi::class create TimeZone {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610FD-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610FD-0000-0000-C000-000000000046}"]
            if {[string length "{000630FD-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630FD-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass SolutionsModule
    set ::twapi::_coclass_idispatch_guids({000610FF-0000-0000-C000-000000000046}) "{000630FF-0000-0000-C000-000000000046}"

    set _coclass_guids(SolutionsModule) "{000610FF-0000-0000-C000-000000000046}"
    twapi::class create SolutionsModule {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{000610FF-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{000610FF-0000-0000-C000-000000000046}"]
            if {[string length "{000630FF-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630FF-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass Conversation
    set ::twapi::_coclass_idispatch_guids({00061101-0000-0000-C000-000000000046}) "{00063101-0000-0000-C000-000000000046}"

    set _coclass_guids(Conversation) "{00061101-0000-0000-C000-000000000046}"
    twapi::class create Conversation {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061101-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061101-0000-0000-C000-000000000046}"]
            if {[string length "{00063101-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063101-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass AccountSelector
    set ::twapi::_coclass_idispatch_guids({00061103-0000-0000-C000-000000000046}) "{00063103-0000-0000-C000-000000000046}"

    set _coclass_guids(AccountSelector) "{00061103-0000-0000-C000-000000000046}"
    twapi::class create AccountSelector {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061103-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061103-0000-0000-C000-000000000046}"]
            if {[string length "{00063103-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063103-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ConversationHeader
    set ::twapi::_coclass_idispatch_guids({00061107-0000-0000-C000-000000000046}) "{00063107-0000-0000-C000-000000000046}"

    set _coclass_guids(ConversationHeader) "{00061107-0000-0000-C000-000000000046}"
    twapi::class create ConversationHeader {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{00061107-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{00061107-0000-0000-C000-000000000046}"]
            if {[string length "{00063107-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063107-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass PeopleView
    set ::twapi::_coclass_idispatch_guids({0006200C-0000-0000-C000-000000000046}) "{000630A3-0000-0000-C000-000000000046}"

    set _coclass_guids(PeopleView) "{0006200C-0000-0000-C000-000000000046}"
    twapi::class create PeopleView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006200C-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006200C-0000-0000-C000-000000000046}"]
            if {[string length "{000630A3-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630A3-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass ThreadView
    set ::twapi::_coclass_idispatch_guids({0006200D-0000-0000-C000-000000000046}) "{000630A4-0000-0000-C000-000000000046}"

    set _coclass_guids(ThreadView) "{0006200D-0000-0000-C000-000000000046}"
    twapi::class create ThreadView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006200D-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006200D-0000-0000-C000-000000000046}"]
            if {[string length "{000630A4-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630A4-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass PreviewPane
    set ::twapi::_coclass_idispatch_guids({0006F0C5-0000-0000-C000-000000000046}) "{00063063-0000-0000-C000-000000000046}"

    set _coclass_guids(PreviewPane) "{0006F0C5-0000-0000-C000-000000000046}"
    twapi::class create PreviewPane {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006F0C5-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006F0C5-0000-0000-C000-000000000046}"]
            if {[string length "{00063063-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{00063063-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass MessageListView
    set ::twapi::_coclass_idispatch_guids({0006200E-0000-0000-C000-000000000046}) "{000630A6-0000-0000-C000-000000000046}"

    set _coclass_guids(MessageListView) "{0006200E-0000-0000-C000-000000000046}"
    twapi::class create MessageListView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006200E-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006200E-0000-0000-C000-000000000046}"]
            if {[string length "{000630A6-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630A6-0000-0000-C000-000000000046}"
            }
        }
    }

    # Coclass SearchView
    set ::twapi::_coclass_idispatch_guids({0006200F-0000-0000-C000-000000000046}) "{000630B3-0000-0000-C000-000000000046}"

    set _coclass_guids(SearchView) "{0006200F-0000-0000-C000-000000000046}"
    twapi::class create SearchView {
        superclass ::twapi::Automation
        constructor {args} {
            set ifc [twapi::com_create_instance "{0006200F-0000-0000-C000-000000000046}" -interface IDispatch -raw {*}$args]
            next [twapi::IDispatchProxy new $ifc "{0006200F-0000-0000-C000-000000000046}"]
            if {[string length "{000630B3-0000-0000-C000-000000000046}"]} {
                my -interfaceguid "{000630B3-0000-0000-C000-000000000046}"
            }
        }
    }
}

