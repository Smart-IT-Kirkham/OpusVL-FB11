package OpusVL::FB11::Controller::FB11::Admin::Users;

use Moose;
use namespace::autoclean;
use String::MkPasswd qw/mkpasswd/;
use Data::Munge qw/elem/;
use Try::Tiny;
use List::Util qw/pairkeys/;

use OpusVL::FB11::Form;
use OpusVL::FB11::Hive;

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

        if (elem $role, [$c->stash->{thisuser}->role_names]) {
            push @selected, $role,
        }

        push @options, $opts;
    }

    $form->field('user_roles')->options(\@options);
    $form->process(
        defaults => { user_roles => \@selected },
        params => $c->req->params,
        posted => !! $c->req->body_params->{submit_roles}
    );
    $upload_form->process($c->req->params);

    # TODO - this is probably more useful done elsewhere
    my $params_form_config = {};
    HAT:
    for my $hat (OpusVL::FB11::Hive->hats('parameters')) {
        if (elem 'OpusVL::FB11::Schema::FB11AuthDB::Result::User', [$hat->get_augmented_classes]) {
            my $schema =  $hat->get_parameter_schema;
            next HAT if not $schema or not %$schema;

            my $field_config = OpusVL::FB11::Form->openapi_to_formhandler($schema);
            my $fieldset = {
                name => $schema->{'x-namespace'},
                tag => 'fieldset',
                label => $schema->{title},
                render_list => [ pairkeys @$field_config ],
            };

            push $params_form_config->{field_list}->@*, @$field_config;
            push $params_form_config->{block_list}->@*, $fieldset;
            push $params_form_config->{render_list}->@*, $fieldset->{name};
            $params_form_config->{defaults} //= {};
            $params_form_config->{defaults} = {
                $params_form_config->{defaults}->%*,
                OpusVL::FB11::Form->openapi_to_init_object(
                    $schema,
                    $hat->get_augmented_data($c->stash->{thisuser})
                )
                ->%*
            };
        }
    }

    if (%$params_form_config) {
        my $defaults = delete $params_form_config->{defaults};
        push $params_form_config->{field_list}->@*, (
            submit_params => 'Submit'
        );
        push $params_form_config->{render_list}->@*, 'submit_params';

        my $params_form = $c->stash->{params_form} = OpusVL::FB11::Form->new($params_form_config);

        $params_form->process(
            defaults => $defaults,
            params => $c->req->params,
            posted => !! $c->req->body_params->{submit_params},
        );

        if ($params_form->validated) {
            for my $hat (OpusVL::FB11::Hive->hats('parameters')) {
                my $schema =  $hat->get_parameter_schema;
                if (elem 'OpusVL::FB11::Schema::FB11AuthDB::Result::User', [$hat->get_augmented_classes]) {
                    $hat->set_augmented_data(
                        $c->stash->{thisuser},
                        $params_form->params_back_to_openapi( $schema )
                    )
                }
            }

            $c->flash->{status_msg} = "Successfully updated parameters";
            $c->res->redirect($c->req->uri);
        }
    }

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
                my $r = $c->model('FB11AuthDB::Role')->find({ role => $role });
                try {
                    $c->stash->{thisuser}->add_to_users_roles({ role_id => $r->id });
                }
                catch {
                    die $_ unless /duplicate key/
                }
            }

            $c->stash->{thisuser}->search_related('users_roles',
                { "role.role" => { 'NOT IN' => $user_roles } },
                { join => "role" }
            )->delete;
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


=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
