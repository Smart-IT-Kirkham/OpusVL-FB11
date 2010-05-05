
##########################################################################################################################
# This set of tests should be run against the TestApp within the 't' directory of the OpusVL::AppKit Catalyst app.
#
# This set of tests is based around building the Catalyst object (with the inheritance AppBuilder brings)
# WARNING!... These tests are only for functions, etc that AppKit has, not "functionallity" as we are using the Catalyst
# object in what I think is an invalid way (by effectily just call ->new on it .. althou this works, there is NO! ::Engine
##########################################################################################################################

use strict;
use warnings;
use Catalyst::ScriptRunner;
use Test::More;
# setup library path
use FindBin qw($Bin);
use lib "$Bin/lib";

# instansiate the Catalyst object.. abit pointless without any ::Engine bits.. but for tests tis usful..
my $cat = Catalyst::ScriptRunner->run('TestApp', 'GetNew');

ok ( $cat, "Built 'new' Catalyst - AppBuilder object" );

can_ok($cat, qw/can_access who_can_access/ );

##########################################################################################################################
# Model tests ...
##########################################################################################################################

my $authdb = $cat->model('AppKitAuthDB');
ok($authdb, "Get the AppKitAuthDB model object");

my $emailaddresses = $authdb->resultset('Role')->email_from_rolename( 'normal users' );
ok($emailaddresses, "Got list of emailaddresses from a role name");
is($#$emailaddresses, 2, "Got correct amount of emailaddresses from a role name");
is($emailaddresses->[0], 'appkit@opusvl.com', "Got correct data in email field (from a role name)");

my $telnumbers = $authdb->resultset('Role')->tel_from_rolename( 'normal users' );
ok($telnumbers, "Got list of telephone numbers from a role name");
is($#$telnumbers, 2, "Got correct amount of telephone numbers from a role name");
is($telnumbers->[0], '07720061678', "Got correct data in tel field (from a role name)");

done_testing;
