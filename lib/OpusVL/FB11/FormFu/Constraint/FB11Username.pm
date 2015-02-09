
package OpusVL::FB11::FormFu::Constraint::FB11Username;

=head1 NAME

OpusVL::FB11::FormFu::Constraint::FB11Username - constraint to prevent duplicate usernames.

=head1 DESCRIPTION

Ensures that duplicate user names aren't created.

=head1 METHODS

=cut

use strict;
use base 'HTML::FormFu::Constraint';

=head user_stashkey

Sets the key used to find an existing user in the context stash.

=cut

sub user_stashkey { my $self = shift; my ( $key ) = @_; $self->{user_stashkey} = $key; }

=head constrain_value

This method is used by formfu to hook into this constraints, constraining code.

Returns:
    boolean     - 0 = did not validate, 1 = validated

=cut 

sub constrain_value
{
    my $self                = shift;
    my ( $value, $params)   = @_;
    my $c                   = $self->form->stash->{context};
    my $stashkey            = $self->{user_stashkey} || 'user';
    my $existing            = $c->stash->{$stashkey}->id if ( exists $c->stash->{$stashkey} );
    my $matched             = $c->model('FB11AuthDB::User')->search( { username => $value, ( $existing ? ( id => { '!=' => $existing } ) : () ) } )->count;
    $self->{message} = "Username already in use";
    return ( $matched > 0 ) ? 0 : 1;
}

##
1;
__END__

=head1 NAME

OpusVL::FB11::FormFu::Constraint::FB11Username - Username contraint for the AppKitAuthDB model.

=head1 SYNOPSIS
    
    - type: Text
      name: username
      constraints:
        - type: '+OpusVL::FB11::FormFu::Constraint::FB11Username'
          user_stashkey: user_for_update

=head1 DESCRIPTION

Ensures the value submitted is not already in use for a username with the FB11AuthDB model.

To find existing user (the one we might be updating, therefore the username WILL exist) we check the 
context stash (Catalyst context) and look for stash key identified by 'user_stashkey'.

If the 'user' is in the stash, it will asume it to be a dbix object, pull its id and 
ignore that id when checking for existing usernames.

=head2 Adding a user.

Nothing required except and FB11AuthDB model, which should be in every AppKit app.

=head2 Updating a user.

In the Catalyst stash there must be:
    'user'        - dbix object for the User.

=head1 AUTHORS

Ben Martin

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

