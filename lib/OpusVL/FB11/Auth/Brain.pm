package OpusVL::FB11::Auth::Brain;

# ABSTRACT: This Brain interfaces with the FB11AuthDB schema
our $VERSION = '0';

use v5.24;
use Moose;
use Try::Tiny;
use OpusVL::FB11::Schema::FB11AuthDB;

=head1 DESCRIPTION

The FB11 auth database has historically been made available through a Catalyst
model. This Brain exposes it as a Hive service.

In time, it will become an interface into a generic auth system, but this has
not been designed yet.

This Brain is also responsible for deploying schemas found in the Hive. This is
because the FB11AuthDB is the core schema, This may change in future.

=head1 PROPERTIES

=head2 connect_info

This is the standard DBI connect info, as an arrayref, to use to connect to
L<OpusVL::FB11::Schema::FB11AuthDB>.

=head2 schema

This is a connected L<OpusVL::FB11::Schema::FB11AuthDB>. It uses
L</connect_info> if you don't provide it to the constructor.

=head2 short_name

The short name of this brain is C<fb11-auth>.

=cut

has connect_info => (
    is => 'ro',
);

has schema => (
    is => 'ro',
    lazy => 1,
    default => sub {
        OpusVL::FB11::Schema::FB11AuthDB->connect($_[0]->connect_info->@*);
    }
);

has short_name => (
    is => 'ro',
    lazy => 1,
    default => 'fb11-auth',
);

=head1 HATS AND SERVICES

=head2 auth

This Brain wears an auth hat and provides the auth service. See
L<OpusVL::FB11::Auth::Brain::Hat::auth>.

This is essentially a stand-in for a future auth service that has not been
designed yet.

=head2 fb11authdb

This is an alias into the auth hat and service.

=head2 dbicdh::manager

The best way to ensure your schemata get deployed is to have this brain in your
hive, since it provides the C<dbicdh::manager> service.

Remember that nothing actually accesses this service by default: this is
because, in principle, FB11 should not require a database to run.

=head2 dbicdh::consumer

The FB11AuthDB is deployed and upgraded as the zeroth priority schema, and thus
is both the manager and consumer.

=cut

# TODO retest legacy parameters against someone who has them
sub hats {
    (
        qw/parameters/,
        fb11authdb => {
            class => 'auth'
        },
        'dbicdh::consumer' => {
            class => '+OpusVL::FB11::Hat::dbicdh::consumer::is_brain',
            constructor => {
                priority => 0,
            }
        },
        'dbicdh::manager',
    )
}

sub provided_services {
    qw/fb11authdb dbicdh::manager/
}

# TODO: I don't like this being done automatically but we have to make sure DBs
# are deployed before other inits run
sub hive_init {
    my $self = shift;
    my $hive = shift;

    $hive->service('dbicdh::manager')->deploy_and_upgrade($hive);

    # XXX TEMPORARY
    # This is not where this should live but this is sort of the right place.
    # The correct behaviour would be a UI that does this on request, which we
    # can direct to if we have no auth data yet.
    $self->_setup_fb11admin($hive);
}

sub _setup_fb11admin {
    my $self = shift;
    my $hive = shift;

    # If we don't have an app, just don't do it. This only matters if there's an
    # app to provide auth to (although why are you here if there's no app?)
    my $app = try { $hive->service('fb11::app') } catch { undef }
        or return;

    my $feature_list = $app->auth_feature_list;

    # XXX Because this is temporary I'm not bothering to see if something else
    # is providing auth. The ability to change auth provider is way further
    # ahead than the ability to set up FB11 on first run.

    # Find any user. If there is none, create basic fb11admin user.
    my $Users = $self->schema->resultset('User');
    my $user = $Users->first;

    return if $user;

    $user = $Users->create({
        username => 'fb11admin',
        email    => 'fb11admin@localhost',
        name     => 'Administrator',
        password => 'fb11password'
    });

    warn "**** Created fb11admin / fb11password! Change the password!";

    for my $section (keys %$feature_list) {
        my $roles = $feature_list->{$section};

        for my $role (keys %$roles) {
            $self->schema->resultset('Aclfeature')->find_or_create({
                feature => $section . '/' . $role
            });
        }
    }
    my $admin_role = $self->schema->resultset('Role')->find_or_create({
        role => 'Admin'
    });

    $self->schema->txn_do(sub {
        for my $feature ( $self->schema->resultset('Aclfeature')->all ) {
            $admin_role->add_to_aclfeatures($feature)
                unless $admin_role->aclfeatures->find($feature->id);
        }
    });

    $user->add_to_roles($admin_role);

    # I hate this but it's necessary. I couldn't find a way of refreshing the
    # ACL that actually worked, short of restarting the app.
    die "Now restart the app because of reasons";
}

with 'OpusVL::FB11::Role::Brain';
1;
