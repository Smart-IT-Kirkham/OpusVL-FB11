package OpusVL::ObjectParams::Hat::objectparams;

use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

# ABSTRACT: Service to find extra parameters for named objects
our $VERSION = '0';

=head1 DESCRIPTION

Implements the C<objectparams> service on the Hive.
sub get_params_for {
    my $self = shift;
    my %args = shift;
}

sub set_params_for {
    my $self = shift;
    my %args = shift;
}

1;
