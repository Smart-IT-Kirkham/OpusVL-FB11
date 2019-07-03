package OpusVL::EventLog::Adapter::System;

# ABSTRACT: Adapter that always identifies system events
our $VERSION = '0';
use Moose;
with 'OpusVL::EventLog::Role::Adapter';

sub get_identifier {
    { object_type => undef }
}

1;

=head1 DESCRIPTION

When requesting events you can use this special object to access system logs
instead of the events recorded against a specific object.

It will always be available as C<$OpusVL::EventLog::SYSTEM>.

=head2 SYNOPSIS

    OpusVL::FB11::Hive
        ->service('eventlog')
        ->get_events_for($OpusVL::EventLog::SYSTEM);

    OpusVL::FB11::Hive
        ->service('eventlog')
        ->add_event($OpusVL::EventLog::SYSTEM, { ... });
