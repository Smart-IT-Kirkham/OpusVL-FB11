package OpusVL::EventLog::Adapter::Static;

# ABSTRACT: Construct an adapter with any data
our $VERSION = '2';

use v5.24;
use Moose;
with 'OpusVL::FB11::Role::Object::Identifiable';

has type => ( is => 'ro' );
has id => ( is => 'ro', isa => 'HashRef' );

sub fb11_unique_identifier {
    my $self = shift;
    return {
        type => $self->type,
        %{$self->id}
    }
}

1;

=head1 DESCRIPTION

You can adapt any object at all by constructing one of these objects. Simply
provide the type, and then a hashref of identifying data in C<id>.

=head1 SYNOPSIS

    my $adapter = OpusVL::EventLog::Adapter::Static->new({
        type => 'myapp::sometype',
        id => {
            parent => $self->parent->name,
            name => $self->name
        }
    });

    OpusVL::FB11::Hive->service('eventlog')->add_event(object => $adapter, ...);
    OpusVL::FB11::Hive->service('eventlog')->get_events_for(object => $adapter, ...);
