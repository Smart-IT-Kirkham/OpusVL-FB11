package OpusVL::AppKit::RolesFor::UserSetupResultSet;

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
