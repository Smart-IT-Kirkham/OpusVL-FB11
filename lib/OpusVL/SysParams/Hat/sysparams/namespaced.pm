package OpusVL::SysParams::Hat::sysparams::namespaced;

# ABSTRACT: Uses the component name as a namespace for components

use Moose;
use OpusVL::SysParams::Brain::Strategy::Global;
with 'OpusVL::FB11::Role::Hat::sysparams';

sub for_component {
    OpusVL::FB11X::SysParams::Brain::Strategy::Namespaced->new({
        namespace => $_[1],
        __brain => $_[0]->__brain
    });
}

1;

=head1 DESCRIPTION

Wear this hat to provide legacy sysparams.

This is done by using the L<OpusVL::FB11X::SysParams::Brain::Strategy::Global>
strategy for parameters, and as such, the value you pass to C<for_component> has
no effect.

=head1 SYNOPSIS

package My::SysParams::Brain;

use Moose;
with 'OpusVL::FB11::Role::Brain';

...

sub hats { qw/sysparams::legacy/ }
sub provided_services { qw/sysparams::legacy/ }
