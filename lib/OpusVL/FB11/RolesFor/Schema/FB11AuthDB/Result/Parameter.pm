package OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::Parameter;

our $VERSION = '2';

use strict;
use Moose::Role;

=head2 setup_authdb

=cut

sub setup_authdb
{
    my $class = shift;
    $class->many_to_many( users => 'user_parameters', 'user');
}

1;
__END__
