#1/usr/bin/perl

use 5.10.1;
use warnings;
use strict;

use Switch;

use Logger::Syslog;
use YAML::Tiny;
use LWP::Protocol::https;
use WWW::Mechanize;

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
