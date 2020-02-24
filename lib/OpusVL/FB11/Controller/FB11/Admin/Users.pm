package OpusVL::FB11::Controller::FB11::Admin::Users;

our $VERSION = '1';

use Moose;
use namespace::autoclean;
use String::MkPasswd qw/mkpasswd/;
use Data::Munge qw/elem/;
use Try::Tiny;
use List::Util qw/pairkeys/;

use OpusVL::FB11::Form;
use OpusVL::FB11::Hive;
use OpusVL::ObjectParams::Adapter::Static;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_myclass              => 'OpusVL::FB11',
);

has_forms (
    user_role_form => 'Admin::Users',
    confirm_form   => 'Confirm',
    user_edit_form => 'Admin::Users::Edit',
    user_add_form  => 'Admin::Users::Add',
);

=head2 auto

    Default action for this controller.

=cut

sub auto
    : Action
    : FB11Feature('User Administration')
{
    my ( $self, $c ) = @_;

    $c->stash->{users_rs} = $c->model('FB11AuthDB::User');
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

    my $form = $self->user_add_form(ctx => $c);
    my $user = $c->model('FB11AuthDB::User')->new_result({});

    $c->stash->{form} = $form;
    $form->process(
        params => $c->req->params,
        posted => !!$c->req->params->{'submit-it'},
        item => $user,
    );

    if ($form->validated) {
        $user->discard_changes;
        $c->flash(
            status_msg => 'User added',
        );

        $c->res->redirect($c->uri_for($self->action_for('show_user'), [ $user->id ]));
        $c->detach;
    }

    $c->stash->{verb} = "Create";
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
    my $user = $c->stash->{thisuser};
    my $upload_form = $c->stash->{upload_form} = $self->form($c, '+OpusVL::FB11::Form::UploadAvatar');

    my $form_config = $self->_build_object_params_fields($c->stash->{thisuser});
    my $init_obj = delete $form_config->{init_obj} // {};

    my @options;
    my @selected;
    for my $role ($c->user->roles_modifiable) {
        if (elem $role, [$c->stash->{thisuser}->role_names]) {
            push @selected, $role,
        }

        push @options, $role, $role;
    }
    $init_obj->{user_roles} = \@selected;

    my $form = $c->stash->{form} = $self->user_role_form(%$form_config);

    # You can't put this in form_config without redefining the entire field
    $form->field('user_roles')->options(\@options);
    $form->process(
        init_object => $init_obj,
        params => $c->req->params,
        posted => !! $c->req->body_params->{submit_roles}
    );
    $upload_form->process($c->req->params);

    if (my $upload = $c->req->upload('file')) {
        my @params = ( file => $upload );
        $upload_form->process(params => { @params });

        if ($upload_form->validated) {
            $user->get_or_default_avatar->update({
                user_id   => $user->id,
                mime_type => $upload->type,
                data      => $upload->slurp,
            });
            $c->flash->{status_msg} = "Successfully updated avatar";
            $c->res->redirect($c->req->uri);
        }
    }

    if ($form->validated) {
        my $user_roles = $form->field('user_roles')->value;
        for my $role(@$user_roles) {
            my $r = $c->model('FB11AuthDB::Role')->find({ role => $role });
            try {
                $user->add_to_users_roles({ role_id => $r->id });
            }
            catch {
                die $_ unless /duplicate key/
            }
        }

        $user->search_related('users_roles',
            { "role.role" => { 'NOT IN' => $user_roles } },
            { join => "role" }
        )->delete;

        $self->_unpack_params_data($user, $form);

        $c->stash->{status_msg} = "User updated";
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

    my $form = $self->form($c, 'Admin::Users::PasswordReset',
        {
            constructor => {
                admin_mode => !!$c->user->has_role('Admin')
            }
        }
    );
    $c->stash->{form} = $form;
    $form->process($c->req->params);
    if ($form->validated) {
        my $password = $form->field('newpassword')->value;

        $user->update( { password => $password } );
        $c->flash->{status_msg} = 'Reset password';
        $c->response->redirect( $prev_url );
    }
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
    my $form = $self->user_edit_form(ctx => $c);
    $c->stash->{form} = $form;

    $form->process(
        item => $c->stash->{thisuser},
        params => $c->req->params,
        posted => !!$c->req->params->{'submit-it'},
    );

    if ($form->validated) {
        $c->flash->{status_msg} = "User updated";
        $c->res->redirect($c->req->uri);
    }

    $c->stash->{verb} = "Edit";
    $c->stash->{template} = "fb11/admin/users/user_form.tt";
}

=head2 disable_user

Disables the user, disallowing access.

=cut

sub disable_user
    : Chained('user_specific')
    : PathPart('disable')
    : Args(0)
    : FB11Feature('User Administration')
{
    my ($self, $c) = @_;

    $c->stash->{thisuser}->update({
        status => 'disabled'
    });

    $c->flash->{status_msg} = "User disabled";
    $c->res->redirect($c->uri_for($self->action_for('index')));
}

=head2 enable_user

(Re-)Enables the user, permitting access.

=cut

sub enable_user
    : Chained('user_specific')
    : PathPart('enable')
    : Args(0)
    : FB11Feature('User Administration')
{
    my ($self, $c) = @_;

    $c->stash->{thisuser}->update({
        status => 'enabled'
    });
    $c->flash->{status_msg} = "User enabled";
    $c->res->redirect($c->uri_for($self->action_for('index')));
}
=head2 delete_user

Attempts to delete the user record. This is only accessible to administrators
and only when DEV_MODE=1.  Will crash if anything restricts the deletion.

=cut

sub delete_user
    : Chained('user_specific')
    : PathPart('delete')
    : Args(0)
    : FB11Feature('Administrator')
{
    my ( $self, $c ) = @_;

    $c->stash->{question} = "Are you sure you want to delete the user <strong>" . $c->stash->{thisuser}->username . "</strong>?";
    $c->stash->{show_permanence_warning} = 1;
    $c->stash->{template} = 'fb11/admin/confirm.tt';
    $c->stash->{form} = $self->confirm_form;
    my $form = $c->stash->{form};
    $form->process($c->req->params);
    if ($form->validated) {
        if ($c->req->params->{submitok}) {
            $c->stash->{thisuser}->delete;
            $c->flash->{status_msg} = "User deleted";
            $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Users')->action_for('index') ) );
        }
        else {
            $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Users')->action_for('index') ) );
        }
    }
}

sub _extension_schemata {
    my $self = shift;
    my $user = shift;

    my $params_adapter = $self->_params_adapter($user);
    my $params_service = OpusVL::FB11::Hive->service('objectparams');

    $params_service->get_form_schemas_for(type => 'fb11core::user');
}

# TODO: This should be done by the User object, which could be achieved simply
# by implementing a role that knows how to make an adapter for DBIC classes. The
# User object *might* think its PK is something other than its email - be wary
# of that.
sub _params_adapter {
    my $self = shift;
    my $user = shift;
    # NOTE: I am keying a user on their email address because the type
    # fb11core::user should define a key and email should be it
    OpusVL::ObjectParams::Adapter::Static->new({
        id => { email => $user->email },
        type => 'fb11core::user'
    });
}

# Gets all the objectparams::extendee schemas and returns a hash to give to the
# form constructor.
sub _build_object_params_fields {
    my $self = shift;
    my $user = shift;

    my $params_service = OpusVL::FB11::Hive->service('objectparams');
    my $params_adapter = $self->_params_adapter($user);
    my $params_form_config = {};
    my $extension_schemata = $self->_extension_schemata($user);

    for my $extender (keys %$extension_schemata) {
        my $schema = $extension_schemata->{$extender};
        my $field_config = OpusVL::FB11::Form->openapi_to_field_list($schema);
        my $extension_data = $params_service->get_parameters_for(
            object => $params_adapter,
            extender => $extender,
        );

        my $fieldset = {
            name => $schema->{'x-namespace'},
            tag => 'fieldset',
            label => $schema->{title},
            render_list => [ pairkeys @$field_config ],
        };

        push $params_form_config->{field_list}->@*, @$field_config;
        push $params_form_config->{block_list}->@*, $fieldset;
        push $params_form_config->{render_list}->@*, $fieldset->{name};

        $params_form_config->{init_obj} //= {};
        if ($extension_data) {
            $params_form_config->{init_obj} = {
                $params_form_config->{init_obj}->%*,
                OpusVL::FB11::Form->openapi_to_init_object(
                    $schema,
                    $extension_data
                )
                ->%*
            };
        }
    }

    return $params_form_config;
}

# De-namespace the form data and send it to its owners. Pass form object
sub _unpack_params_data {
    my $self = shift;
    my $user = shift;
    my $form = shift;

    my $params_service = OpusVL::FB11::Hive->service('objectparams');
    my $params_adapter = $self->_params_adapter($user);
    my $extension_schemata = $self->_extension_schemata($user);

    for my $extender (keys %$extension_schemata) {
        my $schema = $extension_schemata->{$extender};

        $params_service->set_parameters_for(
            object => $params_adapter,
            extender => $extender,
            parameters => $form->values_for_openapi_schema($schema)
        )
    }
}
=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
