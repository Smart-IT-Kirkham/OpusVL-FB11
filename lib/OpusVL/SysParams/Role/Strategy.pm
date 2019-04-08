package OpusVL::SysParams::Role::Strategy;

#ABSTRACT: defines the interface for sysparams strategies

our $VERSION = '0';
use Moose::Role;

=head1 DESCRIPTION

To implement a strategy for storing sysparams, you should consume this role.
These are the objects returned from
L<OpusVL::SysParams::Role::Hat::sysparams/for_component>.

=head1 REQUIRED METHODS

=head2 value_of

B<Arguments>: C<$parameter>

Returns the deserialised value for the given parameter.

=cut

requires qw/value_of/;

1;
