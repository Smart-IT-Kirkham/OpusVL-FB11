package OpusVL::SysParams::Hat::sysparams::management::namespaced;

use v5.24;
use Moose;
use OpusVL::SysParams::Manager::Namespaced;
with 'OpusVL::FB11::Role::Hat::sysparams::management';

our $VERSION = '2';
# ABSTRACT: Creates interfaces to read and write sysparams.

=head1 DESCRIPTION

This hat is installed by default as the C<sysparams::management> service by the
L<OpusVL::SysParams> brain.

See L<OpusVL::FB11::Role::Hat::sysparams::management>.

=cut

sub for_component {
    OpusVL::SysParams::Manager::Namespaced->new({
        namespace => $_[1],
        schema => $_[0]->__brain->schema
    });
}

sub for_all_components {
    OpusVL::SysParams::Manager::Namespaced->new({
        schema => $_[0]->__brain->schema
    });
}

1;
