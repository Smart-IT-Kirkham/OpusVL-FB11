
package OpusVL::AuditTrail::Schema::RoleForResult::EvtCreatorRole;

use Moose::Role;
use MooseX::ClassAttribute;
use JSON;
use Carp;
our @CARP_NOT;

class_has 'audit_updates' => (
	is      => 'rw',
	isa     => 'Bool',
	default => 1,
);

=head1 EvtCreatorRole

This is a moose role that must be included into all objects that may raise
events. The schema definition for these objects must include a
evt_creator_type_id column, and have a foreign key relating to the evt_creators
table.

    package SomePackage;
    use Moose;

    with 'OpusVL::AuditTrail::Schema::RoleForResult::EvtCreatorRole';


Here's an example of the column and foreign key definitions from a result in L<Aquarius::OpenERP>:

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

Once imported the role exposes the following methods:

=cut

=head2 NOTE ON PRIMARY KEY

The primary key of the table must be a single integer column, or this role will not work.
There will be breakage in (at least) C<evt_set_creator> along the lines that
C<column (some value) does not exist>.

=head2 audit_updates

Class attribute to specify whether all database updates should be logged to the
audit trail (defaults to true).

To prevent all updates from being logged (i.e. to raise all audit events manually),
set this property to false in your Result class, i.e.

 __PACKAGE__->audit_updates(0);

=head2 has_evt_creator

Checks whether the evt_creator link has been setup.

=cut

sub has_evt_creator
{
	my $self = shift;

	return $self->evt_creator_type_id ? 1 : 0;
}

=head2 set_evt_creator

This method creates a corresponding creator object and updates the foreign key
reference. This is called automatically after the base class has been inserted.
Note: this means that you cannot raise any events until insert has been called.

=cut

sub set_evt_creator
{
    my $self   = shift;
	my $source = $self->result_source;
    my $schema = $source->schema;

	my $table_name = $source->from;

	my $evt_creator_type = $schema->resultset ('EvtCreatorType')->find_or_create
	({
		creator_type => $table_name
	});

    # We can't guarantee that $self's id will be populated at this stage
    # so load a new copy from the database and work on that.
    $self = $self->get_from_storage() unless $self->id;

    my $evt_creator = $schema->resultset ('EvtCreator')->create
	({
		id           => $self->id,
		creator_type => $evt_creator_type
	});

	$self->evt_creator_type_id ($evt_creator_type->id);
    $self->update;
}

after 'insert' => sub
{
	my $self = shift;

	$self->set_evt_creator;
};

around 'update' => sub
{
	my $orig = shift;
	my $self = shift;
	my $args = shift;

    # avoid doing a select every time we do an update if we don't plan on auditing
    # the change.
    return $self->$orig($args) unless $self->audit_updates;

    my $orig_self = $self->get_from_storage(); # FIXME: could we skip this if there are no dirty columns?
	my %dirty_cols = $self->get_dirty_columns;
	my $rv         = $self->$orig ($args);
	
    if (%dirty_cols)
    {
        $self->evt_raise_event
        ({
            evt_type => 'db-update',
            fmt_args =>
            {
                dirty_cols => [ keys %dirty_cols ],
                orig_self => $orig_self,
            }
        });
    }
	
	return $rv;
};

=head2 evt_raise_event

This actually raises an event. In actual fact just passes control along to the
actual EvtCreator object associated with the base class. This is simply a
convenience method.

You are expected to pass args

    $obj->evt_raise_event({ evt_type => 'test', fmt_args => { } });

You should not use an evt_type called C<'general'> as this will clash with the default
event formatter method C<evt_fmt_general>.

This will call a evt_fmt_$evt_type method.  This can either return a string
which will be put into details and the event field will be filled in with 
the evt_type or it can return a new event type in the C<event> field and
the details too.

If there is no such method, C<evt_fmt_general> is tried.  If that isn't found either,
then this method will die.

    {
         event   => 'An Event',
         details => 'More info about the event'
         data => { text => 1 },
    }

This will do nothing and return silently unless $self->has_event_creator is true.
Ergo, this will usually only work for records inserted after the this AuditTrail role
has been integrated, unless you call $self->set_event_creator somewhere else.
See also the code in C<after insert>#.

=cut

