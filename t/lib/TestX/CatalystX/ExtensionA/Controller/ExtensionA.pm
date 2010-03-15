package TestX::CatalystX::ExtensionA::Controller::ExtensionA;

use Moose;
use namespace::autoclean;
BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }

__PACKAGE__->config
(
    appkit_name                 => 'ExtensionA',
    appkit_icon                 => 'static/images/flagA.jpg',
);

sub home
    :Path
    :Args(0)
    :NavigationName("Home")
    :NavigationHome
{
    my ($self, $c) = @_;

    $c->stash->{template} = 'extensiona.tt';
}

__END__
