package OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Parameter;

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
