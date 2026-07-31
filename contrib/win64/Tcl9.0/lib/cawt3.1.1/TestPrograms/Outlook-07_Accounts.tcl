# Test account functionality of the CawtOutlook package.
#
# Copyright: 2007-2025 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

if { [file exists "SetTestPathes.tcl"] } {
    source "SetTestPathes.tcl"
}
set retVal [catch {package require cawt} pkgVersion]

set appId [Outlook Open]

puts ""
puts "Outlook has [Outlook GetNumAccounts $appId] accounts."
set smtpAddresses [Outlook GetAccountSmtpAddresses $appId]

for { set i 1 } { $i <= [Outlook GetNumAccounts $appId] } { incr i } {
    set accountId1 [Outlook GetAccountId $appId $i]
    puts "Account $i:"
    puts "  User name   : [$accountId1 UserName]"
    puts "  Display name: [$accountId1 DisplayName]"
    puts "  SMTP address: [$accountId1 SmtpAddress]"
    set accountId2 [Outlook GetAccountId $appId [$accountId1 SmtpAddress]]
    Cawt CheckString [$accountId1 SmtpAddress] [$accountId2 SmtpAddress] "SMTP address"
    Cawt CheckString [$accountId1 SmtpAddress] [lindex $smtpAddresses [expr $i-1]] "SMTP address"
    Cawt Destroy $accountId1
    Cawt Destroy $accountId2
}
puts ""

Cawt PrintNumComObjects

Cawt CheckBoolean true [Cawt IsAppIdValid $appId] "IsAppIdValid"

if { [lindex $argv 0] eq "auto" } {
    Outlook Quit $appId
    Cawt Destroy
    Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
    exit 0
}
Cawt Destroy
Cawt CheckBoolean false [Cawt IsAppIdValid $appId] "IsAppIdValid"
