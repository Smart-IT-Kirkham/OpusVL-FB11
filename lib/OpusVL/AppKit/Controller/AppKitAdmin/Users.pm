package OpusVL::AppKit::Controller::AppKitAdmin::Users;

use Moose;
use namespace::autoclean;

BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }
__PACKAGE__->config
(
    appkit_myclass              => 'OpusVL::AppKit',
);

=head2 auto
    Default action for this controller.
=cut
sub auto
    : Private
{
    my ( $self, $c ) = @_;

    # add to the bread crumb..
    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Users', url => $c->uri_for( $c->controller('AppKitAdmin::Users')->action_for('index') ) } );

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

=head2 user_add_form
=cut
sub adduser
    : Local
    : Args(0)
    : AppKitForm("appkitadmin/users/user_form.yml")
{
    my ( $self, $c ) = @_;

    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Add', url => $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('adduser') ) } );

    if ( $c->stash->{form}->submitted_and_valid )
    {
        my $user = $c->model('AppKitAuthDB::User')->new_result( {} );
        $c->stash->{form}->model->update( $user );
        $c->stash->{status_msg} = "User added";
    }
    $c->stash->{template} = "appkitadmin/users/user_form.tt";
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

    push ( @{ $c->stash->{breadcrumbs} }, { name => $c->stash->{user}->username, url => $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('show_user'), [ $c->stash->{user}->id ] ) } );

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

=head2 edit_user
    End of chain.
    Display a users details.
=cut
sub edit_user
    : Chained('user_specific')
    : PathPart('form')
    : Args(0)
    : AppKitForm("appkitadmin/users/user_form.yml")
{
    my ( $self, $c ) = @_;

    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Edit', url => $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('edit_user'), [ $c->stash->{user}->id ] ) } );

    if ( $c->stash->{form}->submitted_and_valid )
    {
        # update the user from the form..
        $c->stash->{form}->model->update( $c->stash->{user} );
        $c->stash->{status_msg} = "User updated";
    }

    # set default values..
    $c->stash->{form}->model->default_values( $c->stash->{user} );
    $c->stash->{template} = "appkitadmin/users/user_form.tt";
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

=head2 delete_parameter
    End of chain.
=cut
sub delete_parameter
    : Chained('user_specific')
    : PathPart('deleteparameter')
    : Args(1)
{
    my ( $self, $c, $param_id ) = @_;

    $c->stash->{user}->delete_related('user_parameters', { parameter_id => $param_id } );
    $c->stash->{status_msg} = "Parameter deleted";
    $c->go( $c->controller->action_for('index') );
}

=head2 add_parameter
    End of chain.
=cut
sub add_parameter
    : Chained('user_specific')
    : PathPart('addparameter')
    : Args(0)
{
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' )
    {
        my $parameter_id        = $c->req->param('parameter_id');
        my $parameter_value     = $c->req->param('parameter_value');
        $c->stash->{user}->update_or_create_related('user_parameters', { parameter_id => $parameter_id, value => $parameter_value } );
        $c->stash->{status_msg} = "Parameter updated";
    }

    # refresh show page..
    $c->res->redirect( $c->uri_for( $c->controller('AppKitAdmin::User')->action_for('show_user'), [ $c->stash->{user}->id ] ) ) ;
}


1;
__END__
