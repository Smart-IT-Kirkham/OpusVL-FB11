package OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Aclrule;

use strict;
use Moose::Role;

sub setup_authdb
{
    my $class = shift;
    $class->many_to_many( roles => 'aclrule_roles', 'role');
}

1;
__END__
