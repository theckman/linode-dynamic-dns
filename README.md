#Introduction

Like many other people on the internet I used a DynDNS free account to be able to have a DNS record that always pointed to my home address.  As my home address has a dynamic IP address, I could easily configure my router to poke DynDNS every so often to update the record.

A short time ago my DynDNS free account stopped working out of the blue without any announcement or explanation as to why.  I imagine DynDNS felt it best to discontinue their free service even when they offered to keep us on-board.

The failure of the DynDNS DNS entry meant my (hastily built) Nagios system was upset as it could no longer determine the DNS for my house and could not do it's monitoring thing.

#The Script

All of my DNS is hosted through [Linode](http://www.linode.com/?r=78a747e2c08ffb6618e260c3c62f536687b9159c), so I felt it made sense to build a script that would use the [Linode API](http://www.linode.com/api) to update my records and effectively build a "DynDNS" system.

This script is used to update a specified 'A' record in the [Linode DNS Manager](http://www.linode.com/?r=78a747e2c08ffb6618e260c3c62f536687b9159c) using the [Linode API](http://www.linode.com/api).  The script is a port of my [Hurricane Electric IPv4 Endpoint Updater Perl script](https://github.com/theckman/he-ipv4-perl) so a lot of the code has been altered and improved.  These improvements will also make it back to the original project.

#More Coming Soon

While I am confident the script is ready for use (as I have implemented it this evening), I still need to write some documentation to explain the installation.
