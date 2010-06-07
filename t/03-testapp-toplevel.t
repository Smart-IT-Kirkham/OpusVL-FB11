
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

    # Request public page... not logged but should allow access.
    $mech->get_ok("/test/publicaccess");
    is( $mech->ct, "text/html");
    $mech->content_contains("Controller: Test Action: access_public", "Runs a action with 'AppKitAllAccess' specified ");

    # Send incorrect login information..
    $mech->post_ok( '/login', { username => 'appkitadmin', password => 'passwordnotcorrect' }, "Submit to login page");
    $mech->content_contains("Wrong username or password", "Not Logged after giving incorrect details");

    # Send some login information..
    $mech->post_ok( '/login', { username => 'appkitadmin', password => 'password' }, "Submit to login page");
    $mech->content_contains("Welcome to", "Logged in, showing index page");

    # can we see the admin..
    $mech->get_ok( '/appkit/admin', "Can see the admin index");
    $mech->content_contains("Administration", "Showing admin page");

    # can we see the ExtensionA chained actoin
    $mech->get_ok( '/start/mid/end', "Can see the ExtensionA chained action page");
    $mech->content_contains('Start Chained actions...Middle of Chained actions...End of Chained actions.', "Chained content");

    # Request a page (from ExtensionB) we should NOT have access to..
    $mech->get_ok( '/test/noaccess', "Get Access Denied" );
    $mech->content_contains("Access denied", "Can see Access denied message");

    # can we see the ExtensionB formpage
    $mech->get_ok( '/extensionb/formpage', "Can see the ExtensionB form page");
    $mech->content_contains('<option value="1">Greg Bastien</option>', "Showing select option with content from the BookDB model");

    # Request a page (we should not have an ACL rule for this action)...
    $mech->get_ok( '/test/custom', "Get Custom page" );
    $mech->content_contains("Test Controller from TestApp - custom action", "Request action with no ACL but be allowed via the 'appkit_can_access_actionpaths' config var.");

    # can we logout.
    $mech->get_ok( '/logout', "Can logout");

    # request the home page .. (which should redirect to login)..
    $mech->get_ok("/");

    ## NEED TO ADD MANY MORE TESTS!!... think about all things that could and could not happen with the TestApp..
    # .. things I can think of now:
    #       
    #       access controll (adding, removing, allow, deny)
    #       roles (adding, removing, allow, deny)
    #       users (adding, removing, change password)

}
else 
{
      plan skip_all => 'NOT specified (and probably running) the CATALYST_SERVER.. please run the TestApp server (see README) and run test again.';
}
