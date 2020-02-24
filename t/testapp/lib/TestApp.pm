package TestApp;

use strict;
use warnings;
no warnings 'experimental::signatures';;
use TestApp::Builder;

our $VERSION = '1';

TestApp::Builder->new(
    appname => __PACKAGE__,
    version => $VERSION
)->bootstrap;
