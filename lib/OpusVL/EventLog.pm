package OpusVL::EventLog;

# ABSTRACT: Simple interface to log events against data or the system
our $VERSION = '1';
use Moose;
use OpusVL::EventLog::Schema;
use OpusVL::EventLog::Adapter::System;

=head1 DESCRIPTION

Use this service to store and retrieve event data against objects.

See the Hat for documentation: L<OpusVL::EventLog::Hat::eventlog>.

=head1 SYNOPSIS

    my $event_log = OpusVL::FB11::Hive->service('eventlog');

    my $guard = $event_log->set_environmental_data({ user_id => ... });

    OpusVL::FB11::Hive->service('eventlog')
        ->add_event(object => $object_adapter, payload => $event_data, type => 'creation');

Z<>

    my @events = OpusVL::FB11::Hive->service('eventlog')
        ->get_events_for(object => $object_adapter, type => 'creation', since => $last_week);

=cut

has short_name => (
    is => 'ro',
    default => 'event-log'
);

has connect_info => (
    is => 'ro',
);

has schema => (
    is => 'ro',
    default => sub { OpusVL::EventLog::Schema->connect($_[0]->connect_info->@*) },
    lazy => 1,
);

with 'OpusVL::FB11::Role::Brain';

sub hats {
    'eventlog',
    'dbicdh::consumer' => {
        class => '+OpusVL::FB11::Hat::dbicdh::consumer::is_brain'
    }
}

sub provided_services {
    'eventlog'
}

=head1 CONSTANTS

=head2 $SYSTEM

Use this for your C<event_type> for a system event.

Make sure you read the warnings about using this in
L<OpusVL::EventLog::Adapter::System>

=cut

# No need to construct an object
our $SYSTEM = 'OpusVL::EventLog::Adapter::System';

1;
