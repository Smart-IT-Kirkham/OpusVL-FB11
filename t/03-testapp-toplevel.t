
##########################################################################################################################
# This set of tests should be run against the TestApp within the 't' directory of the OpusVL::AppKit Catalyst app.
#
# I couldn't figure out why we couldn't run the tests in the usual way so 
# I flipped it to do so.  I guess the problem we had was fixed somehow?
#
##########################################################################################################################

use strict;
use warnings;
use Test::More;
use Cache::Memcached::libmemcached;


use FindBin qw($Bin);
use lib "$Bin/lib";

use ok 'TestApp';
use Test::WWW::Mechanize::Catalyst 'TestApp';

# quickly reset the memcached cache to 
# make sure test results aren't skewed by
# previous runs.

{
    my $memd = Cache::Memcached::libmemcached->new({
            servers => [ "localhost:11211"],
            compress_threshold => 10_000
            });
    $memd->flush_all;
}

{
    # build the testing machanised object...
    my $mech = Test::WWW::Mechanize::Catalyst->new();

    # Request index page... not logged in so should redirect..
    $mech->get_ok("/");
    is( $mech->ct, "text/html");
    $mech->content_contains("Please login", "Redirect to login page");
    $mech->content_contains('OpusVL::AppKit', 'App name and logo should be present');

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
    $mech->content_contains("Settings", "Showing admin page");

    # can we see the ExtensionA chained actoin
    $mech->get_ok( '/start/mid/end', "Can see the ExtensionA chained action page");
    $mech->content_contains('Start Chained actions...Middle of Chained actions...End of Chained actions.', "Chained content");

    # Request a page (from ExtensionB) we should NOT have access to..
    $mech->get( '/test/noaccess', "Get Access Denied" );
    is $mech->status, 403, 'Check we get a 403';

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
    $mech->content_like(qr/Access denied/i, 'check not logged in');

    $mech->post_ok( '/login', { username => 'APPKITadmin', password => 'password' }, "Submit to login page");
    $mech->content_contains("Welcome to", "Logged in, showing index page");

    $mech->get_ok('/appkit/admin/users/adduser', 'Go to add user page');
    $mech->post_ok('/appkit/admin/users/adduser', 
        {
            username     => 'tester',
            password     => 'password',
            status       => 'enabled',
            email        => 'colin@opusvl.com',
            tel          => '555-32321',
            submitbutton => 'Submit',
        }, 'Try (and fail) to add user'
    );
    $mech->content_contains("This field is required", "Not all fields filled in on add user page") 
        || diag $mech->content;
    $mech->post_ok('/appkit/admin/users/adduser', 
        {
            username     => 'tester',
            password     => 'password',
            status       => 'enabled',
            email        => 'colin@opusvl.com',
            name         => 'Colin',
            tel          => '555-32321',
            submitbutton => 'Submit',
        }, 'Add user'
    );
    # setup permissions
    # FIXME: these user id/role id's are hard wired.
    # we could use mechanise to find them from the links.
    $mech->get_ok('/user/3/show', 'Look at user details');
    $mech->post_ok('/user/3/show', { user_role => 1, savebutton => 'Save' }, 'Add role to user'); 
    $mech->content_contains('User Roles updated', 'Role should have been updated');

    $mech->get_ok('/extensiona', 'Go to extension page');
    $mech->content_like(qr'Expanded Chained Action'i, 'Check we have menu along left');
    $mech->content_like(qr'Expanded Action'i, 'Check we have menu along left');
    $mech->content_like(qr'ExtensionA'i, 'Check we have menu along left');
    $mech->content_like(qr'ExtensionB'i, 'Check we have menu along left');
    $mech->content_like(qr'Test Controller \(within TestApp\)'i, 'Check we have menu along left');

    TODO: {
          local $TODO = 'Check password reset functionality';
          $mech->get_ok('/user/3/reset', 'Try password reset link');
    }
    # fIXME: check this actually works rather than bounces me for instance!

    $mech->get_ok( '/logout', "Can logout");

    $mech->get_ok('/appkit/user/changepword', 'Get change password page');
    $mech->content_contains('Access denied');
    $mech->post_ok( '/login', { username => 'tester', password => 'password' }, "Login as tester");
    $mech->base_is('http://localhost/appkit/user/changepword', 'Should have redirected to url I was trying to access');
    $mech->content_contains("Current password", "Change password page")
        || diag $mech->content;

    $mech->post_ok('/appkit/user/changepword', { password => 'newpassword', passwordconfirm => 'newpassword', submitbutton => 'Submit Query' }, 'Try to change password without mentioning current password');
    $mech->content_contains('required', 'Should complain about current password being missing')
        || diag $mech->content;

    $mech->post_ok('/appkit/user/changepword', { originalpassword => 'password', password => '', passwordconfirm => '', submitbutton => 'Submit Query' }, 'Try to change password to blank');
    $mech->content_contains('required', 'Should complain about password being missing')
        || diag $mech->content;


    $mech->post_ok('/appkit/user/changepword', { originalpassword => 'password', password => 'newpassword', passwordconfirm => 'nomatch', submitbutton => 'Submit Query'  }, 'Try to change password with dodgy passwords');
    $mech->content_contains('Does not match', 'Should complain about differing password inputs')
        || diag $mech->content;

    $mech->post_ok('/appkit/user/changepword', { originalpassword => 'password', password => 'newpassword', passwordconfirm => 'newpassword', submitbutton => 'Submit Query'  }, 'Try to change password');
    $mech->content_contains('your password has been changed', 'Password changed okay');

    $mech->post_ok('/appkit/user/changepword', { originalpassword => 'wrong', password => 'newpassword2', passwordconfirm => 'newpassword2', submitbutton => 'Submit Query'  }, 'Try to change password using wrong original password');
    $mech->content_contains('Invalid password', 'Password not changed');

    $mech->get_ok( '/logout', "Can logout");

    ##################################################
    # test the blank role fix.

    $mech->post_ok( '/login', { username => 'appkitadmin', password => 'password' }, "Submit to login page");
    $mech->content_contains("Welcome to", "Logged in, showing index page");

    $mech->get_ok('/appkit/admin/access/addrole', 'Go to roles page');
    $mech->post_ok('/appkit/admin/access/addrole', {
        addrolebutton => 'Add Role',
        rolename => 'blah',
    }, 'Create a new role');
    $mech->content_like(qr'Access Tree for blah'i, 'Check we have created role');
    $mech->post_ok('/appkit/admin/access/addrole', {
        addrolebutton => 'Add Role',
        rolename => 'blah',
    }, 'Create a new role');
    $mech->content_like(qr'Role already exists'i, 'Check we cannot create role again');
    $mech->post_ok('/appkit/admin/access/addrole', {
        addrolebutton => 'Add Role',
        rolename => '',
    }, 'Try to create a blank role');
    $mech->content_unlike(qr'Access Tree for'i, 'Check we have created role');
    $mech->content_like(qr'Specify a role name'i, 'Check we got told to enter a role name');

    $mech->get_ok('/admin/access/role/blah/show', 'Go back to the role we created');
    $mech->get('/admin/access/role/blah/delrole', 'Delete the role');
    is $mech->status, 403, 'Check we get a 403';
    $mech->get_ok('/admin/access/role/Administrator/show', 'Lets give ourselves permission to do it, we are admin after all');
    $mech->post_ok('/admin/access/role/Administrator/show', {
            savebutton => 'Save',
            'appkit/admin/access/auto'=>'allow',
            'appkit/admin/access/addrole'=>'allow',
            'appkit/admin/access/delete_role'=>'allow',
            'appkit/admin/access/index'=>'allow',
            'appkit/admin/access/role_specific'=>'allow',
            'appkit/admin/access/show_role'=>'allow',
            'appkit/admin/index'=>'allow',
            'appkit/admin/users/add_parameter'=>'allow',
            'appkit/admin/users/adduser'=>'allow',
            'appkit/admin/users/auto'=>'allow',
            'appkit/admin/users/delete_parameter'=>'allow',
            'appkit/admin/users/delete_user'=>'allow',
            'appkit/admin/users/edit_user'=>'allow',
            'appkit/admin/users/get_parameter_input'=>'allow',
            'appkit/admin/users/index'=>'allow',
            'appkit/admin/users/show_user'=>'allow',
            'appkit/admin/users/user_specific'=>'allow',
            'appkit/user/change_password'=>'allow',
            'extensiona/expansionaa/endchain'=>'allow',
            'extensiona/expansionaa/home'=>'allow',
            'extensiona/expansionaa/midchain'=>'allow',
            'extensiona/expansionaa/startchain'=>'allow',
            'extensiona/home'=>'allow',
            'extensionb/formpage'=>'allow',
            'extensionb/home'=>'allow',
            'index'=>'allow',
            'search/index'=>'allow',
            'test/access_admin'=>'allow',
            'test/cause_error'=>'allow',
            'test/index'=>'allow',
    }, 'Allow deleting roles.');

    $mech->get_ok('/admin/access/role/blah/delrole', 'Delete the role');
    $mech->content_like(qr'Are you sure you want to delete the role'i, 'Check we are asked to confirm the deletion');
    $mech->click_ok('submitok');
    $mech->content_like(qr'Role deleted'i, 'Check we deleted the role');

    $mech->get('/admin/access/role/notthere/delrole');
    is $mech->status, 404, 'Check we get a 404 for a non existent role';

    # this would be so cool if it worked.  Unfortunately the mech
    # will only work if the page it's just downloaded has this
    # link contained.
    #$mech->link_status_is(['/admin/access/role/notthere/delrole'], 404, 'Check 404 on role that does not exist');

    ## NEED TO ADD MANY MORE TESTS!!... think about all things that could and could not happen with the TestApp..
    # .. things I can think of now:
    #       
    #       access controll (adding, removing, allow, deny)
    #       roles (adding, removing, allow, deny)
    #       users (adding, removing, change password)

}

done_testing();
