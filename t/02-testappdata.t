
use strict;
use warnings;
use Test::More;
use File::ShareDir;
use FindBin qw($Bin);
use lib "$Bin/lib";

use_ok 'OpusVL::FB11::Schema::FB11AuthDB';
use_ok 'TestApp';

##########################################################################################################################
# Setup..
##########################################################################################################################

my $authdb;
my $adminrole;
my $normalrole;
my $adminuser;
my $normaluser;

my $path            = File::ShareDir::module_dir( 'TestApp' );
my $authdb_config->{connect_info} =
{   
    dsn             => 'dbi:SQLite:' . $path . '/root/db/fb11_auth.db',
    user            => '',
    password        => '',
    on_connect_call => 'use_foreign_keys',
};


ok( $authdb = OpusVL::FB11::Schema::FB11AuthDB->connect($authdb_config->{connect_info}),     "Got handle to AppKitAuthDB" );

$authdb->txn_begin;

ok( $authdb->resultset('Role')->search()->delete,       "Deleted all Role's " );
ok( $authdb->resultset('Aclrule')->search()->delete,    "Deleted all Aclrule's " );
ok( $authdb->resultset('UsersFavourite')->search()->delete, "Deleted all Favourites" );
ok( $authdb->resultset('UserAvatar')->search()->delete, "Deleted all users' avatars" );
ok( $authdb->resultset('User')->search()->delete,       "Deleted all User's " );

$adminrole = $authdb->resultset('Role')->create( { role => 'Administrator' } );
ok( $adminrole, "Created Administrator Role");

$normalrole = $authdb->resultset('Role')->create( { role => 'Normal User' } );
ok( $normalrole, "Created Normal User Role");

diag("Created Roles");

my %rules = (
    'index'                                 => ['Administrator', 'Normal User'],
    'default',                              => ['Administrator', 'Normal User'],
    'auto',                                 => ['Administrator', 'Normal User'],
    'fb11/auto',                          => ['Administrator', 'Normal User'],
    'fb11/admin/auto',                    => ['Administrator'],
    'fb11/admin/index',                   => ['Administrator'],
    'fb11/admin/access/auto',             => ['Administrator'],
    'fb11/admin/access/index',            => ['Administrator'],
    'fb11/admin/access/addrole',          => ['Administrator'],
    'fb11/admin/access/role_specific',    => ['Administrator'],
    'fb11/admin/access/show_role',        => ['Administrator'],
    'fb11/admin/users/index',             => ['Administrator'],
    'fb11/admin/users/adduser',           => ['Administrator'],
    'fb11/admin/users/show_user',         => ['Administrator'],
    'fb11/admin/users/auto',              => ['Administrator'],
    'fb11/admin/users/user_specific',     => ['Administrator'],
    'fb11/admin/users/edit_user',         => ['Administrator'],
    'fb11/admin/users/delete_user',       => ['Administrator'],
    'fb11/admin/users/user_avatar'        => ['Administrator', 'Normal User'],
    'fb11/user/change_password',          => ['Administrator'],
    'custom/custom',                        => ['Administrator'],
    'custom/custom_access_denied',          => ['Administrator'],
    'custom/custom_link',                   => ['Administrator'],
    'custom/who_can_access_stuff',          => ['Administrator'],
    'extensiona/home',                      => ['Administrator'],
    'extensiona/expansionaa/home',          => ['Administrator'],
    'extensionb/home',                      => ['Administrator'],
    'extensionb/formpage',                  => ['Administrator'],
    'search/index',                         => ['Administrator'],
    'test/index',                           => ['Administrator', 'Normal User'],
    'test/access_admin',                    => ['Administrator'],
    'test/cause_error',                     => ['Administrator'],
    'extensiona/expansionaa/startchain',    => ['Administrator'],
    'extensiona/expansionaa/midchain',      => ['Administrator'],
    'extensiona/expansionaa/endchain',      => ['Administrator'],
    'rest/vehicle',                         => ['Administrator'],
    'rest/vehicle_GET',                     => ['Administrator'],
    'test/access_user_or_admin',            => ['Normal User'],
);

foreach my $rule ( keys %rules) 
{
    my $ra_roles = $rules{$rule};
    foreach my $role_name ( $ra_roles )
    {
        my $role = $authdb->resultset('Role')->search({ role => $role_name })->first;

        # .. create rule..
        my $aclrule = $authdb->resultset('Aclrule')->find_or_create( { actionpath => $rule } );

        # .. link to role...
        $aclrule->add_to_aclrule_roles( { role_id => $role->id } );
    }
}

diag("Created ACL Rules .. and linked to roles..");

$adminuser = $authdb->resultset('User')->create( { username => 'fb11admin', password => 'password', email => 'fb11@opusvl.com', name => 'FB11 Admin', tel => '07720061678' } );
ok( $adminuser,     "Created Admin user" );
$adminuser->set_roles( $adminrole );
ok( $adminuser->roles->find( { role => 'Administrator'} ), "Check admin user has admin role");

$normaluser = $authdb->resultset('User')->create( { username => 'fb11user', password => 'password', email => 'fb11@opusvl.com', name => 'FB11 User', tel => '07720061678' } );
ok( $normaluser,     "Created Normal user" );
$normaluser->set_roles( $normalrole );
ok( $normaluser->roles->find( { role => 'Normal User'} ), "Check normal user has normal role");

my $buff;
my $imageopen = 1;
open my $image, '<', 'lib/auto/OpusVL/FB11/root/static/images/profile.png' or do {
    ok $!, "Failed to open profile.png: $!";
    $imageopen = 0;
};

diag "Skipping image tests because it failed to open"
    if not $imageopen;

if ($imageopen) {
    my $blob;
    while(read $image, $buff, 1024) {
        $blob .= $buff;
    }

    close $image;
    ## insert default profile pic into all users
    for my $user ($authdb->resultset('User')->all) {
        # remove it first
        if (my $avatar = $authdb->resultset('UserAvatar')->find({ user_id => $user->id })) {
            $avatar->delete;
        }

        $user->create_related('avatar', {
            id        => $user->id,
            user_id   => $user->id,
            mime_type => 'image/png',
            data      => $blob,
        });
    }
}

$authdb->txn_commit;

done_testing;
