package OpusVL::SysParams::Role::Manager;

#ABSTRACT: defines the interface for sysparams management strategies

our $VERSION = '0';
use Moose::Role;
with 'OpusVL::SysParams::Role::Strategy';

=haed1 DESCRIPTION

This Manager role is a superset of L<OpusVL::SysParams::Role::Strategy> and
implements all of the functionality you'd want on top of getting a value.

=head1 REQUIRED METHODS

=head2 set_value

B<Arguments>: C<$property>, C<$value>

Set the property to the given value. The value can be any simple scalar, or an
arrayref or hashref whose values recursively validate against this sentence.

The data type of the property will be used to validate all data points in the
structure.

=head2 metadata_for

B<Arguments>: C<$property>

Returns a structure describing the property, containing C<label>, C<comment>,
and C<type>.

=head2 set_metadata

B<Arguments>: C<$property>, C<$hashref>

Sets the metadata provided in the hashref. Only the keys in the hashref will be
updated.

=head2 set_default

B<Arguments>: C<$property>, C<$value>, C<$metadata>

Sets the default value and metadata for this property. All metadata must be
passed (see L</metadata_for>).

If the property already exists, no action will be taken. If the parameter
doesn't exist it will be created with the given value and metadata.

=cut

requires qw/set_value metadata_for set_metadata set_default/;
