package OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::Aclrule;

use strict;
use Moose::Role;

sub setup_authdb
{
    my $class = shift;
    $class->many_to_many( roles => 'aclrule_roles', 'role');
}

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
