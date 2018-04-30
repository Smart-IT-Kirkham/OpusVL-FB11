package OpusVL::FB11::Role::Interface::Parameters;

use Moose::Role;

# ABSTRACT: Defines the required methods for a Brain that wants to provide parameters


=head1 METHODS

=head2 get_augmented_data

B<Arguments>: C<$data>

C<$data> will be an arbitrary object, and the implementer must return the
parameters for it.

=cut

requires 'get_augmented_data';

=head2 get_augmented_classes

The implementer must return a list of class names that it is capable of
returning parameters for.

=cut

requires 'get_augmented_classes';

=head2 get_parameter_schema

B<Arguments>: C<$class>

C<$class> will be a class returned by L</get_augmented_classes>. The implementer
must return a data structure that defines the user-defined schema for the
parameters for this class.

The shape of this schema is TBC but it probably will be a subset of OpenAPI.

=cut

requires 'get_parameter_schema';

=head2 set_augmented_data

B<Arguments>: C<$object>, C<%$subset_of_data>

The implementer must store the hashref in C<$subset_of_data> against the object,
such that L</get_augmented_data> will return this.

As the name suggests, C<$subset_of_data> may indeed be only a subset of the
fields defined by the L<schema|/get_parameter_schema>.

Validation is performed by the implementer.

=cut

requires 'set_augmented_data';

=head2 set_parameter_schema

B<Arguments>: C<$class>, C<%$entire_schema>

The implementer must set this schema against the given class. The entire schema
is passed, so removed fields are easily identified.

=cut

requires 'set_parameter_schema';

1;
