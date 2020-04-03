package OpusVL::EventLog::Adapter::System;

# ABSTRACT: Adapter that always identifies system events
our $VERSION = '2';
use Moose;
with 'OpusVL::FB11::Role::Object::Identifiable';

sub fb11_unique_identifier {
    { object_type => undef }
}

1;

=head1 DESCRIPTION

When requesting events you can use this special object to access system logs
instead of the events recorded against a specific object.

It will always be available as C<$OpusVL::EventLog::SYSTEM>.

=head1 SYNOPSIS

    OpusVL::FB11::Hive
        ->service('eventlog')
        ->get_events_for($OpusVL::EventLog::SYSTEM);

    OpusVL::FB11::Hive
        ->service('eventlog')
        ->add_event($OpusVL::EventLog::SYSTEM, { ... });

=head1 WARNINGS

Please be careful when providing types to system events: it is much more likely
that you provide a type that someone else has used, and thus pollute one another
with unexpected data in future, if you don't use namespaced type names.

=head1 IMPLEMENTATION DETAILS

This is trivially an adapter that always returns a
hashref with the undefined value for C<object_type>, and no other
identification. This allows events to be logged in the system log instead of
against an object.