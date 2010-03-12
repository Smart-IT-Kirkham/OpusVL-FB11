package TestApp;

use strict;
use warnings;

use TestApp::Builder;

TestApp::Builder->new( appname => __PACKAGE__ )->bootstrap;


### Enable the tests to work...
##my $dsn = $ENV{TESTAPP_DSN} ||= 'dbi:SQLite:testapp.db';
##__PACKAGE__->config
##(
##    'Model::SimpleCMS'  =>
##    {
##        connect_info => [ $dsn, '', '', { AutoCommit => 1 } ],
##    }
##);
##
##__PACKAGE__->setup;

1;
