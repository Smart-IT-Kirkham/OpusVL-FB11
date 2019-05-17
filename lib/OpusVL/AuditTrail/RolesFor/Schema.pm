package OpusVL::AuditTrail::RolesFor::Schema;

=head1 NAME

package OpusVL::AuditTrail::RolesFor::Schema;

=head1 SYNOPSIS

This allows for our logging to be inserted into an existing schema and make use of the existing
connection details.  The class can inject our schema objects into the existing schema.  It is also
used to hook up the username details from the web framework.

    # in your schema class.
    with 'OpusVL::AuditTrail::RolesFor::Schema';
    OpusVL::AuditTrail::RolesFor::Schema->setup_sysparams(__PACKAGE__);

    # now to set the username for the events do
    $schema->evt_username($user);


=head1 METHODS

=head2 evt_username

=head2 evt_addr

=cut

use Moose::Role;
use feature 'state';

# FIXME: need to hook up some easy way to get this set.
sub evt_username
{
	# this is a bit nasty, and potentially prone to confusion if we ever want
	# to run multiple difference EcmDB configs in the same process (which we
	# shouldn't!!!!). the proper way would probably involve a singlton, or
	# maybe save to a temporary DB table?? anyway, this should hopefully do for
	# now

	state $evt_username;

	my $self = shift;

	$evt_username = shift
		if $#_ == 0;

	return $evt_username;
}

sub evt_addr
{
    state $ip_addr;
    my ($self, $addr) = @_;
    
    $ip_addr = $addr
        if $addr;

    return $ip_addr;
}

=head2 setup_sysparams

This method injects the result/resultset objects needed by the AuditTrail object into a the schema
this role has been applied to.  If this isn't called as suggested in the synopsis you will need to
have these results already loaded in your schema somehow.

=cut

# FIXME: point it to our schema stuff.
sub setup_sysparams
{
    my $class = shift;
    my $package = shift;
    # NOTE: you're better off doing,
    #
    # __PACKAGE__->setup_audittrail;
    #
    $package->setup_audittrail;
}

=head2 setup_audittrail

This will method will load the DBIC classes into your schema.

    __PACKAGE__->setup_audittrail;

This superceeds the setup_sysparams method because it's simpler to call
and better named. (i.e. not a dodgy copy/paste job).

=cut

sub setup_audittrail
{
    my $package = shift;
    $package->load_namespaces(
        result_namespace => '+OpusVL::AuditTrail::Schema::Result',
        resultset_namespace => '+OpusVL::AuditTrail::Schema::ResultSet',
    );
}


=head1 LICENSE AND COPYRIGHT

Copyright 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
