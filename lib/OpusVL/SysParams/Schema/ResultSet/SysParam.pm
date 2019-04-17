package OpusVL::SysParams::Schema::ResultSet::SysParam;
use v5.24;
use strict;
use warnings;

our $VERSION = '0';

# ABSTRACT: Formalises and simplifies sysparam naming behaviour

use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';

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

=head2 all_param_names

Returns a list of all parameter names within the current namespace, with the
namespace removed.

=cut

sub all_param_names {
    my $self = shift;
    my $ns = $self->{sysparams_namespace};
    my @all = $self->namespaced_search->get_column('name')->all;
    map $self->_denamespaced_name($_), @all;
}

=head2 all_param_data

Returns a list of all parameters as hashrefs containing C<name>, C<value>,
C<label>, C<comment>, C<data_type> - with the value being deserialised already.

=cut

sub all_param_data {
    my $self = shift;
    my $ns = $self->{sysparams_namespace};

    map { +{
        name => $self->_denamespaced_name($_->name),
        value => $_->value,
        label => $_->label,
        comment => $_->comment,
        data_type => $_->data_type,
    }} $self->namespaced_search->all;
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

See also L</namespaced_search>.

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

=head2 set_default

B<Arguments>: C<$name>, C<$data>

Creates C<$name> (in the current namespace) if it does not exist, using C<$data> to do so.

C<$data> should be a hashref with C<value>, C<label>, C<comment>, and
C<data_type> in it, with C<comment> being optional.

This method does not guarantee its return value yet.

=cut

sub set_default {
    my $self = shift;
    my $name = shift;
    my $data = shift;

    # The wrapped value and data_type setter in the Result class is not used by
    # find_or_create. This seems the easiest place to do this.
    $data->{value} = { value => $data->{value} };

    $data->{data_type} = { value => $data->{data_type} };

    my $param = $self->find_or_create({
        name => $self->_namespaced_name($name),
        %$data,
    });
}

=head2 namespaced_search

After calling L</with_namespace> zero or more times, this method can be used to
actually create the resultset that uses the provided namespace. It can be used
in place of L<DBIx::Class::ResultSet/search>.

This is necessary because we cannot I<remove> a search for a namespace once it
is established, so we defer the establishment of the namespace until you ask for
it.

Note that this won't translate further searches to add the namespace. For
example, this probably isn't what you want:

    ...->with_namespace('a::namespace')
        ->find({ name => 'leaf.name.of.param' });

This will produce C<WHERE name LIKE 'a::namespace::%' AND name =
'leaf.name.of.param'>. Use L</find_by_name> for that example, or if you really
must you can use C<_namespaced_name($param)>, but don't do that if you can avoid
it, because it's private.

=cut

sub namespaced_search {
    my $self = shift;

    return $self if not defined $self->{sysparams_namespace};

    $self->search({
        name => {
            -like => $self->{sysparams_namespace} . '::%'
        }
    });
}

# Returns the fully namespaced name if we have set a namespace, or just the name
# if we have not
sub _namespaced_name {
    my $ns = $_[0]->{sysparams_namespace};
    # Make sure we do a definedness check, because the empty string is a valid
    # namespace
    defined $ns ? $ns . '::' . $_[1] : $_[1]
}

# Removes the current namespace from the parameter name and returns the result
sub _denamespaced_name {
    my $ns = $_[0]->{sysparams_namespace};
    my $name = $_[1];
    # Make sure we do a definedness check, because the empty string is a valid
    # namespace
    my $rm = defined $ns ? $ns . '::' : '';

    $name =~ s/^$rm//r;
}

1;
