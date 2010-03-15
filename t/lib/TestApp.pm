package TestApp;

use strict;
use warnings;

use TestApp::Builder;

TestApp::Builder->new( appname => __PACKAGE__ )->bootstrap;


1;
