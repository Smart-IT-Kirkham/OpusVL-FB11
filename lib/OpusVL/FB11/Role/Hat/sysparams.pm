package OpusVL::FB11::Role::Hat::sysparams;

use Moose::Role;
with "OpusVL::FB11::Role::Hat";

# ABSTRACT: Defines a sysparams hat.

=head1 DESCRIPTION

A sysparams hat is just one that can be inspected at any point for configuration
provided by the user. It is quite simple: it has C<get> and C<set>.

=head1 METHODS

=head2 get

B<Arguments>: C<$param_name>, C<$default>?

Gets the value of a parameter. The caller should know what type to expect back
(but see L</LATER>) Returns C<$default> if the result would otherwise be
undefined, and if you provide one.

It is not an error to request a parameter that is not defined.

=head2 set

B<Arguments>: C<$param_name>, C<$value>

Sets the given parameter to the given value. The implementation may throw a
validation exception in this case.

Please note we have not yet defined core exceptions so try to keep it friendly.

=cut

requires 'set', 'get';

=head1 LATER

It seems prudent that only parameters that are going to be used should be
created. The current implementation of system parameters, in
L<OpusVL::SysParams>, allows the end user to arbitrarily create parameters that
will never be used, and does not give any indication of what parameters are
actually expected of the system.

We should provide an interface on this hat that allows components to declare
which parameters they are going to use.

    requires 'register_param';

    -> $param_name, $type

We should therefore constrain at this level which data types we are going to
support. This means that callers to L</get> would have a more formalised
knowledge of what is going to come back (and we can blow up in more interesting
ways too).

=cut

1;
