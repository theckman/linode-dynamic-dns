#Introduction

Like many other people on the internet I used a DynDNS free account to be able to have a DNS record that always pointed to my home address.  As my home address has a dynamic IP address, I could easily configure my router to poke DynDNS every so often to update the record.

A short time ago my DynDNS free account stopped working out of the blue without any announcement or explanation as to why.  I imagine DynDNS felt it best to discontinue their free service even when they offered to keep us on-board.

The failure of the DynDNS DNS entry meant my (hastily built) Nagios system was upset as it could no longer determine the DNS for my house and could not do it's monitoring thing.

#The Script

All of my DNS is hosted through [Linode](http://www.linode.com/?r=78a747e2c08ffb6618e260c3c62f536687b9159c), so I felt it made sense to build a script that would use the [Linode API](http://www.linode.com/api) to update my records and effectively build a "DynDNS" system.

This script is used to update a specified 'A' record in the [Linode DNS Manager](http://www.linode.com/?r=78a747e2c08ffb6618e260c3c62f536687b9159c) using the [Linode API](http://www.linode.com/api).  The script is a port of my [Hurricane Electric IPv4 Endpoint Updater Perl script](https://github.com/theckman/he-ipv4-perl) so a lot of the code has been altered and improved.  These improvements will also make it back to the original project.

#More Coming Soon

While I am confident the script is ready for use (as I have implemented it this evening), I still need to write some documentation to explain the installation.

#License
Copyright (c) 2012 Tim Heckman and contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
