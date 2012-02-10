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
