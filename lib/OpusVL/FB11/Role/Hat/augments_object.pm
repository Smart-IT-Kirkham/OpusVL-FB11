package OpusVL::FB11::Role::Hat::augments_object;

use Moose::Role;
with "OpusVL::FB11::Role::Hat";

# ABSTRACT: Tells other components that this one may augment an object

requires 'get_augmented_data';

1;

=head1 DESCRIPTION

Any component that has objects might want to allow other components to augment
that object. It would therefore ask the component manager for all hats of this
type, and ask those hats for augmented data.

=head1 METHODS

=head2 get_augmented_data

B<Arguments>: C<$arbitrary_data>

Returns augmented data for the given object. The return value should be of the
same type as the input data, to some reasonable level of abstraction: DBIC stuff
from a DBIC object, hashref for hashref, etc.
