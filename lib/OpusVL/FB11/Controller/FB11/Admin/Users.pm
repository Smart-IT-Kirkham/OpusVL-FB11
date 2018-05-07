package OpusVL::FB11::Controller::FB11::Admin::Users;

use Moose;
use namespace::autoclean;
use String::MkPasswd qw/mkpasswd/;
use Data::Munge qw/elem/;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_myclass              => 'OpusVL::FB11',
);

has_forms (
    user_role_form => 'Admin::Users',
    confirm_form   => 'Confirm',
);

=head2 auto

    Default action for this controller.

=cut

sub auto
    : Action
    : FB11Feature('User Administration')
{
    my ( $self, $c ) = @_;

    # add to the bread crumb..
    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Users', url => $c->uri_for( $c->controller('FB11::Admin::Users')->action_for('index') ) } );

    # stash all users..
    my $users_rs = $c->model('FB11AuthDB::User')->search;
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
    : FB11Feature('User Administration')
{
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'fb11/admin/users/show_user.tt';
}

=head2 adduser

=cut

sub adduser
    : Local
    : Args(0)
    : FB11Feature('User Administration')
{
    my ( $self, $c ) = @_;

    push @{$c->stash->{breadcrumbs}}, {
        name    => 'Add',
        url     => $c->uri_for($c->controller('FB11::Admin::Users')->action_for('adduser'))
    };

    $c->stash->{page_options} = [
        { url => $c->uri_for($self->action_for('index')), title => 'Back to users' },
    ];

    my $form = $self->form($c, 'Admin::AddUser');

    $c->stash->{form} = $form;
    $form->process($c->req->params);

    if ($form->validated) {
        my $password = $form->field('password')->value;
        my $new_user = $c->model('FB11AuthDB::User')->create({
            username => $form->field('username')->value,
            password => $password,
            email    => $form->field('email')->value,
            name     => $form->field('name')->value,
            tel      => $form->field('tel')->value,
            status   => $form->field('status')->value,
        });

        $c->flash(
            status_msg => 'User added',
        );
        
        $c->res->redirect($c->uri_for($self->action_for('show_user'), [ $new_user->id ]));
        $c->detach;
    }

    $c->stash->{h1}       = "Add User";
    $c->stash->{template} = "fb11/admin/users/user_form.tt";
}

=head2 user_specific

    Start of chain.

=cut

sub user_specific
    : Chained('/')
    : PathPart('user')
    : CaptureArgs(1)
    : FB11Feature('User Administration')
{
    my ( $self, $c, $user_id ) = @_;
    ( $c->stash->{thisuser} ) = $c->model('FB11AuthDB::User')->find( $user_id );
}

=head2 show_user

    End of chain.
    Display a users details.

=cut

sub show_user
    : Chained('user_specific')
    : PathPart('show')
    : FB11Feature('User Administration')
    : Args(0)
{
    my ( $self, $c ) = @_;
    my $form = $self->user_role_form;
    my $upload_form = $self->form($c, '+OpusVL::FB11::Form::UploadAvatar');
    $c->stash->{form} = $form;
    $c->stash->{upload_form} = $upload_form;
    push @{ $c->stash->{breadcrumbs} }, {
        name    => $c->stash->{thisuser}->username,
        url     => $c->uri_for($c->controller('FB11::Admin::Access')->action_for('show_user'), [ $c->stash->{thisuser}->id ])
    };

    my @options;
    my @selected;
    for my $role ($c->user->roles_modifiable) {
        my $opts = {
            value => $role,
            label => $role,
        };

        if (elem $role, [$c->stash->{thisuser}->roles]) {
            push @selected, $role,
        }

        push @options, $opts;
    }

    $form->field('user_roles')->options(\@options);
    $form->process(defaults => { user_roles => \@selected });
    $form->process($c->req->params);
    $upload_form->process($c->req->params);


    if (my $upload = $c->req->upload('file')) {
        my @params = ( file => $upload );
        $upload_form->process(params => { @params });

        if ($upload_form->validated) {
            $c->stash->{thisuser}->get_or_default_avatar->update({
                user_id   => $c->stash->{thisuser}->id,
                mime_type => $upload->type,
                data      => $upload->slurp,
            });
            $c->flash->{status_msg} = "Successfully updated avatar";
            $c->res->redirect($c->req->uri);
        }
    }

    if ($form->validated) {   
        my $user_roles = $form->field('user_roles')->value;
        if (@$user_roles) {
            foreach my $role(@$user_roles) {
                $c->stash->{thisuser}->find_or_create_related('users_roles', { role => $role } );
            }

            $c->stash->{thisuser}->search_related('users_roles', { role => { 'NOT IN' => $user_roles } } )->delete;
            $c->stash->{status_msg} = "User Roles updated";
        }   
    }
}


sub user_avatar
    : Chained('user_specific')
    : PathPart('avatar')
    : FB11Feature('User Avatars')
    : Args(0)
{
    my ($self, $c) = @_;
    my $user = $c->stash->{thisuser};
    if (my $avatar = $user->get_or_default_avatar) {
        $c->res->content_type($avatar->mime_type);
        $c->res->body($avatar->data);
    }
}

sub reset_password
    : Chained('user_specific')
    : PathPart('reset')
    : FB11Feature('User Password Administration')
    : Args(0)
{
    my ( $self, $c ) = @_;

    my $user = $c->stash->{thisuser};
    my $prev_url = $c->uri_for( $self->action_for('show_user'), [ $user->id ] );

    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Reset password', url => $c->uri_for( $c->controller('FB11::Admin::Access')->action_for('reset_password'), [ $user->id ] ) } );

    $c->forward('/fb11/admin/users/reset_password_form', [ $prev_url, $user ] );
}

# to allow other controllers to forward to this setting their own 
# breadcrumbs and passing their own url.
sub reset_password_form
    : Action
    : FB11Feature('User Password Administration')
{
    my ($self, $c, $prev_url, $user) = @_;

    if ($c->req->param('cancel')) {
        $c->response->redirect( $prev_url );
        $c->detach;
    }

    my $form = $self->form($c, 'Admin::Users::PasswordReset');
    $c->stash->{form} = $form;
    $form->process($c->req->params);
    if ($form->validated) {
        my $password = $form->field('newpassword')->value;

        $user->update( { password => $password } );
        $c->flash->{status_msg} = 'Reset password';
        $c->response->redirect( $prev_url );
    }
    # FIXME: wut is this?
    #else
    #{
    #    $c->stash->{form}->default_values( {
    #            newpassword => mkpasswd,
    #            user => $user->username,
    #        });
    #}
}

=head2 edit_user

    End of chain.
    Display a users details.

=cut

sub edit_user
    : Chained('user_specific')
    : PathPart('form')
    : Args(0)
    : FB11Feature('User Administration')
{   
    my ( $self, $c ) = @_;
    $c->stash->{page_options} = [
        { url => $c->uri_for($self->action_for('show_user'), [ $c->stash->{thisuser}->id ]), title => 'Back to ' . $c->stash->{thisuser}->name },
        { url => $c->uri_for($self->action_for('index')), title => 'Show users' },
    ];
    my $form = $self->form($c, 'Admin::AddUser', { update => 1 });
    $c->stash->{form} = $form;

    push @{$c->stash->{breadcrumbs}}, {
        name    => 'Edit',
        url     => $c->uri_for($c->controller('FB11::Admin::Access')->action_for('edit_user'), [ $c->stash->{thisuser}->id ])
    };

    my @fields = qw<username password name email tel status>;

    my $defaults = {};
    $defaults->{$_} = $c->stash->{thisuser}->$_
        for @fields;

    $form->process(init_object => $defaults, params => $c->req->params);
    if ($form->validated) {
        for (@fields) {
            if (my $res = $form->field($_)->value) {
                $c->stash->{thisuser}->$_($res);
            }
        }
        $c->stash->{thisuser}->update;
        $c->flash->{status_msg} = "User updated";
        $c->res->redirect($c->req->uri);
    }

    $c->stash->{h1}       = "Edit User";
    $c->stash->{template} = "fb11/admin/users/user_form.tt";
}

=head2 delete_user

    End of chain.

=cut

sub delete_user
    : Chained('user_specific')
    : PathPart('delete')
    : Args(0)
    : FB11Feature('User Administration')
{
    my ( $self, $c ) = @_;

    $c->stash->{question} = "Are you sure you want to delete the user:" . $c->stash->{thisuser}->username;
    $c->stash->{template} = 'fb11/admin/confirm.tt';
    $c->stash->{form} = $self->confirm_form;
    my $form = $c->stash->{form};
    $form->process($c->req->params);
    if ($form->validated) {
        if ($c->req->params->{submitok}) {
            $c->stash->{thisuser}->status('deleted');
            $c->flash->{status_msg} = "User deleted";
            $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Users')->action_for('index') ) );
        }
        else {
            $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Users')->action_for('index') ) );
        }
    }
}


=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
