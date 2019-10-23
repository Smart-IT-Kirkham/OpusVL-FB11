package OpusVL::ObjectParams::Role::Extensible;

# ABSTRACT: Attach to classes to make their objects extensible
our $VERSION = '1';

use Moose::Role;

=head1 DESCRIPTION

An object that can have parameters attached to it can use this Role to ensure a
common interface into things that can be passed to the service. It doesn't
I<have> to consume this role; nor does it I<have> to even supply this interface.
Owners of such objects are responsible for creating the Adapter object. This
Role just facilitates it.

=head1 REQUIRED METHODS

=head2 extension_adapter

Returns an object consuming the L<OpusVL::ObjectParams::Role::Adapter> role.

This object can be passed to
L<OpusVL::ObjectParams::Role::Hat::objectparams/get_params_for> and
L<OpusVL::ObjectParams::Role::Hat::objectparams/set_params_for> to identify the
object in question.

=head1 SEE ALSO

Any "subclass" of this Role (that's not how Roles work) can be used to include a
standard implementation of this method if you want.

=cut

requires qw/extension_adapter/;

1;
