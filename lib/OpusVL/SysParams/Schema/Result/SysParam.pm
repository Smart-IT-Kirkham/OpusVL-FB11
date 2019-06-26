package OpusVL::SysParams::Schema::Result::SysParam;

use strict;
use warnings;

our $VERSION = '0';
# ABSTRACT: Defines the storage for system parameters

use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::Core';

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
format as L<HTML::FormHandler::Field::Select/options>. This allows us to both
validate the values and draw an appropriate form control in the admin UI.

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
        serializer_options => { allow_nonref => 1 },
    },
    comment => {
        data_type   => "text",
        is_nullable => 1,
    },
    data_type => {
        data_type => 'text',
        is_nullable => 0,
        default_value => '{"value":"text"}',
        serializer_class => 'JSON',
        serializer_options => { allow_nonref => 1 },
    },
);

__PACKAGE__->set_primary_key("name");

# InflateColumn::Serializer assumes that a nonref value is already serialised,
# which is wrong for our purposes. We wrap all these methods to force the value
# to always be a hashref, and to transparently return the real value.

# Note we intentionally do not wrap get_column, or we'd never be able to get at
# the real value if we need to, and we risk getting into a loop if DBIC itself
# calls get_column.

# Also note that this result class shouldn't really be used outside of the
# sysparams component, because other components should interact with the Hat,
# whose interface does not allow this object through.
around [qw/value data_type/] => sub {
    my $orig = shift;
    my $self = shift;
    my @args = @_;

    if (@args) {
        $args[0] = {value => $args[0]};
    }

    my $ret = $self->$orig(@args);

    return $ret->{value};
};

around update => sub {
    my $orig = shift;
    my $self = shift;
    my $href = shift;

    if (exists $href->{value}) {
        $href->{value} = { value => $href->{value} };
    }
    if (exists $href->{data_type}) {
        $href->{data_type} = { value => $href->{data_type} };
    }


    $self->$orig($href);
};

1;

