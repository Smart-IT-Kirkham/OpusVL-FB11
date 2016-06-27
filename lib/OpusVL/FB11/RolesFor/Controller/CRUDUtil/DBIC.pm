package OpusVL::FB11::RolesFor::Controller::CRUDUtil::DBIC;
use strict;
use warnings;
use Moose::Role;
use Try::Tiny;

sub _crudutil_dbic_process_form
{
    my ($self, $c, %params) = @_;
    die "item is required" unless exists($params{item});
    my $item = $params{item};
    my $form = $params{form} or die "form is required";
    my $redirect_function = $params{success_redirect};
    unless (defined $redirect_function) {
        $redirect_function = sub { $c->uri_for($self->action_for('edit'), [shift->id]) };
    }
    unless ($item) {
        $c->detach('/not_found');
    }
    my $caught_exception;
    try {
        $form->process(
            item   => $item,
            params => $c->req->params,
        );
    }
    catch {
        if (/duplicate/) {
            $c->stash->{error_msg} = 'Cannot save duplicate record';
            $caught_exception = 1;
        }
        else {
            die $_;
        }
    };
    $c->stash(form => $form);
    $c->detach if $caught_exception;
    if ($form->validated) {
        $c->res->redirect( $redirect_function->($item) );
        $c->flash->{status_msg} = $params{success_msg};
        $c->detach;
    }
}

1;

=head1 NAME

OpusVL::FB11::RolesFor::Controller::CRUDUtil::DBIC - helpers for CRUD operations on DBIx::Class objects

=head1 SYNOPSIS

Controller:

    package MyApp::FB11X::Component::Controller::Person; 

    use strict;
    use warnings;
    use Moose;
    use namespace::autoclean;
    BEGIN { extends 'Catalyst::Controller' };
    with(
        'OpusVL::FB11::RolesFor::Controller::GUI',
        'OpusVL::FB11::RolesFor::Controller::CRUDUtil::DBIC',
    );

    __PACKAGE__->config(
    # etc
    );

    has_forms (
        person_form => 'Person',
    );

    sub edit
        :Path
        :Args(1)
        :FB11Feature('Read Person')
        :NavigationName('Person List')
    {
        my ($self, $c, $person_id) = @_;
        $c->stash(verb => 'Edit', template => 'myapp/people/person_form.tt');
        $self->_crudutil_dbic_process_form($c, 
            item => $c->model('MyAppDB::Person')->find($person_id),
            form => $self->person_form,
            success_msg => 'Person created',
        );
    }

    sub create
        :Local
        :FB11Feature('Create Reseller')
        :NavigationName('Create Reseller')
    {
        $c->stash(verb => 'Create', template => 'myapp/people/person_form.tt');
        $self->_crudutil_dbic_process_form($c,
            item => $c->model('MyAppDB::Person')->new({}),
            form => $self->person_form,
            success_msg => 'Person saved',
        );
    }

=head1 METHODS

=head2 _crudutil_dbic_process_form

    $self->_crudutil_dbic_process_form($c,
        item => $c->model('MyAppDB::Person')->find($person_id),
        form => $self->person_form,
        success_msg => 'Person created',
    );


This captures the most common pattern where you create or edit a L<DBIx::Class> result via a
form with L<HTML::FormHandler::TraitFor::Model::DBIC>.

To edit and save a new object, pass in

    item => $c->model('MyAppDB::Person')->new({})

or a version thereof that sets up some sensible defaults for GUI creation.

Apart from the positional argument C<$c>, you also need to pass in the following named arguments, accepted as a hash of arguments:

=over 8

=item item

The object that is to be edited and saved by the form

=item form

An L<HTML::FormHandler> ready to handle the item with the C<process> method.

It should have role L<HTML::FormHandler::TraitsFor::Model::DBIC>.
Another role that implements the same interface should also work, but not tested so your mileage may vary.

=item success_msg

The message to put in the flash->{status_msg} before redirection after a successful save.

=item success_redirect (optional)

A CODEREF that returns the URL to redirect the user to after a successful save.

The default is as if you passed in this:

    success_redirect => sub {
        my $item = shift ;
        return $c->uri_for($self->action_for('edit'), [$item->id]);
    },

By default, it will redirect to the 'edit' action on the current controller, passing in a single argument, the
id of the edited or created item.

=back

