package OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Role;

use strict;
use Moose::Role;

=head2 setup_authdb

=cut

sub setup_authdb
{
    my $class = shift;

    $class->many_to_many( users => 'users_roles', 'user');
    $class->many_to_many( aclrules => 'aclrule_roles', 'aclrule_id');

}

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
