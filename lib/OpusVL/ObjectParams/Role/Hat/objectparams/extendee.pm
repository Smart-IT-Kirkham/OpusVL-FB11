package OpusVL::ObjectParams::Role::Hat::objectparams::extendee;

use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

# ABSTRACT: Identifies a Brain that can have extensions

=head1 DESCRIPTION

Wear this hat to tell other Brains that your objects can be extended. This is
done by coming up with semantic names for your objects, and then using those
names as keys into a configuration hashref.

It is your responsibility to ensure that your objects have performed the lookup
process of parameters provided by other Brains; it is acceptable to have an
C<extra_parameters> method (or such) that performs this lookup on request.

These objects are encouraged to consume
L<OpusVL::ObjectParameters::Role::Extensible> to simplify this arrangement.

=head1 REQUIRED METHODS

=head2 extendee_spec

This will return a paired list configuring the objects you will accept
extensions to. The semantic name of the object is the key, and a configuration
hashref is the value.

=head3 Config hashref

TODO:

You may specify the C<adapter> key in the config hashref. This will be used to
look up an adapter for your object. See L<OpusVL::ObjectParameters/Adapters>.

The value is the leaf part of the adapter you want to use, and the module will
be loaded for you. Using common semantics, if you prefix this value with a +, it
will be treated as a full module name, and we'll load that instead.

If you don't specify this, you will be expected to construct your own adapter at
the point you look up parameters through the service.

=cut

requires qw/extendee_spec/;
1;
