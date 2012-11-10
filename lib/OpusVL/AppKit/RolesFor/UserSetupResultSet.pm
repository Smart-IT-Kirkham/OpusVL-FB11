package OpusVL::AppKit::RolesFor::UserSetupResultSet;

=head1 NAME

    OpusVL::AppKit::RolesFor::UserSetupResultSet

=head1 SYNOPSIS

    package OpusVL::App::Schema::ResultSet::Role;

    use Moose;
    extends 'DBIx::Class::ResultSet';
    with 'OpusVL::AppKit::RolesFor::UserSetupResultSet';

    sub initdb
    {
        my $self = shift;

        my $permissions = {
            "AppKit/Home Page" => ["Admin"],
            "AppKit/Password Change" => ["Admin"],
            ...
        };
        my $users = [
            { 
                username => 'appkitadmin',
                password => 'password',
                ...
            }
        ];
        $self->setup_users($users, $permissions, 'Admin');
    }

=head1 DESCRIPTION

This role provides a simple way to setup default users and set of roles
for an AppKit auth database.  The idea is to call it from an initdb function
which gets called when the database is built by your script.

=head1 METHODS

=head2 setup_users

    my $permissions = {
        "AppKit/Home Page" => ["Admin"],
        "AppKit/Password Change" => ["Admin"],
        "AppKit/Role Administration" => ["Admin"],
        "AppKit/User Administration" => ["Admin"],
        "AppKit/User Password Administration" => ["Admin"],
        "Search/Search box" => ["Admin"],
        "System Parameters/System Parameters" => ["Admin"],
    };
    my $users = [
        { 
            username => 'appkitadmin',
            password => 'password',
            email => 'admin@opusvl.com',
            name => 'AppKit Admin',
            tel => '01788 550 302',
        }
    ];
    $self->setup_users($users, $permissions, 'Admin');

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
    my $user_list = shift;
    my $permissions_list = shift;
    my $user_role = shift;

    my $schema = $self->result_source->schema;
    my @roles = uniq map { @$_ } values $permissions_list;
    my %role_map;
    for my $role (@roles)
    {
        $role_map{$role} = $schema->resultset('Role')->find_or_create({ role => $role });
    }
    my $feature_rs = $schema->resultset('Aclfeature');
    for my $feature (keys %$permissions_list)
    {
        my $f = $feature_rs->find_or_create({ feature => $feature });
        for my $role (@{$permissions_list->{$feature}})
        {
            my $role_o = $role_map{$role};
            $f->add_to_roles($role_o);
        }
    }
    my @users;
    for my $user_data (@$user_list) {
        push @users, $schema->resultset('User')->create($user_data);
    }
    my $admin = $role_map{$user_role};
    for my $user (@users)
    {
        $user->add_to_roles($admin);
    }
}

1;
