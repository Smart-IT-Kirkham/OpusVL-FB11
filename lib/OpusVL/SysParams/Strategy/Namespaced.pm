package OpusVL::SysParams::Strategy::Namespaced;
use OpusVL::SysParams::Schema;

use v5.24;
use Moose;
with 'OpusVL::SysParams::Role::Strategy';

our $VERSION = '0';

# ABSTRACT: A sysparams strategy that understands namespaces

=head1 DESCRIPTION

This strategy uses the component name as a namespace for the system parameters.

It is perfectly acceptable, nay encouraged, to use the double-colon separator in
the component if it is useful to do so.

=head1 SYNPOSIS

    my $sysparams = OpusVL::FB11::Hive->service('sysparams')
        ->for_component('fb11::base')

This strategy is installed as the default provider for the C<sysparams> service
when you use L<OpusVL::SysParams> as the brain. See the documentation for that
module for how to select the brain for this service.

=head1 PROPERTIES

=head2 namespace

The namespace to search for parameters. When you use the Hive, as in the
synopsis, this comes from what you passed to
L<OpusVL::SysParams::Hat::sysparams::namespaced/for_component>.

=head2 schema

This is by default an instance of L<OpusVL::SysParams::Schema>, constructed from
L<OpusVL::SysParams/connect_info>. You may provide any connected schema for
testing purposes, e.g.

=head1 METHODS

See also L<OpusVL::SysParams::Role::Strategy>.

=head2 value_of

Returns the value of the provided parameter within the namespace in C<namespace>.

=cut

has namespace => (
    is => 'ro'
);

has schema => (
    is => 'ro',
    default => sub {
        OpusVL::SysParams::Schema->connect($_[0]->__brain->connect_info)
    }
);

sub value_of {
    my $self = shift;
    my $param = shift;

    $self->schema->resultset('SysInfo')
        ->with_namespace($self->namespace)
        ->find({ name => $param });
}

1;
