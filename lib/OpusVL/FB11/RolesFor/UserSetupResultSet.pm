package OpusVL::FB11::RolesFor::UserSetupResultSet;

our $VERSION = '2';

=head1 NAME

    OpusVL::FB11::RolesFor::UserSetupResultSet

=head1 SYNOPSIS

    package OpusVL::App::Schema::ResultSet::Role;

    use Moose;
    extends 'DBIx::Class::ResultSet';
    with 'OpusVL::FB11::RolesFor::UserSetupResultSet';

    sub initdb
    {
        my $self = shift;

        my $permissions = {
            "FB11/Home Page" => ["Admin"],
            ...
            "System Parameters/System Parameters" => ["Admin"],
        };
        my $role_permissions = {
            "modules/audittrail/events/all_events" => ["Admin"],
            ...
            "modules/resultsetsearch/search_results" => ["Admin"],
        };
        my $users = [
            { 
                username => 'fb11admin',
                ...
                name => 'FB11 Admin',
                roles => [ 'Admin' ],
            }
        ];
        $self->setup_users({
            users => $users, 
            feature_permissions => $permissions,
            role_permissions => $role_permissions,
        });
    }

=head1 DESCRIPTION

This role provides a simple way to setup default users and set of roles
for an FB11 auth database.  The idea is to call it from an initdb function
which gets called when the database is built by your script.

=head1 METHODS

=head2 setup_users

    my $permissions = {
        "FB11/Home Page" => ["Admin"],
        "FB11/Password Change" => ["Admin"],
        "FB11/Role Administration" => ["Admin"],
        "FB11/User Administration" => ["Admin"],
        "FB11/User Password Administration" => ["Admin"],
        "Search/Search box" => ["Admin"],
        "System Parameters/System Parameters" => ["Admin"],
    };
    my $role_permissions = {
        "modules/audittrail/events/all_events" => ["Admin"],
        "modules/audittrail/events/event_search" => ["Admin"],
        "modules/audittrail/events/home" => ["Admin"],
        "modules/resultsetsearch/search_results" => ["Admin"],
    };
    my $users = [
        { 
            username => 'fb11admin',
            ...
            name => 'FB11 Admin',
            roles => [ 'Admin' ],
        }
    ];
    $self->setup_users({
        users => $users, 
        feature_permissions => $permissions,
        role_permissions => $role_permissions,
    });

This method takes a hash containing the feature permissions and a list
of users and the role to give those users, and creates the permissions
and users.

To generate the permissions hash use the L<scripts/permission_extract.sh>
script.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2012 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut


use Moose::Role;
use List::MoreUtils qw/uniq/;

sub setup_users
{
    my $self = shift;
    my $args = shift;
    my $user_list = $args->{users};
    my $feature_permissions_list = $args->{feature_permissions};
    my $role_permission_list = $args->{role_permissions};

    my $schema = $self->result_source->schema;
    my @roles = uniq map { @$_ } values %$feature_permissions_list;
    push @roles, uniq map { @$_ } values %$role_permission_list;
    @roles = uniq @roles;
    my %role_map;
    for my $role (@roles)
    {
        $role_map{$role} = $schema->resultset('Role')->find_or_create({ role => $role });
    }
    my $feature_rs = $schema->resultset('Aclfeature');
    for my $feature (keys %$feature_permissions_list)
    {
        my $f = $feature_rs->find_or_create({ feature => $feature });
        for my $role (@{$feature_permissions_list->{$feature}})
        {
            my $role_o = $role_map{$role};
            $f->add_to_roles($role_o);
        }
    }
    my $rule_rs = $schema->resultset('Aclrule');
    for my $rule (keys %$role_permission_list)
    {
        my $f = $rule_rs->find_or_create({ actionpath => $rule });
        for my $role (@{$role_permission_list->{$rule}})
        {
            my $role_o = $role_map{$role};
            $f->add_to_roles($role_o);
        }
    }
    my @users;
    for my $user_data (@$user_list) {
        my $roles_wanted = delete $user_data->{roles};
        my $user = $schema->resultset('User')->create($user_data);
        for my $wanted (@$roles_wanted)
        {
            my $role = $role_map{$wanted};
            $user->add_to_roles($role);
        }
    }
}

1;
