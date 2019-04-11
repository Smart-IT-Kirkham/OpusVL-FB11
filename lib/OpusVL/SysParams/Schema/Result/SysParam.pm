package OpusVL::SysParams::Schema::Result::SysParam;

use strict;
use warnings;

our $VERSION = '0';
# ABSTRACT: Defines the storage for system parameters

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components('InflateColumn::Serializer', 'Core');

__PACKAGE__->table('sysparams');

=head1 DESCRIPTION

This represents a single table of all system parameters. Conventionally, we use
C<::> to "hard" namespace parameters, and C<.> to "soft" namespace them.

The difference is that the "hard" namespace will be something like a grouping
system, whereas the "soft" namespace is more like having a single parameter with
multiple sub-parameters.

UIs can assume these conventions if they want to display groups or
sub-parameters specially.

=head1 PROPERTIES

=head2 name

This is the name of the parameter, which must be unique in the system. It is the
primary key of the table.

Only the fully-namespaced name of the parameter is unique.

=head2 label

This is a human-friendly name for the parameter and should be shown to the user
when they are setting values.

=head2 value

The value of the parameter is always stored as JSON but we allow a squishier
form of JSON whereby scalar values are allowable at the top level. This makes
simple parameters easier to understand when we look in the database.

This is automatically inflated and deflated, so you should never have to worry
about decoding it yourself. Nor should you try to set an encoded string, unless
that's what you meant to do.

=head2 comment

A comment about or description of the value, e.g. its purpose in the system, or
maybe usage information.

=head2 data_type

The data type of the value. Presently, we only support a single data type,
regardless of the complexity of the value.

This data type refers to the logical data type; essentially a constraint on the
valid values. For a complex structure of value, the data type is applied to all
leaf values.

The data type is used to decide how to draw the controls in the admin UI.

Data type is stored as a simple string or an object (both transparently serialised as
JSON). The object form supports data types that require configuration: this is
done by providing an object with the C<type> and C<parameters> keys.

A simple string data type is exactly equivalent to providing an object with that
string as the value for the C<type> key, and no C<parameters> key.

The data type can be one of:

=over

=item B<text>: A single line of text

=item B<textarea>: A block of text

=item B<date>, B<time>, B<datetime>: These are separate to allow for things like durations

=item B<boolean>: A simple toggle

=item B<enum>: A more complex data type that provides a list of options

The enum type use the object form, where its C<parameters> key uses the same
format as L<HTML::FormHandler::Select/options>. This allows us to both validate
the values and draw an appropriate form control in the admin UI.

=back

=cut

__PACKAGE__->add_columns(
    name => {
        data_type   => "text",
        is_nullable => 0,
    },
    label => {
        data_type   => "text",
        is_nullable => 0,
    },
    value => {
        data_type   => "text",
        is_nullable => 0,
        serializer_class => 'JSON',
    },
    comment => {
        data_type   => "text",
        is_nullable => 1,
    },
    data_type => {
        data_type => 'enum',
        is_nullable => 0,
        default_value => 'text',
        serializer_class => 'JSON',
    },
);

__PACKAGE__->set_primary_key("name");

1;

