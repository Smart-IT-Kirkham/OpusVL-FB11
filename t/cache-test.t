use strict;
use Test::More;
use Test::WWW::Mechanize::PSGI;
use Child;
use Plack::Runner;
use TestApp;

sub server
{
    my $port = shift;
    return sub {

        my ( $parent ) = @_;

        note ("Server started on port $port");
        TestApp->setup_engine('PSGI');
        my $app = sub { TestApp->run(@_) };
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

my $mech = Test::WWW::Mechanize->new();
$mech->get_ok('http://localhost:9001/');
$mech->post_ok( 'http://localhost:9001//login', { username => 'appkitadmin', password => 'password' }, "Submit to login page");
$mech->get_ok('http://localhost:9001//admin/access/role/Administrator/show');
my $first_load = $mech->content;

my $mech2 = Test::WWW::Mechanize->new();
$mech2->get_ok('http://localhost:9002/');
$mech2->post_ok( 'http://localhost:9002/login', { username => 'appkitadmin', password => 'password' }, "Submit to login page");
$mech2->get_ok('http://localhost:9002/admin/access/role/Administrator/show');
$mech2->post_ok('http://localhost:9002/admin/access/role/Administrator/show', {
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
        'test/index'=>'allow',
}, 'Allow deleting roles.');

$mech->get_ok('http://localhost:9001/admin/access/role/Administrator/show');
ok $first_load ne $mech->content, "Content should have changed.";
done_testing;

# Kill the children if it is not done
note ("Killing servers");
$proc->complete || $proc->kill(9);
$proc2->complete || $proc2->kill(9);
note ("Done");
