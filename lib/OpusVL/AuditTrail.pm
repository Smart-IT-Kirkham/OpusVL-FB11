package OpusVL::AuditTrail;

use warnings;
use strict;
use Carp qw/confess/;

=head1 NAME

OpusVL::AuditTrail - Standard audit trail

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.043';


=head1 SYNOPSIS

This module allows the raising of events (essentially an audit trail) that tie closely
to your objects in L<DBIx::Class>.

In order to achieve this close hook up you need to add a field to the objects you want
to log from.  This will allow you to slice events by event type, creator type, and find 
events for an individual record.  

For generic logging not tied directly to an object there is a SystemEvent class that can
be used to log directly.

    $schema->resultset('SystemEvent')->log->login_failed( 'colin', '127.0.0.1' );

Regular logging tends to look like this,

    sub login_failed
    {
        my $self = shift;
        my $username = shift;
        my $address = shift;
        
        $self->evt_raise_event ({ evt_type => 'login-fail', fmt_args => { 
                                        username => $username, address => $address 
                                    } });
    }

    sub evt_fmt_login_fail
    {
        my $self = shift;
        my $args = shift;
        return sprintf 'Login attempt failed, username %s from %s.', $args->{username}, $args->{address};
    }

To get an objects events you then check the C<evt_events>. 

    $obj->evt_events; # EvtEvents resultset constrained to the object.

For the events relating to that object type do,

    EvtCreatorType->find({ id => $obj->evt_creator_type_id })->evt_creators->search_related('evt_events');

=head1 INTEGRATING

In order to integrate the loggging into a table you need to make the following changes,

=head2 DBIx::Class::Schema

In order to hook up the username for logging you need to add this role to your schema class.

    with 'OpusVL::AuditTrail::RolesFor::Schema';

=head2 SCHEMA

Add the following field and foreign key definition to your SQL schema,
to the relation behind each model you'll be audit-trailing.

    evt_creator_type_id  integer, 
    FOREIGN KEY (id, evt_creator_type_id) REFERENCES evt_creators,

=head2 Result

Make sure you regenerate this if you're using DBIx::Class::Schema::Loader or add the fields
and relationship here manually otherwise.

Here's an example from L<Aquarius::OpenERP>:

    __PACKAGE__->add_columns(
        # ... ,
        'evt_creator_type_id' => {
            data_type => 'integer',
            is_nullable => 1
        },
        # ... ,
    );

    # ...

    __PACKAGE__->belongs_to(
      "evt_creator",
      "OpusVL::AuditTrail::Schema::Result::EvtCreator",
      { creator_type_id => "evt_creator_type_id", id => "id" },
      {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
      },
    );
    

=head2 Role For Result

In your C<Result> class, consume the role L<OpusVL::AuditTrail::Schema::RoleForResult::EvtCreatorRole> :

    with 'OpusVL::AuditTrail::Schema::RoleForResult::EvtCreatorRole';

Add calls to create the events,

    $self->evt_raise_event ({ evt_type => 'email-sent' });

And a corresponding function to format the event.

    sub evt_fmt_email_sent
    {
        my $self = shift;
        return sprintf 'Email %s was sent to %s.', $self->letter_type, $self->email_address;
    }

It is also recommended that you implement a method C<evt_source_name> as described in
L<OpusVL::AuditTrail::Schema::RoleForResult::EvtCreatorRole>.

=head2 ResultSet

In your C<ResultSet> class, consume the role L<OpusVL::AuditTrail::Schema::RoleForResultSet::EvtCreatorRole>

Add:

    with 'OpusVL::AuditTrail::Schema::RoleForResultSet::EvtCreatorRole';

Note that you might also need to flip your C<ResultSet> to use Moose if it doesn't already.

    use Moose;
    extends 'DBIx::Class::ResultSet';
    # now the 'with' line

This will give you functions like C<evt_events> so that you can get all the events relating to that object type.

=head2 Additional links

If you want the object to be linked to something like the customer so that it's events also appear as part of the customers events you'll also need to do this,

Edit C<lib/EazyCollect/ECM/Schema/EcmDB/RoleForResult/Customer.pm>

    around evt_events => sub
    {
        my $orig = shift;
        my $self = shift;
        my $my_events  = $self->$orig (@_);
        my $dbt_events = $self->dbt_payments->evt_events;
        my $letter_events = $self->customer_letters->evt_events; # add your source of events
        my $union      = $my_events->union ([ $dbt_events, $letter_events] ); # and here into the union
        return $union;
    };

This way when they look at the customers events they also see in this case the customer letters events too.

=head2 SystemEvent

In order to make use of the SystemEvent class you need to call initdb_populate on the resultset after
the dataset is setup but before the first log message is created.

=head2 Catalyst

The username used the in the events comes from the $schema->evt_username parameter.  To set this simply
do this in your Root controller,

    before auto => sub
    {
        my $self = shift;
        my $c    = shift;

        $c->model ('Model')->schema->evt_username (undef);
    };

    after auto => sub
    {
        my ( $self, $c ) = @_;
        if($c->user)
        {
            $c->model ('Model')->schema->evt_username ($c->user->username);
        }
    }

=head1 AUTHOR

OpusVL, C<< <dev at opusvl.com> >>


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1; # End of OpusVL::AuditTrail
