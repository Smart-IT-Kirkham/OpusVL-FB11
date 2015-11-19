package OpusVL::FB11::Controller::FB11::User;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_myclass              => 'OpusVL::FB11',
);

=head2 change_password

=cut

sub change_password
    : Path('changepword')
    : Args(0)
    : FB11Feature('Password Change')
{
    my ($self, $c ) = @_;
    my $form = $self->form($c, 'Admin::Users::PasswordReset');
    $c->stash->{form} = $form;
    $form->process($c->req->params);
    if ($form->validated) {
        my $password = $c->req->params->{'newpassword'};

        $c->user->update({ password => $password });
        $c->stash->{hide_form} = 1;
    }
}

sub favourite_page
    : Path('favourite')
    : Args(0)
    : FB11Feature('Add Page to Favourites')
{
    my ($self, $c) = @_;
    if (my $page = $c->req->query_params->{page} and my $name = $c->req->query_params->{name}) {
       my $fav_rs = $c->model('FB11AuthDB::UsersFavourite')->search({ user_id => $c->user->id });
       if (my $fav_page = $fav_rs->find({ page => $page })) {
            $fav_page->delete();
       }
       else {
            $fav_rs->create({
                page    => $page,
                name    => $name,
                user_id => $c->user->id,
            })
       }

       $c->res->redirect($page);
    }
}
=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
