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

requires qw/set_value metadata_for set_default/;

1;
