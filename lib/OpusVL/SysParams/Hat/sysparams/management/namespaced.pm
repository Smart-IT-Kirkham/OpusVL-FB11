package OpusVL::SysParams::Hat::sysparams::management::namespaced;

use v5.24;
use Moose;
use OpusVL::SysParams::Schema;
use OpusVL::SysParams::Manager::Namespaced;
with 'OpusVL::FB11::Role::Hat::sysparams::management';

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
        schema => OpusVL::SysParams::Schema->connect($_[0]->__brain->connect_info->@*)
    });
}

sub for_all_components {
    OpusVL::SysParams::Manager::Namespaced->new({
    schema => OpusVL::SysParams::Schema->connect($_[0]->__brain->connect_info->@*)
    });
}

1;
