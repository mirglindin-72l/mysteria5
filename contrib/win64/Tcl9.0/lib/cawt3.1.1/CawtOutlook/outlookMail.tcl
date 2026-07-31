# Copyright: 2007-2025 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

namespace eval Outlook {

    namespace ensemble create

    namespace export CreateMail
    namespace export CreateHtmlMail
    namespace export GetMailIds
    namespace export GetMailSubjects
    namespace export SendMail

    proc _CreateMail { appId mailType recipientList { subject "" } { body "" } { attachmentList {} } } {
        set mailId [$appId CreateItem $::Outlook::olMailItem]

        $mailId Display
        foreach recipient $recipientList {
            $mailId -with { Recipients } Add $recipient
        }
        if { $mailType eq "text" } {
            set sig [$mailId Body]
            $mailId Body [format "%s\n%s" $body $sig]
        } else {
            set sig [$mailId HtmlBody]
            $mailId HtmlBody [format "%s %s" $body $sig]
        }
        $mailId Subject $subject
        foreach attachment $attachmentList {
            $mailId -with { Attachments } Add [file nativename [file normalize $attachment]]
        }
        return $mailId
    }

    proc CreateMail { appId recipientList { subject "" } { body "" } { attachmentList {} } } {
        # Create a new Outlook text mail.
        #
        # appId          - Identifier of the Outlook instance.
        # recipientList  - List of mail addresses.
        # subject        - Subject text.
        # body           - Mail body text.
        # attachmentList - List of files used as attachment.
        #
        # Returns the identifier of the new mail object.
        #
        # See also: CreateHtmlMail SendMail

        return [Outlook::_CreateMail $appId "text" $recipientList $subject $body $attachmentList]
    }

    proc CreateHtmlMail { appId recipientList { subject "" } { body "" } { attachmentList {} } } {
        # Create a new Outlook HTML mail.
        #
        # appId          - Identifier of the Outlook instance.
        # recipientList  - List of mail addresses.
        # subject        - Subject text.
        # body           - Mail body text in HTML format.
        # attachmentList - List of files used as attachment.
        #
        # Returns the identifier of the new mail object.
        #
        # See also: CreateMail SendMail

        return [Outlook::_CreateMail $appId "html" $recipientList $subject $body $attachmentList]
    }

    proc SendMail { mailId args } {
        # Send an Outlook mail.
        #
        # mailId - Identifier of the Outlook mail object.
        # args   - Options described below.
        #
        # -account <accId>   - Send mail using the specified account identifier.
        #                      Default: First account.
        # -onbehalf <string> - Send mail using the specified mail address.
        #                      Sets the mail header field `From`.
        #
        # Returns no value.
        #
        # See also: CreateMail CreateHtmlMail GetAccountId

        variable sTypeLibWorkaround

        if { ! [info exists sTypeLibWorkaround] } {
            # SendUsingAccount needs "putref", not "put", despite what the type library says.
            # See https://github.com/apnadkarni/twapi/issues/15
            ::twapi::dispatch_prototype_set {{00063034-0000-0000-C000-000000000046}} SendUsingAccount 0 8 {64209 0 8 24 {{9 1}} {}}
            set sTypeLibWorkaround 1
        }

        foreach { key value } $args {
            if { $value eq "" } {
                error "SendMail: No value specified for key \"$key\"."
            }
            switch -exact -nocase -- $key {
                "-account"  { set accountId $value }
                "-onbehalf" { set fromMail  $value }
                default    { error "SendMail: Unknown key \"$key\" specified." }
            }
        }

        if { [info exists fromMail] } {
            $mailId SentOnBehalfOfName $fromMail
        }
        if { [info exists accountId] } {
            $mailId -putref SendUsingAccount $accountId
        }
        $mailId Send
    }

    proc GetMailIds { appId } {
        # Get a list of mail identifiers.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns a list of mail identifiers.
        #
        # See also: GetMailSubjects CreateMail SendMail 

        set idList [list]
        foreach { name folderId } [Outlook::GetFoldersRecursive $appId $::Outlook::olMailItem] {
            set numItems [$folderId -with { Items } Count]
            if { $numItems > 0 } {
                for { set i 1 } { $i <= $numItems } { incr i } {
                    lappend idList [$folderId -with { Items } Item $i]
                }
            }
        }
        return $idList
    }

    proc GetMailSubjects { appId } {
        # Get a list of mail subjects.
        #
        # appId - Identifier of the Outlook instance.
        #
        # Returns a list of mail subjects.
        #
        # See also: GetMailIds CreateMail SendMail 

        set subjectList [list]
        foreach { name folderId } [Outlook::GetFoldersRecursive $appId $::Outlook::olMailItem] {
            set numItems [$folderId -with { Items } Count]
            if { $numItems > 0 } {
                for { set i 1 } { $i <= $numItems } { incr i } {
                    set mailId [$folderId -with { Items } Item $i]
                    lappend subjectList [$mailId Subject]
                    Cawt Destroy $mailId
                }
            }
        }
        return $subjectList
    }
}
