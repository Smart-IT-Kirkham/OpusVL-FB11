package OpusVL::SysParams::Hat::sysparams::management::namespaced;

use Moose::Role;
with 'OpusVL::SysParams::Hat::sysparams';

our $VERSION = '0';
# ABSTRACT: Creates interfaces to read and write sysparams.

=head1 DESCRIPTION

This hat is installed by default as the C<sysparams::management> service by the
L<OpusVL::SysParams> brain.

See L<OpusVL::FB11::Role::Hat::sysparams::management>.

=cut

sub for_component {
    OpusVL::SysParams::Manager::Namespaced->new({
        namespace => $_[1],
        __brain => $_[0]->__brain
    });
}

sub for_all_components {
    OpusVL::SysParams::Manager::Namespaced->new({
        __brain => $_[0]->__brain
    });
}

1;
