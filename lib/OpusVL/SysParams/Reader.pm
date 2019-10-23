package OpusVL::SysParams::Reader;

use Moose;

our $VERSION = '1';

# ABSTRACT: Readonly proxy to a manager

has manager => (
    is => 'ro',
    handles => [ 'value_of' ]
);

1;

=head1 DESCRIPTION

Most uses of SysParams are readonly. This class takes a Manager object and
exposes only the C<value_of> method. It is intended to be returned from
L<OpusVL::FB11::Role::Hat::sysparams/for_component> (and C<for_all_components>).
