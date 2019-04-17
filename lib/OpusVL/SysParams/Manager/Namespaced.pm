package OpusVL::SysParams::Manager::Namespaced;

use v5.24;
use Moose;
use PerlX::Maybe;
with 'OpusVL::SysParams::Role::Manager';

our $VERSION = '0';

# ABSTRACT: Provides a management interface into namespaced sysparams

=head1 DESCRIPTION

This manager provides the writing behaviour corresponding to the readonly
behaviour of L<OpusVL::SysParams::Strategy::Namespaced>. It uses the component
name for the namespace when finding sysparams.

=head1 SYNOPSIS

    OpusVL::FB11::Hive->service('sysparams::manager')
        ->for_component('fb11::core')
        ->...

This manager object is installed as the default way of managing sysparams
through the Hive, provided you use the L<OpusVL::SysParams> brain. See that
class for details.

=head1 PROPERTIES

=head2 namespace

The namespace all parameter names are under.

This is populated for you from the value passed to
L<OpusVL::SysParams::Hat::sysparams::manager::namespaced/for_component>, if you
use the Hive as suggested.

=head2 schema

Uses L<OpusVL::SysParams/connect_info> to create an L<OpusVL::SysParams::Schema>
object if you use the Hive to get at the service.

You can instead provide one yourself for e.g. testing, if you want to.

=cut

has namespace => (
    is => 'ro',
    predicate => 'has_namespace'
);

has schema => (
    is => 'ro',
);

=head1 METHODS

See L<OpusVL::SysParams::Role::Manager>. All parameter names are taken relative
to L</namespace>, but otherwise behaviour is the same.

=cut

sub value_of {
    my $self = shift;
    my $param = shift;

    my $p = $self->_rs->find_by_name($param)
    or return;

    $p->value;
}

sub all_params {
    my $self = shift;
    $self->_rs->in_name_order->all_param_names;
}

sub all_params_fulldata {
    my $self = shift;
    $self->_rs->in_name_order->all_param_data;
}

sub set_value {
    my $self = shift;
    my $param = shift;
    my $value = shift;

    my $p = $self->_rs->find_by_name($param)
    or return;

    $p->update({ value => $value });
}

sub metadata_for {
    my $self = shift;
    my $param = shift;

    my $p = $self->_rs->find_by_name($param) or return;

    return +{
        map { $_ => $p->$_ } qw/comment label data_type/
    };
}

sub set_default {
    my $self = shift;
    my $param = shift;
    my $value = shift;
    my $metadata = shift;

    $self->_rs->set_default($param, {
        value => $value,
        %$metadata
    });
}

sub _rs {
    my $self = shift;
    my $rs = $self->schema->resultset('SysParam');

    if ($self->has_namespace) {
        return $rs->with_namespace($self->namespace)
    }

    return $rs;
}

1;
