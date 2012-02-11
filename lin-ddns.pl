#!/usr/bin/perl

use 5.10.1;
use warnings;
use strict;

use Switch;

use Logger::Syslog;
use YAML::Tiny;
use LWP::Protocol::https;
use WWW::Mechanize;
use WebService::Linode;

use Data::Dumper;

our ($apiKey, $domainID, $resourceID, $debug, @listURL);

####
# begin configuration section
#
$apiKey = "";

$domainID = "";

$resourceID = "";

@listURL = (
	"http://v4.ipv6-test.com/api/myip.php",
	"http://whatismyip.org/",
	"http://ifconfig.me/ip",
	"http://automation.whatismyip.com/n09230945.asp"
);


# $debug = "3";
logger_prefix("lin-ddns:");
#
# end configuration section
####

logger_prefix("lin-ddns:");
$debug = 3 unless defined $debug;
our $configFile = "/var/cache/lin-ddns.yml";
our $regexIP='^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))(?![\\d])';

our $linApi = new WebService::Linode( apikey => $apiKey );

sub slog {
	if ($debug >= 1) {
		my $level = shift;
		my $message = shift;
		switch ($level) {
			case 3 {
				if ($level <= $debug) { info($message); }
			}
			case 2 {
				if ($level <= $debug) { warning($message); }
			}
			case 1 {
				if ($level <= $debug) { error($message); }
			}
			else { warning("incorrect value used for message level on subroutine slog call on line " . __LINE__); }
		}

		if ($debug >= 4) {
			my $prefix;
			if ($level == 1) { $prefix = "[error] "; }
			elsif ($level == 2) { $prefix = "[warning] "; }
			elsif ($level == 3) { $prefix = "[info] "; }
			say($prefix . $message);
		}
	}
}

# this creates a default yaml file with useless yet sane values
sub ymlCreate {
    my $yaml = YAML::Tiny->new;
    $yaml->[0]->{url} = '9001';
    $yaml->write($configFile);
    if (-e $configFile) {
        slog("file created successfully", 3);
    } else {
        slog("crap, something didn't go as planned. file does not appear to have been created. exiting", 1);
        exit 1;
    }
}

# pulls values from yaml file and spits them back
sub ymlGet {
    my $yaml = YAML::Tiny->new;
    $yaml = YAML::Tiny->read($configFile);
    my $url = $yaml->[0]->{url};
    return $url;
}

# writes the meaningful values to the yaml file
sub ymlWrite {
    my $url = shift;
    my $yaml = YAML::Tiny->new;
    $yaml->[0]->{url} = $url;
    $yaml->write($configFile);
}

# gets the external IP address using one of the URLs from @lishURL
sub getExtIP {
    my ($index, $list, $listLen) = @_;
    my $extIP;
    my $run = 1;

    # creates new mechanize for pulling the data. sets custom user agent to pretend to be curl and catches errors
    my $mech = WWW::Mechanize->new(
        agent=>"curl/7.21.0 (i486-pc-linux-gnu) libcurl/7.21.0 WWW-Mechanize/$WWW::Mechanize::VERSION (theckman/he-ipv4.pl)",
        onerror=>sub { slog("something happened when trying to connect to " . $list->[$index], 2); } );

    # loop will run as many times as there are values in the URL list.
    while ($run <= $listLen) {
        # gets the URL and throws the content in to $extIP
        $mech->get($list->[$index]);
        $extIP = $mech->content(format=>'text');

        # the content is matched against regext to make sure we got an IP.  Also makes sure HTTP status 200
        # if not try again with different URL until loop ends. if no URL is obtained exit 1
        if ($extIP !~ /$regexIP/ && $mech->status() == 200) {
            slog("incorrect value obtained from " . $list->[$index] . ". trying next url", 2);
            next;
        } elsif ($run == $listLen && $extIP !~ /$regexIP/) {
            slog("unable to determine external IP address for some reason. do you have an active network connection? exiting", 1);
            exit 1;
        } elsif ($extIP =~ /$regexIP/ && $mech->status() == 200) {  $extIP = $1; last; }

    } continue {
        if ($index + 1 == @$list ) { $index = 0; } else { $index++; };
        $run++;
    }
    return ($extIP, $index);
}
