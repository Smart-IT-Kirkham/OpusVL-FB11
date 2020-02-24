package OpusVL::SysParams::Role::Manager;

#ABSTRACT: defines the interface for sysparams management strategies

our $VERSION = '1';
use Moose::Role;

=head1 DESCRIPTION

This Manager role is a superset of L<OpusVL::SysParams::Role::Strategy> and
implements all of the functionality you'd want on top of getting a value.

=head1 REQUIRED METHODS

=head2 value_of

B<Arguments>: C<$param>

Returns the deserialised value of this parameter.

=head2 all_params

Returns a list of parameters. To encourage consistency in naming, "parameter"
refers only to the name of the parameter.

=head2 all_params_fulldata

Returns a list of the full data for all parameters. This will be a list of
hashrefs containing all data that a parameter can have: C<name>, C<value>,
C<label>, C<comment>, C<data_type>.

The C<value> will be deserialised.

=head2 set_value

B<Arguments>: C<$param>, C<$value>

Set the parameter to the given value. The value can be any simple scalar, or an
arrayref or hashref whose values recursively validate against this sentence.

The data type of the parameter will be used to validate all data points in the
structure.

The return value of this method is intentionally unspecified, in case we find a
good use for it in future. Callers should not expect any particular value to be
returned.

=head2 metadata_for

B<Arguments>: C<$param>

Returns a structure describing the parameter, containing C<label>, C<comment>,
and C<data_type>. Returns no value if C<$param> is not found.

=head2 set_default

B<Arguments>: C<$param>, C<$value>, C<$metadata>

Sets the default value and metadata for this parameter. All metadata must be
passed (see L</metadata_for>).

If the parameter already exists, no action will be taken. If the parameter
doesn't exist it will be created with the given value and metadata.

The return value of this method is intentionally unspecified, in case we find a
good use for it in future. Callers should not expect any particular value to be
returned.

=cut

requires qw/value_of all_params all_params_fulldata set_value metadata_for set_default/;

1;
