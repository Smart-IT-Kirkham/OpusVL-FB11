#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

# setup library path
use FindBin qw($Bin);
use lib "$Bin/lib";

BEGIN { $ENV{TESTAPP_DSN} = 'dbi:SQLite:t/lib/testapp.db'; }

# make sure testapp works
use ok 'TestApp';

# a live test against TestApp, the test application
use Test::WWW::Mechanize::Catalyst 'TestApp';

my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get_ok('http://localhost/', 'get main page');
$mech->content_like(qr/TestApp for SimpleCMS works/i, 'see if it has our text');

$mech->get_ok('http://localhost/testurl', 'cms is up on the default namespace');
$mech->content_like(qr/TestApp for SimpleCMS testurl works/, 'can access TestApp Root controller page');

$mech->get_ok('http://localhost/simplecms', 'cms is up on the default namespace');
$mech->content_like(qr/Tag groups/i, 'looks like main CMS admin page');

$mech->get_ok('http://localhost/AboutUs', 'cms content being server by the default method in the TestApp::Root controller');
$mech->content_like(qr/About Us/i, 'looks like CMS page');

done_testing;
