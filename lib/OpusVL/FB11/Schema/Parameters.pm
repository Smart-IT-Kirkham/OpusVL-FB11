package OpusVL::FB11::Schema::Parameters;

use Moose;
use MooseX::NonMoose;
use v5.24;
use Try::Tiny;

extends 'DBIx::Class::Schema';
# ABSTRACT: Defines a Brain that handles OpusVL::CustomParameters

with 'OpusVL::AuditTrail::Schema::RoleForResultSet::EvtCreatorRole';
with 'OpusVL::Preferences::RolesFor::Schema';
__PACKAGE__->setup_preferences_schema;

has short_name => (
    is => 'rw',
    default => 'fb11_parameters'
);

with 'OpusVL::FB11::Role::Brain';

# I've asked in IRC for how get the Role to pick the right place to do this,
# since Schema doesn't have a new, and therefore doesn't get a BUILD
after connection => sub { shift->register_self };

sub provided_services {
    qw/parameters/
}

=head2 get_augmented_data

Returns the Result from our own schema that has the same "base" name as the
provided object.

If we don't have one of those, we return nothing.

=cut

sub get_augmented_data {
    my $self = shift;
    my $object = shift;

    my $class = ref $object;

    my ($source) = $class =~ /::([^:]+)$/;

    my $rs = try {
        $self->resultset($source);
    }
    catch {
        warn "No rs for $source";
    };

    return unless $rs;
    return $rs->find($object->id);
}

# FIXME: This is a bad model right now because if we register another User class
# via this mechanism it will override the one we provide.
# Or maybe that's a good thing idk

=head2 register_extension

By passing another DBIx::Class::Schema object and a list of names, you can
register other classes to be discovered when requesting augmented data for an
object.

Remember to request this provider from the component manager.

    OpusVL::FB11::ComponentManager
        ->service('parameters')
        ->register_extension($schema_obj, qw/MyResult MyOtherResult/);

=cut

sub register_extension {
    my $self = shift;
    my $schema = shift;
    $self->load_classes(
        ref $schema => \@_
    );
}

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

sub schema_version { 1 }

1;
