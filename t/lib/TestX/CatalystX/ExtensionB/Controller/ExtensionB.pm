package TestX::CatalystX::ExtensionB::Controller::ExtensionB;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name                 => 'Extension Bee',
    fb11_icon                 => 'static/images/flagB.jpg',
    fb11_myclass              => 'TestX::CatalystX::ExtensionB',
);


sub auto 
    :Private
{
    my ($self, $c) = @_;

    #$c->stash->{current_model}  = 'BookDB::Author';
}


=head2 home
    bascially the index path for this controller.
=cut
sub home
    :Path
    :Args(0)
    :NavigationHome
    :NavigationName('ExtensionB Home')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'extensiona.tt';
}


=head2 formpage 
    Testing not only the loading of a FormFu config file but also if that config
    can access a model and pull data from it.
=cut
sub formpage
    :Local
    :Args(0)
    :NavigationName('Form Page')
{
    my ($self, $c) = @_;

    # stash all books..
    my $rs = $c->model('BookDB::Book')->search;
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my @books = $rs->all;
    my @authors = $c->model('BookDB::Author')->all;
    $c->stash->{books} = \@books;

    my $form = $self->form($c, '+OpusVL::FB11::Form::Test::ExtensionB', { item => $c->model('BookDB::Author')->search });
    my @options = map { { value => $_->id, label => $_->full_name } } @authors;
    $form->field('author')->options(\@options);
    $c->stash->{form} = $form;
    $form->process($c->req->params);

    $c->stash->{template} = 'formpage.tt';
}


__END__
