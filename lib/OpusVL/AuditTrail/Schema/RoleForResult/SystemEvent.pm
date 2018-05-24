package OpusVL::AuditTrail::Schema::RoleForResult::SystemEvent;

=head1 NAME

OpusVL::AuditTrail::Schema::RoleForResult::SystemEvent

=head1 SYNOPSIS

This class provides standard non object based events.  If you don't have a 
logical place to hang an event off, hang it off here.

=cut

use Moose::Role;

with 'OpusVL::AuditTrail::Schema::RoleForResult::EvtCreatorRole';

=head2 login_failed

Raise a login failed event.

=cut

sub login_failed
{
    my $self = shift;
    my $username = shift;
    my $address = shift;
    
    $self->evt_raise_event ({ evt_type => 'login-fail', fmt_args => { username => $username, address => $address } });
}

=head2 evt_fmt_login_fail

Method to format the login failure event messages.

=cut
sub evt_fmt_login_fail
{
    my $self = shift;
    my $args = shift;
    return sprintf 'Login attempt failed, username %s from %s.', $args->{username}, $args->{address};
}

=head2 evt_source_name

Method to return the source of the event.

=cut 
sub evt_source_name
{
    return "System event";
}

1;

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
