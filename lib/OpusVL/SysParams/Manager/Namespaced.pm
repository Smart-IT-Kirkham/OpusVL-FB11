package OpusVL::SysParams::Manager::Namespaced;

use v5.24;
use strict;
use warnings;
use feature 'signatures';
no warnings 'experimental::signatures';

use Moose;
use failures qw<opusvl::sysparams::no_such_param>;
use PerlX::Maybe;
with 'OpusVL::SysParams::Role::Manager';

our $VERSION = '2';

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
    required => 1,
);

=head1 METHODS

See L<OpusVL::SysParams::Role::Manager>. All parameter names are taken relative
to L</namespace>, but otherwise behaviour is the same.

=cut

sub value_of {
    my $self = shift;
    my $param = shift;

    if (my $p = $self->_rs->find_by_name($param))
    {
        return $p->value
    }
    else
    {
        failure::opusvl::sysparams::no_such_param
        ->throw({
            msg => sprintf(
                "parameter %s not found in store",
                $self->_namespace_behaviour->full_param_name($param)
            ),
            trace => failure->confess_trace,
        })
    }
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
    return $self->_namespace_behaviour->resultset($self->schema);
}

sub _namespace_behaviour($self)
{
    $self->has_namespace
    ? _Namespace->new(namespace => $self->namespace)
    : _NullNamespace->new()

    # If we find more behaviour varies with it, add methods to the
    # _Namespace and _NullNamespace classes
    #
    # TODO do we ever have any non-namespaced sysparams now?
    #   If not we can remove this and make namespace attribute required
}


BEGIN {
    # TODO give these classes files and a Perl namespace of their own
    package _Namespace {
        use Moose;
        has namespace => (
            is => 'ro',
            required => 1,
            isa => 'Str',
        );

        sub full_param_name($self, $param)
        {
            $self->namespace . '::' . $param
        }

        sub resultset($self, $schema)
        {
            $schema->resultset('SysParam')->with_namespace($self->namespace)
        }
    }

    package _NullNamespace {
        use Moose;
        sub full_param_name($self, $param)
        {
            $param
        }
        sub resultset($self, $schema) {
            $schema->resultset('SysParam')
        }
    }
}

1;
