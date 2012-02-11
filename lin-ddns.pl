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

our ($apiKey, $domainID, $resourceID, $debug, @listURL);

####
# begin configuration section
#
# this can be obtained from your "My Porifle" link at
# the top right of the Linode Manager
$apiKey = "";

# this can be obtained by using the domain.list API function:
# https://api.linode.com/?api_key=$apiKey&api_action=domain.list
$domainID = "";

# this can be obtained by using the domain.resource.list API function:
# https://api.linode.com/?api_key=$apiKey&api_action=domain.resource.list&domainid=$domainID
$resourceID = "";

@listURL = (
	"http://v4.ipv6-test.com/api/myip.php",
	"http://whatismyip.org/",
	"http://ifconfig.me/ip",
	"http://automation.whatismyip.com/n09230945.asp"
);

# debug output - higher verbosity inherits less verbose logging
# 0 - no debugging
# 1 - errors only logged to syslog
# 2 - warnings logged to syslog
# 3 - info logged to syslog (default)
# 4 - errors+warnings+info printed
# 5 - printing of additional information
# $debug = "3";

logger_prefix("lin-ddns:");
#
# end configuration section
####

# building some variables / settings needed for operation
logger_prefix("lin-ddns:");
$debug = 3 unless defined $debug;
our $configFile = "/var/cache/lin-ddns.yml";
our $regexIP='^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))(?![\\d])';
my $urlLen = @listURL;
my $urlNum;

unless (-e $configFile) {
	slog(3, "\"" . $configFile . "\" doesn't exist. attempting to create file");
	ymlCreate();
}

my $fileURL = ymlGet();
say("from file: fileURL: " . $fileURL) if ($debug == 5);

$fileURL = 9001 if ($fileURL !~ /^[0-9]*$/);
say("post sanity: fileURL: " . $fileURL) if ($debug == 5);

if ($fileURL + 1 >= $urlLen ) { $urlNum = 0; } else { $urlNum = $fileURL + 1; }
say("urlLen: " . $urlLen . " | urlNum: ". $urlNum) if ($debug == 5);

my ($extIP, $urlUsed) = getExtIP($urlNum, \@listURL, $urlLen);
say("extIP: " . $extIP . " | urlUsed: " . $urlUsed) if ($debug == 5);

my $setIP = api_getTarget();

if ($extIP ne $setIP) {
	my $update = api_updateTarget($extIP);
	if (defined $update) {
		ymlWrite($urlUsed, $extIP);
		slog(3, "the zone has been updated with the target " . $extIP);
		exit;
	} else {
		ymlWrite($urlUsed);
		slog(1, "the external IP address has changed, however there was an error trying to update target to " . $extIP);
		exit 1;
	}
} else {
	ymlWrite($urlUsed);
	slog(3, "the external IP address (" . $extIP . ") has not changed");
	exit;
}

sub slog {
	if ($debug >= 1) {
		my $level = shift;
		my $message = shift;
		switch ($level) {
			case 3 {
				info($message) if ($level <= $debug);
			}
			case 2 {
				warning($message) if ($level <= $debug);
			}
			case 1 {
				error($message) if ($level <= $debug);
			}
			else { warning("incorrect value used for message level on subroutine slog call on line " . __LINE__); }
		}

		if ($debug >= 4) {
			my $prefix;
			$prefix = "[error] " if ($level == 1);
			$prefix = "[warning] " if ($level == 2);
			$prefix = "[info] " if ($level == 3);
			say($prefix . $message);
		}
	}
}

sub ymlCreate {
    my $yaml = YAML::Tiny->new;
    $yaml->[0]->{url} = '9001';
    $yaml->write($configFile);
    if (-e $configFile) {
        slog(3, "file created successfully");
    } else {
        slog(1, "crap, something didn't go as planned. file does not appear to have been created. exiting");
        exit 1;
    }
}

sub ymlGet {
    my $yaml = YAML::Tiny->new;
    $yaml = YAML::Tiny->read($configFile);
    my $url = $yaml->[0]->{url};
    return $url;
}

sub ymlWrite {
    my $url = shift;
    my $yaml = YAML::Tiny->new;
    $yaml->[0]->{url} = $url;
    $yaml->write($configFile);
}

sub getExtIP {
    my ($index, $list, $listLen) = @_;
    my $extIP;
    my $run = 1;

    my $mech = WWW::Mechanize->new(
        agent=>"WWW-Mechanize/$WWW::Mechanize::VERSION (theckman/lin-ddns.pl)",
        onerror=>sub { slog(2,"something happened when trying to connect to " . $list->[$index]); }
		);

    while ($run <= $listLen) {
        $mech->get($list->[$index]);
        $extIP = $mech->content(format=>'text');

        if ($extIP !~ /$regexIP/ && $mech->status() == 200) {
            slog(2, "incorrect value obtained from " . $list->[$index] . ". trying next url");
            next;
        } elsif ($run == $listLen && $extIP !~ /$regexIP/) {
            slog(1, "unable to determine external IP address for some reason. do you have an active network connection? exiting");
            exit 1;
        } elsif ($extIP =~ /$regexIP/ && $mech->status() == 200) {  $extIP = $1; last; }

    } continue {
        if ($index + 1 == @$list ) { $index = 0; } else { $index++; };
        $run++;
    }
    return ($extIP, $index);
}

sub api_getTarget {
	my $linApi = new WebService::Linode( apikey => $apiKey );
	my $domainResource = $linApi->domain_resource_list(domainid => $domainID, resourceid => $resourceID);
	return $domainResource->[0]->{target};
}

sub api_updateTarget {
	my $newIP = shift;
	my $linApi = new WebService::Linode( apikey => $apiKey );
	return $linApi->domain_resource_update(domainid => $domainID, resourceid => $resourceID, target => $newIP);
}
