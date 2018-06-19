package OpusVL::AuditTrail::Test;

use Exporter::Easy (
    OK => [qw/has_events get_events_rs/],
);

use Test::More import => [qw/cmp_ok/];

sub has_events {
    my ($obj, $event_name, $expected_count, $desc) = @_;
    my $msg = sprintf('%s should have exactly %d %s events', $desc, $expected_count, $event_name);
    
    my $events = get_events_rs($obj, $event_name);
    cmp_ok($events->count, '==', $expected_count, $msg);

    return $events;
}

sub get_events_rs {
    my ($obj, $event_name) = @_;
    $obj->evt_events->search({ event => $event_name })
}

1;

__END__

=head1 NAME

OpusVL::AuditTrail::Test - Test utilities for the audit trail

=head1 SYNOPSIS

    use Test::Most tests => 2;
    use OpusVL::AuditTrail::Test qw/has_events get_events_rs/;
    use Test::DBIx::Class ..., ':resultsets' => 'Foo';

    my $foo = Foo->create({...});
    my $events = has_events($foo, 'foo-created', 1, 'new foo');
    like($events->first->details, qr/\bfiddle\b/, 'event details should contain the word fiddle');


=head1 EXPORTS

=head2 has_events

    has_events($obj, $event_name, $expected_count, $desc);

E.g.:

    my $events = has_events($bidder, 'online-bidder-created', 1, 'bidder');
    # then you can do more checks against $events, like checking contents of $events->first->details

Verify that there are exactly C<$expected_count> events of type C<$event_name>
attached to the object C<$obj>.

The C<$desc> is prepended to the test comment, followed by a space.
Usually C<$desc> will simply be the name of the object being tested, e.g. 'bidder' or 'Alice'.
You could also use adverbs, e.g. 'bidder still'.

Returns the found C<OpusVL::AuditTrail::Schema::ResultSet::EvtEvent> so you can do further tests on them.

=head2 get_events_rs

    my $events_rs = get_events_rs($obj, $event_name);

Get the C<ResultSet> of events on C<$obj> where the event type is C<$event_name>.

=head1 AUTHOR

OpusVL, C<< <nick.booker at opusvl.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
