package OpusVL::FB11::Hat::sysparams::is_brain;

# ABSTRACT: a sysparams Hat where the brain implements the methods.

use Moose;
with 'OpusVL::FB11::Role::Hat::sysparams';

sub get { shift()->__brain->get(@_) // $_[1] }
sub set { shift()->__brain->set(@_) }

1;

=head1 DESCRIPTION

A brain that wears the sysparams hat can just say it's one of these and then put
C<get> and C<set> on itself.

See L<OpusVL::FB11::Role::Hat::sysparams> for documentation.
