package OpusVL::ObjectParams::Schema::Result::Storage;

use strict;
use warnings;
use DBIx::Class::Candy;

# ABSTRACT: Stores parameters in a naïve way
our $VERSION = '1';

=head1 DESCRIPTION

This class represents a simple table that backs
L<OpusVL::ObjectParams::Hat::objectparams::storage>.

=head1 COLUMNS

=head2 id

We store our own ID because the object identifier is not unique (although it is unique with the owner identifier), but also JSON can't be used as a primary key.

=head2 object_type

The semantic name that the extendee component (i.e. the component that owns the object) uses for this object.

=head2 object_identifier

JSON object containing the fields and values that an object told us it can be identified by.

=head2 parameter_owner

Normally the C<short_name> of the Brain who is adding these parameters, but in any case, some unique identifier for the extender component.

=head2 parameters

The actual JSON object containing the extra parameters.

=cut

table 'object_params';

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
};

column object_type => {
    data_type => 'text',
};

column object_identifier  => {
    data_type => 'jsonb',
};

# I considered making this also JSONB but I think we want to encourage the use
# of the Brain short_name as this identifier.
column parameter_owner => {
    data_type => 'text'
};

column parameters => {
    data_type => 'jsonb'
};

# I also considered storing the schema that was used at the time the parameters
# were created, but I decided that if you're going to change that schema you can
# also write a migration.
1;
