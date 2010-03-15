package OpusVL::AppKit::Base::Controller::GUI;

=head1 NAME

    OpusVL::AppKit::Base::Controller::GUI - Base Controller for those wanting to interact with AppKit

=head1 SYNOPSIS

    package MyApp::Controller::SomeFunkyThing;
    use Moose
    BEGIN{ extends 'OpusVL::AppKit::Base::Controller::GUI' };

    __PACKAGE__->config( appkit_name => 'My Funky App' );
    
    sub index
        :Path
        :Args(0)
        :NavigationHome
        :NavigationName("Funky Home")
        :PortletName("Funky Portlet")
    {   
        # .. do some funky stuff .. 
    }
        
=head1 DESCRIPTION

    If you extend this controller it can be intergrated into the OpusVL::AppKit.

    You can just do: 
        extends 'OpusVL::AppKit::Base::Controller::GUI';

    Give your Controller a name within the GUI:
        __PACKAGE__->config( appkit_name => 'Some Name' );

    To make use of the additional features you will have to use one of the following
    action method attributes:

        NavigationHome
            This tells the GUI this action is the 'Home' action for this controller.

        NavigationName
            Tells the GUI this action is a navigation item and what its name should be.

        PortletName
            Tells the GUI this action is a portlet action, so calling is only garented to fill
            out the 'portlet' stash key.
    

=head1 SEE ALSO

    L<CatalystX::AppBuilder>,
    L<OpusVL::AppKit>,
    L<Catalyst>

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 LICENSE

    This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself.

=cut

##################################################################################################################################
# use lines.
##################################################################################################################################
use Moose;
use namespace::autoclean;

##################################################################################################################################
# moose calls.
##################################################################################################################################

BEGIN { extends 'Catalyst::Controller'; }

has appkit                  => ( is => 'ro',    isa => 'Int',                       default => 1 );
has appkit_name             => ( is => 'ro',    isa => 'Str',                       default => 'AppKit' );

=head2 home_action

    This should return undef or the Catalyst::Action that related to the Home action for GUI.

    It knows which action to return by looking through all the available AppKit actions
    and returning the ones marked with a 'NavigationHome' action method attribute.
    
=cut
has home_action             => ( is => 'ro',    isa => 'Catalyst::Action|Undef',    lazy_build => 1 );
sub _build_home_action
{
    my $self  = shift;
    my $home_action;
    foreach ( keys %{ $self->_appkit_action_info } )
    {
        next unless $self->_appkit_action_info->{$_}->{enabled_home};

        $home_action = $self->action_for( $self->_appkit_action_info->{$_}->{action_name} );
        last;
    }
    return $home_action;
}
=head2 navigation_actions

    This should return a HashRef,  keyed by the action_name with a value of the Catalyst::Action

    This hash ref is built by parseing the '_appkit_action_info' for all action method marked with a
    'NavigationName' attribute.
    
=cut
has navigation_actions      => ( is => 'ro',    isa => 'HashRef',                   lazy_build => 1 );
sub _build_navigation_actions
{
    my $self  = shift;
    my %navigations;
    foreach ( keys %{ $self->_appkit_action_info } )
    {
        next unless $self->_appkit_action_info->{$_}->{enabled_navigation};
        $navigations{ $self->_appkit_action_info->{$_}->{navigation_name} } = $self->action_for( $self->_appkit_action_info->{$_}->{action_name} );
    }
    return \%navigations;
}
=head2 portlet_actions

    This should return a HashRef of portlet name and actions.

    This hash ref is built by parseing the '_appkit_action_info' for all action method marked with a
    'PortletName' attribute.
=cut
has portlet_actions         => ( is => 'ro',    isa => 'HashRef',                   lazy_build => 1 );
sub _build_portlet_actions
{
    my $self  = shift;
    my %portlets;
    foreach ( keys %{ $self->_appkit_action_info } )
    {
        next unless $self->_appkit_action_info->{$_}->{enabled_portlet};

        my $key     = $self->_appkit_action_info->{$_}->{portlet_name} ;
        my $val   = $self->_appkit_action_info->{$_}->{action_name};
        $portlets{ $self->_appkit_action_info->{$_}->{portlet_name} } = $self->action_for( $self->_appkit_action_info->{$_}->{action_name} );
    }
    return \%portlets;
}

