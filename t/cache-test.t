use strict;
use Test::More;
use Child;
use Plack::Runner;
use FindBin qw($Bin);
use lib "$Bin/lib";
use TestApp;
use Test::WWW::Mechanize;

sub server
{
    my $port = shift;
    return sub {

        my ( $parent ) = @_;

        note ("Server started on port $port");
        my $app = TestApp->psgi_app(@_);
        my $runner = Plack::Runner->new;
        my @args = @ARGV;
        push @args, ('--port', $port);
        $runner->parse_options(@args);
        $runner->run($app);

    }
}

my $child = Child->new(server(9001));
my $child2 = Child->new(server(9002));
my $proc = $child->start;
my $proc2 = $child2->start;
sleep(1);

my $mech = Test::WWW::Mechanize->new();
$mech->get_ok('http://localhost:9001/');
$mech->post_ok( 'http://localhost:9001//login', { username => 'fb11admin', password => 'password' }, "Submit to login page");
$mech->get_ok('http://localhost:9001//admin/access/role/Administrator/show');
$mech->post_ok('http://localhost:9002/admin/access/role/Administrator/show', {
        savebutton => 'Save',
        'action_fb11/admin/access/auto'=>'allow',
        'action_fb11/admin/access/addrole'=>'allow',
        'action_fb11/admin/access/delete_role'=>'allow',
        'action_fb11/admin/access/index'=>'allow',
        'action_fb11/admin/access/role_specific'=>'allow',
        'action_fb11/admin/access/show_role'=>'allow',
        'action_fb11/admin/index'=>'allow',
        'action_fb11/admin/users/adduser'=>'allow',
        'action_fb11/admin/users/auto'=>'allow',
        'action_fb11/admin/users/delete_user'=>'allow',
        'action_fb11/admin/users/edit_user'=>'allow',
        'action_fb11/admin/users/index'=>'allow',
        'action_fb11/admin/users/show_user'=>'allow',
        'action_fb11/admin/users/user_specific'=>'allow',
        'action_fb11/user/change_password'=>'allow',
        'action_extensiona/expansionaa/endchain'=>'allow',
        'action_extensiona/expansionaa/home'=>'allow',
        'action_extensiona/expansionaa/midchain'=>'allow',
        'action_extensiona/expansionaa/startchain'=>'allow',
        'action_extensiona/home'=>'allow',
        'action_extensionb/formpage'=>'allow',
        'action_extensionb/home'=>'allow',
        'action_index'=>'allow',
        'action_search/index'=>'allow',
        'action_test/cause_error'=>'allow',
        'action_test/access_admin'=>'allow',
}, 'Set role to known state.');
$mech->get_ok('http://localhost:9001//admin/access/role/Administrator/show');
my $first_load = $mech->content;

my $mech2 = Test::WWW::Mechanize->new();
$mech2->get_ok('http://localhost:9002/');
$mech2->post_ok( 'http://localhost:9002/login', { username => 'fb11admin', password => 'password' }, "Submit to login page");
$mech2->get_ok('http://localhost:9002/admin/access/role/Administrator/show');
$mech2->post_ok('http://localhost:9002/admin/access/role/Administrator/show', {
        savebutton => 'Save',
        'action_fb11/admin/access/auto'=>'allow',
        'action_fb11/admin/access/addrole'=>'allow',
        'action_fb11/admin/access/delete_role'=>'allow',
        'action_fb11/admin/access/index'=>'allow',
        'action_fb11/admin/access/role_specific'=>'allow',
        'action_fb11/admin/access/show_role'=>'allow',
        'action_fb11/admin/index'=>'allow',
        'action_fb11/admin/users/adduser'=>'allow',
        'action_fb11/admin/users/auto'=>'allow',
        'action_fb11/admin/users/delete_user'=>'allow',
        'action_fb11/admin/users/edit_user'=>'allow',
        'action_fb11/admin/users/index'=>'allow',
        'action_fb11/admin/users/show_user'=>'allow',
        'action_fb11/admin/users/user_specific'=>'allow',
        'action_fb11/user/change_password'=>'allow',
        'action_extensiona/expansionaa/endchain'=>'allow',
        'action_extensiona/expansionaa/home'=>'allow',
        'action_extensiona/expansionaa/midchain'=>'allow',
        'action_extensiona/expansionaa/startchain'=>'allow',
        'action_extensiona/home'=>'allow',
        'action_extensionb/formpage'=>'allow',
        'action_extensionb/home'=>'allow',
        'action_index'=>'allow',
        'action_search/index'=>'allow',
        'action_test/cause_error'=>'allow',
        'action_test/access_admin'=>'allow',
        'action_test/index'=>'allow',
}, 'Allow deleting roles.');

sleep(2);
$mech->get_ok('http://localhost:9001/admin/access/role/Administrator/show');
$mech->get_ok('http://localhost:9001/admin/access/role/Administrator/show');
ok $first_load ne $mech->content, "Content should have changed.";
if($first_load eq $mech->content)
{
    diag $first_load;
}
done_testing;

# Kill the children if it is not done
note ("Killing servers");
$proc->is_complete || $proc->kill(9);
$proc2->is_complete || $proc2->kill(9);
note ("Done");
