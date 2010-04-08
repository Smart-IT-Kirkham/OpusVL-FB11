package OpusVL::AppKit::Controller::AppKitAdmin::Users;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

=head2 auto
    Default action for this controller.
=cut
sub auto
    : Private
{
    my ( $self, $c ) = @_;

    # add to the bread crumb..
    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Users', url => $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('index') ) } );

    # stash all users..
    my $users_rs = $c->model('AppKitAuthDB::User')->search;
    $users_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my @users = $users_rs->all;
    $c->stash->{users} = \@users;

}

=head2 index
    default action for access administration.
=cut
sub index
    : Path
    : Args(0)
{
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'appkitadmin/users/show_user.tt';
}

=head2 user_specific
    Start of chain.
=cut
sub user_specific
    : Chained('/')
    : PathPart('user')
    : CaptureArgs(1)
{
    my ( $self, $c, $user_id ) = @_;
    ( $c->stash->{user} ) = $c->model('AppKitAuthDB::User')->find( $user_id );
}

=head2 show_user
    End of chain.
    Display a users details.
=cut
sub show_user
    : Chained('user_specific')
    : PathPart('show')
    : Args(0)
{
    my ( $self, $c ) = @_;

    # test if need to process user submission...
    if ( $c->req->method eq 'POST' )
    {   
        my $user_roles = $c->req->params->{user_role};
        $user_roles = [ $user_roles ] if defined $user_roles && ! ref $user_roles;

        foreach my $role_id ( @$user_roles )
        {
            $c->stash->{user}->find_or_create_related('user_roles', { role_id => $role_id } );
        }

        $c->log->debug("************************** SUBMITTED ROLES: $#$user_roles :" . join('|', @$user_roles) );
        $c->stash->{user}->search_related('user_roles', { role_id => { 'NOT IN' => $user_roles } } )->delete;
    }

    # capture and stash role information for the user..
    my @roles;
    foreach my $role_rs ( $c->model('AppKitAuthDB::Role')->search )
    {
        my $checked = '';
        if ( $c->stash->{user}->search_related('user_roles', { role_id => $role_rs->id } )->count > 0 )
        {
            $checked = 'checked';
        }
        push( @roles, { role => $role_rs->role, input => "<INPUT TYPE='checkbox' NAME='user_role' VALUE='".$role_rs->id."' $checked>" } );
    }
    $c->stash->{roles} = \@roles;
}

=head2 delete_user
    End of chain.
=cut
sub delete_user
    : Chained('user_specific')
    : PathPart('delete')
    : Args(0)
{
    my ( $self, $c ) = @_;
    $c->stash->{user}->delete;
    $c->res->redirect( $c->uri_for( $c->controller->action_for('index') ) );
}

=head2 user_add_to_role
    End of chain.
    Adds a user to a role
=cut
sub user_add_to_role
    : Chained('user_specific')
    : PathPart('adduser')
    : Args(0)
{
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' )
    {
        # create the look up..
        my $user_id        = $c->req->param('user_id');
        $c->stash->{role}->update_or_create_related('user_roles', { user_id => $user_id } );
    }

    # refresh show page..
    $c->res->redirect( $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

1;
__END__