=head2 _build__appkit_action_info
    _appkit_action_info is a var used to hold information from the parsing of all AppKit contollers and actions.
    This var is used internally to enable quick access to controller/action based data.
=cut
has _appkit_action_info     => ( is => 'ro',    isa => 'HashRef',       lazy_build => 1 );
sub _build__appkit_action_info
{
    my ( $self ) = shift;
    
    my %action_info;

    # Loop through all this controllers actionmethods...
    foreach my $action_method ( $self->get_action_methods )
    {   
        next if $action_method->name =~ /^_/;
        my $action = $self->action_for( $action_method->name );
        next unless defined $action;

        my %appkit_action_info = 
        (
            action_name         => $action->name,

            enabled_navigation  => 0,
            enabled_portlet     => 0,
            enabled_home        => 0,
        );

        # .. check all attributes against this action..
        foreach my $attr ( keys %{ $action->attributes } )
        {   
            if ( $attr eq 'NavigationName' )            # check for a NavigationName action
            {   
                $appkit_action_info{enabled_navigation}     = 1;
                ( $appkit_action_info{navigation_name} )    = @{ $action->attributes->{$attr} };
            }
            elsif ( $attr eq 'NavigationHome' )        # check for a Home action
            {   
                $appkit_action_info{enabled_home}     = 1;
            }
            elsif ( $attr eq 'PortletName' )            # check for any Portlet actions.
            {   
                $appkit_action_info{enabled_portlet}    = 1;
                ( $appkit_action_info{portlet_name} )   = @{ $action->attributes->{$attr} };
            }
        }
        
        # put information into list..
        $action_info{ $action_method->name } = \%appkit_action_info; 
    } 

    # set the _appkit_action_info hash ref..
    return \%action_info; 
}

##################################################################################################################################
# controller actions.
##################################################################################################################################
=head2 stash_navigation
    Put all the AppKit Controller Navigation data in the stash
    If you forward to this action, you should end up with a stash value keyed by 'navigation'.
        eg. $c->forward('stash_navigation');
    The value of 'navigation' is an ArrayRef of HashRefs.
    The HashRefs contain 2 keys:
        text    = The text of the navigation item
        uri     = The uri if the action the navigation relates to.
=cut
sub stash_navigation :Private
{
    my ( $self, $c ) = @_;
    my @navigations;
    foreach my $apc ( @{ $c->appkit_controllers } )
    {
        foreach my $nav_name ( keys %{ $apc->navigation_actions } )
        {
            my $nav_action = $apc->navigation_actions->{$nav_name};

            # test we can access this action..
            next unless $c->can_access( $nav_action->reverse );

            # build an array of navigation information...
            push
            (
                @navigations,
                {
                    text    => $nav_name,
                    uri     => $c->uri_for( $nav_action ),
                }
            );
        }
    }
    $c->stash->{navigation} = \@navigations;
}

=head2 stash_portlets
    Put all the AppKit Controller Portlets data in the stash
    If you forward to this action, you should end up with a stash value keyed by 'portlets'.
        eg. $c->forward('stash_portlets');
    The value of 'portlets' is an ArrayRef of HashRefs.
    The HashRefs contain 2 keys:
        name    = The name of the portlet
        html    = The HTML content of the portlet
=cut
sub stash_portlets :Private
{   
    my ( $self, $c ) = @_;
    my @portlets;
    foreach my $apc ( @{ $c->appkit_controllers } )
    {   
        foreach my $portlet_name ( keys %{ $apc->portlet_actions } )
        {   
            my $portlet_action = $apc->portlet_actions->{$portlet_name};

            # forward to the portlet action..
            $c->forward( $portlet_action );

            # take things from the stash (that the action should have just filled out)
            push
            (
                @portlets,
                {
                    name    => $portlet_name,
                    html    => $c->stash->{portlet}->{html}
                }
            );
        }
    }
    $c->stash->{portlets} = \@portlets;
}

##
1;