sub evt_raise_event
{
	my $self = shift;
	my $args = shift;

	return 
		unless $self->has_evt_creator;

	my $source = $self->result_source;
	my $schema = $source->schema;

	my $type     = delete $args->{evt_type};
	my $type_obj = $schema->resultset ('EvtType')->find_or_create ({ event_type => $type });

	my $fmt_method = "evt_fmt_$type";
	$fmt_method =~ s/-/_/g;

    my $fmt_info;
    my $fmt_args = delete $args->{fmt_args};
    if ($self->can ($fmt_method))
    {
        $fmt_info = $self->$fmt_method ($fmt_args);
    }
    elsif($self->can('evt_fmt_general'))
    {
        $fmt_info = $self->evt_fmt_general ($fmt_args);
    }
    else
    {
        croak "You're missing a evt_fmt method ($fmt_method)";
    }


    my $evt_args;
    
    if ( $self->can("evt_source_name") )
    {
        $evt_args->{source} = $self->evt_source_name;
    }
    else
    {
        $evt_args->{source} = $self->evt_default_source_name;
    }

	$evt_args->{type_id} = $type_obj->id;

    my $json = JSON->new->allow_nonref->convert_blessed;
    # allow DateTime objects to be encoded in json.
    local *DateTime::TO_JSON = sub { return shift->ymd; };
    if (ref $fmt_info eq 'HASH')
    {
        # new format return value: hashref such as:
        #    {
        #         event   => 'An Event',
        #         details => 'More info about the event'
        #    }

        $evt_args->{event}   = $fmt_info->{event};
        $evt_args->{details} = $fmt_info->{details};
        my $data = $fmt_info->{data};
        if($data)
        {
            $evt_args->{data} = $json->encode($data) 
        }
        else
        {
            $evt_args->{data} = $json->encode($fmt_info);
        }
    }
    else
    {
        $evt_args->{event}   = $type;
        $evt_args->{details} = $fmt_info;
        $evt_args->{data} = $json->encode($fmt_args);
    }

	return $self->evt_creator->add_to_evt_events ($evt_args);
}

=head2 evt_default_source_name

Returns a default string for the source of the object derived from a name field if 
found, or an id.

It will whine if it generates it from the an id.  These are not normally of use to man 
nor beast so it's far better to simply create your own C<evt_source_name> method that 
returns a string giving a human understandable description of the source of the event.  
If the object doing the logging is a customer this could return something like 
'Customer Bill Blogs'.  Something like 'Customer 1' is unlikely to be of much use 
unless that 1 is something exposed in the interface and searchable by the users.

=cut 
sub evt_default_source_name
{
    my $self = shift;

    if ( $self->can('name') && $self->name )
    {
        return $self->result_source->source_name." ".$self->name;
    }
    else
    {
        #carp "Is there a evt_source_name method you'd like to introduce in the schema?";
        return $self->result_source->source_name.", ID ".$self->id;
    }
}

=head2 evt_events

Returns a DBIC::ResultSet of the events associated with this object.

=cut

sub evt_events
{
	my $self = shift;

	return $self->evt_creator->evt_events_rs;
}

=head2 evt_fmt_db_update

Method that formats the db-update event message.

Expects $args to be hashref containing at least keys C<dirty_cols> and C<orig_self>

=cut

sub evt_fmt_db_update
{
	my $self = shift;
	my $args = shift;

	my $dirty_cols = $args->{dirty_cols};
    my $orig_self = $args->{orig_self};

    my $humanize_field_name = sub {
        my $field = shift;
        return join(' ', map { ucfirst($_) } split('_', $field));
    };

    my $format_change = sub {
        my $col = shift;
        my $field = $humanize_field_name->($col);
        my $orig_value = $orig_self->get_column($col);
        my $new_value = $self->get_column($col);
        return sprintf("%s changed from '%s' to '%s'", $field, $orig_value||'', $new_value);
    };

    my @changes = map {$format_change->($_)} @$dirty_cols;

    my $msg = join("\n", @changes);

    return {
                event   => 'Record Update',
                details => $msg
            };
}

=head1 HOOKS

=head2 evt_format_$event_type

Where C<$event_type> is the evt_type passed into C<evt_raise_event> but with
dashes (-) changed to underscores (_).

It's called by C<evt_raise_event> to get a formatted string for the audit log.

Example for event type C<db-update>:

 sub evt_fmt_db_update
 {
 	my $self = shift;
 	my $args = shift;
 
 	my $dirty_cols = $args->{dirty_cols};
 
 	my $msg;
 
 	$msg .= sprintf "  %s => '%s'\n", $_, $self->get_column ($_)
 		foreach @$dirty_cols;
 
     return {
                 event   => 'Record Update',
                 details => $msg
             };
 }

=head2 evt_source_name

You are encouraged to implement C<evt_source_name> in your consuming object
if it doesn't have a C<name> method or field that produces what you want to
include in the event's C<source> field.

For example, for a class representing an email contact, you might define it like this:

 sub evt_source_name($) {
     my $self = shift;
     return sprintf('%s %s <%s>', $self->first_name, $self->last_name, $self->email);
 }

=cut

return 1;

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
