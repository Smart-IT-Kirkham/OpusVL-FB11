package TestX::CatalystX::ExtensionA::Controller::ExtensionA;

use Moose;
use namespace::autoclean;
BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }

__PACKAGE__->config
(
    appkit_name                 => 'ExtensionA',
    appkit_icon                 => 'static/images/flagA.jpg',
    appkit_myclass              => 'TestX::CatalystX::ExtensionA',
);

sub home
    :Path
    :Args(0)
    :NavigationHome
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'extensiona.tt';
}

sub formpage
    :Local
    :Args(0)
    :NavigationName('Form Page')
    :AppKitForm
{
    my ($self, $c) = @_;

    $c->stash->{template} = 'formpage.tt';
}

__END__
