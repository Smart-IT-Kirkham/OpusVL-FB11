package TestApp::Controller::Custom;

use Moose;
use namespace::autoclean;
BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }

__PACKAGE__->config
(
    appkit_name                 => 'Custom Controller (within TestApp)',
);

sub custom 
    :Path
    :Args(0)
    :NavigationName("Customer - Index")
    :NavigationHome
{ 
    my ($self, $c) = @_;
    $c->res->body('Hello .. this is the Custom Controller from TestApp' );
}

sub custom_link
    : Path('link')
    : NavigationName("Customer - Link")
{ 
    my ($self, $c) = @_;
    $c->res->body('Hello .. this is the Custom Controller from TestApp -- this is the link' );
}

sub custom_access_denied
    : Path('ad')
{ 
    my ($self, $c) = @_;
    $c->stash->{error_msg} = "Customer accessd denied message";
    $c->go('/index');
}

sub who_can_access_stuff
    :Path('whocan')
    :Args(0)
    :NavigationName("Who Can Access")
{ 
    my ($self, $c) = @_;

    my $string = '';
    foreach my $user ( $c->who_can_access( 'custom/custom' ) )
    {
        $string .= "--" . $user->username;
    }
    $c->res->body("Who: $string");
}


1;
