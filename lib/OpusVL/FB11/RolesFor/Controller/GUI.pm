package OpusVL::FB11::RolesFor::Controller::GUI;

our $VERSION = '1';

=head1 NAME

    OpusVL::FB11::RolesFor::Controller::GUI - Role for Controllers wanting to interact with FB11

=head1 SYNOPSIS

    package MyApp::Controller::SomeFunkyThing;
    use Moose;
    BEGIN{ extends 'Catalyst::Controller' };
    with 'OpusVL::FB11::RolesFor::Controller::GUI';

    __PACKAGE__->config( fb11_name        => 'My Funky App' );
    __PACKAGE__->config( fb11_icon        => 'static/funkster/me.gif' );
    __PACKAGE__->config( fb11_myclass     => 'MyApp' );
    
    sub index
        :Path
        :Args(0)
        :NavigationHome
        :NavigationName("Funky Home")
        :Widget("Funky Widget")
        :FB11Form
    {   
        # .. do some funky stuff .. 
    }
        
=head1 DESCRIPTION

    If you use this Moose::Role with a controller it can be intergrated into the OpusVL::FB11.

    You can just do: 
        use Moose;
        with 'OpusVL::FB11::RolesFor::Controller::GUI';

    Give your Controller a name within the GUI:
        __PACKAGE__->config( fb11_name => 'Some Name' );

    To make use of the additional features you will have to use one of the following
    action method attributes:

        NavigationHome
            This tells the GUI this action is the 'Home' action for this controller.

        NavigationName
            Tells the GUI this action is a navigation item and what its name should be.

        Widget
            Tells the GUI this action is a widget action, so calling is only garented to fill
            out the 'widget' stash key.

        SearchName
            Tells the GUI this action is a search action and what its name should be
    
=head1 METHODS

=cut

##################################################################################################################################
# use lines.
##################################################################################################################################
use strict;
use Moose::Role;
with 'OpusVL::FB11::RolesFor::Controller::FormHandler';
with 'OpusVL::FB11::RolesFor::Controller::UI';


##
1;
