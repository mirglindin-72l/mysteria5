# Copyright: 2007-2025 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Outlook {

    namespace ensemble create

    namespace export GetAccountId
    namespace export GetAccountSmtpAddresses
    namespace export GetNumAccounts

    proc GetNumAccounts { appId } {
        # Get the number of Outlook accounts.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns the number of Outlook accounts.
        #
        # See also: GetAccountSmtpAddresses GetAccountId SendMail

        set accounts [$appId -with { Session } Accounts]
        set numAccounts [$accounts Count]
        Cawt Destroy $accounts
        return $numAccounts
    }

    proc GetAccountSmtpAddresses { appId } {
        # Get a list of account SMTP addresses.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns a list of account SMTP addresses.
        #
        # See also: GetNumAccounts GetAccountId SendMail

        set accounts [$appId -with { Session } Accounts]
        set numAccounts [$accounts Count]

        set addressList [list]
        for { set i 1 } { $i <= $numAccounts } { incr i } {
            set accountId [$accounts Item $i]
            lappend addressList [$accountId SmtpAddress]
            Cawt Destroy $accountId
        }
        Cawt Destroy $accounts
        return $addressList
    }

    proc GetAccountId { appId indexOrName } {
        # Get an account by its index or SMTP address.
        #
        # appId       - Identifier of the Outlook instance.
        # indexOrName - Index or SMTP address of the account.
        #
        # Returns the identifier of the account object.
        #
        # The first account has index 1.
        #
        # If the index is out of bounds or the SMTP address 
        # does not exist, an error is thrown.
        #
        # See also: GetNumAccounts GetAccountSmtpAddresses SendMail

        set accounts [$appId -with { Session } Accounts]
        set numAccounts [$accounts Count]

        if { [string is integer -strict $indexOrName] } {
            set index [expr int($indexOrName)]
            if { $index < 1 || $index > $numAccounts } {
                Cawt Destroy $accounts
                error "GetAccountId: Invalid account index $index given."
            }
            set accountId [$accounts Item $index]
            Cawt Destroy $accounts
            return $accountId
        } else {
            set smtpAddress [string tolower $indexOrName]
            for { set i 1 } { $i <= $numAccounts } { incr i } {
                set accountId [$accounts Item $i]
                if { [string tolower [$accountId SmtpAddress]] eq $smtpAddress } {
                    Cawt Destroy $accounts
                    return $accountId
                }
                Cawt Destroy $accountId
            }
            error "GetAccountId: No account with address $smtpAddress"
        }
    }
}
