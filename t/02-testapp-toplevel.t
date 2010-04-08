
##########################################################################################################################
# This set of tests should be run against the TestApp within the 't' directory of the OpusVL::AppKit Catalyst app.
#
# Due to reasons I belive are related to Catalyst::ScriptRunner and the AppBuilder, we can't use the
# Test::WWW::Mechanize::Catalyst as normal, so please run up a copy of the OpusVL::Appkit TestApp (see README)
# Once you have run the test server, set the host and port in the ENV variable 'CATALYST_SERVER'.. then you can test.
##########################################################################################################################

use strict;
use warnings;
use Test::More;
use Test::WWW::Mechanize::Catalyst;

if ( $ENV{CATALYST_SERVER} )
{
    # once done, we should set the number of tests.. for no just using 'no_plan'..
    #plan tests => 60;
    plan 'no_plan';

    # build the testing machanised object...
    my $mech = Test::WWW::Mechanize::Catalyst->new();

    # Request index page... not logged in so should redirect..
    $mech->get_ok("/");
    is( $mech->ct, "text/html");
    $mech->content_contains("Please login", "Redirect to login page");

    # Send incorrect login information..
    $mech->post_ok( '/login', { username => 'appkitadmin', password => 'passwordnotcorrect' }, "Submit to login page");
    $mech->content_contains("Wrong username or password", "Not Logged after giving incorrect details");

    # Send some login information..
    $mech->post_ok( '/login', { username => 'appkitadmin', password => 'password' }, "Submit to login page");
    $mech->content_contains("Welcome to the OpusVL::AppKit", "Logged in, showing index page");

}
else 
{
      plan skip_all => 'NOT specified (and probably running) the CATALYST_SERVER.. please run the TestApp server (see README) and run test again.';
}
