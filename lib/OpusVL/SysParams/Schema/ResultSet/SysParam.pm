package OpusVL::SysParams::Schema::ResultSet::SysParam;
use strict;
use warnings;

our $VERSION = '0';

# ABSTRACT: Formalises and simplifies sysparam naming behaviour

use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';

has namespace => ( is => 'ro' );

=head1 DESCRIPTION

This ResultSet only makes it a bit easier to find an
L<OpusVL::SysParams::Schema::Result::SysParam> object. The actual creation of
parameters and setting of values should be done through L<OpusVL::SysParams>,
preferably via L<OpusVL::FB11::Hive>. See those docs for details.

=head1 METHODS

=head2 find_by_name

B<Arguments>: C<$name>

Finds the parameter by the given C<$name>. If none exists, an error is thrown,
because if you want to use a system parameter you have to have created it first.
See L<OpusVL::SysParams>.

=cut

sub find_by_name {
    my $self = shift;
    my $name = shift;

    $self->find({ name => $self->_namespaced_name($name) });
}

=head2 with_namespace

Searches only for parameters in the given namespace. Returns a new object with
the namespace built in. Calling it on an object that already has a namespace
will add the new namespace under the existing one.

    $schema->resultset('SysParam')
        ->with_namespace('fb11::core')
        ->find_by_name('theme');
    # Equivalent:
    $schema->resultset('SysParam')
        ->with_namespace('fb11')
        ->with_namespace('core')
        ->find_by_name('theme');
    # Equivalent:
    $schema->resultset('SysParam')
        ->find_by_name('fb11::core::theme');
    # Expected usage:
    my $core_params = $schema->resultset('SysParams')->with_namespace('fb11::core');
    my $params = $core_params->in_name_order->all;

If you don't pass a namespace, the empty namespace is used.

=cut

sub with_namespace {
    my $self = shift;
    my $ns = shift // '';

    # DBIC is way old, but this seems to be allowed by the code, so I'm doing it
    my $clone = $self->search;

    # Remember to allow for the empty string as a valid namespace!
    if (exists $clone->{sysparams_namespace}) {
        $clone->{sysparams_namespace} .= '::' . $ns;
    }
    else {
        $clone->{sysparams_namespace} = $ns;
    }

    $clone;
}

=head2 in_name_order

Re-sorts the result set to be in name order, i.e. alphabetically by their
fully-qualified name.

=cut

sub in_name_order {
    my $self = shift;
    my $me = $self->current_source_alias;
    return $self->search(undef, {
        order_by => ["$me.name"],
    });
}

=head2 in_label_order

Re-sorts the result set to be in label order, i.e. alphabetically by the
human-readable label.

=cut

sub in_label_order {
    my $self = shift;
    my $me = $self->current_source_alias;
    return $self->search(undef, {
        order_by => ["$me.label"],
    });
}

1;
