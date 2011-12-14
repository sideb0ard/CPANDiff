#!/usr/bin/perl -w
use strict;
$|++;

unless ($ARGV[1]) {
    print "Usage: ./CompareHostCpanModules.pl login\@host1 login\@host2\n";
    exit;
}

my $host1 = $ARGV[0];
my $host2 = $ARGV[1];

my $clientprog = "/tmp/clientpl"; # THERES PROB A WAY TO PASS THROUGH THE WHOLE SCRIPT BUT THIS IS EASIEr FoR NOW
my $CLIENT = << 'END';
    use ExtUtils::Installed;
    my $instmod = ExtUtils::Installed->new();
    foreach my $module ($instmod->modules()) {
        my $version = $instmod->version($module) || "???";
        print "$module = $version\n";
    }
END

open(CLIENT,">$clientprog") || die "OH YA! Couldnae open yer $clientprog for writing : $!\n";;
print CLIENT $CLIENT;

my $host1modulelist = ssh($host1);
my $host2modulelist = ssh($host2);

print "HOST1:::\n";
foreach my $k (keys %$host1modulelist) {
#    print "$k IS MUTHAFUCKIN ${$host1modulelist}{$k}\n";
    if (${$host2modulelist}{$k}) {
        print "$host1 and $host2 both have $k\n";
        if (${$host1modulelist}{$k} eq ${$host2modulelist}{$k}) {
            print "ALL GOOD - BOTH HAVE $k and version is ${$host1modulelist}{$k}\n";
        } else {
            print "BOTH HAVE $k  - but $host1 has version ${$host1modulelist}{$k} whereas $host2 has ${$host2modulelist}{$k}\n";
        } 
    } else {
        print "$host1 has $k - but $host2 doesn't\n";
    }
}

sub ssh {
    my $host = shift;
    my $ssh = "/usr/bin/ssh $host '(perl)' < $clientprog";
    print "SSH is\n$ssh\n";
    my $hostmodulesblob = `$ssh`;
    my %hostmodulelist = split(/[=\n]/, $hostmodulesblob);
    return (\%hostmodulelist);
}


#print "RARA!!!$hostmodulelist\n";
