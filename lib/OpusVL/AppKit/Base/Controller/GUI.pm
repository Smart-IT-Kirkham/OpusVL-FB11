package OpusVL::AppKit::Base::Controller::GUI;

=head1 NAME

    OpusVL::AppKit::Base::Controller::GUI - Base Controller for those wanting to interact with AppKit

=head1 SYNOPSIS

    package MyApp::Controller::SomeFunkyThing;
    use Moose
    BEGIN{ extends 'OpusVL::AppKit::Base::Controller::GUI' };

    __PACKAGE__->config( appkit_name        => 'My Funky App' );
    __PACKAGE__->config( appkit_icon        => 'static/funkster/me.gif' );
    __PACKAGE__->config( appkit_myclass     => 'MyApp' );
    
    sub index
        :Path
        :Args(0)
        :NavigationHome
        :NavigationName("Funky Home")
        :PortletName("Funky Portlet")
        :AppKitForm
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

        AppKitForm
            Behaves like FormConfig option in FormFu Controller, except it loads form from the 
            ShareDir of namespace passed in 'appkit_myclass'
            
        SearchName
            Tells the GUI this action is a search action and what its name should be
    

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

BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; }

has appkit                  => ( is => 'ro',    isa => 'Int',                       default => 1 );
has appkit_name             => ( is => 'ro',    isa => 'Str',                       default => 'AppKit' );
has appkit_myclass          => ( is => 'ro',    isa => 'Str',                       );

=head2 home_action
    This should be the hash of action details that pertain the the 'home action' of a controller.
    If there is none defined for a controller, it should be undef.
=cut

has home_action             => ( is => 'rw',    isa => 'HashRef'        );

=head2 navigation_actions
    This should be an Array Ref of HashRef's pertaining the actions that make up the navigation
=cut

has navigation_actions      => ( is => 'rw',    isa => 'ArrayRef',  default => sub { [] } );

=head2 portlet_actions
    This should be an Array Ref of HashRef's pertaining the actions that are Portlet's
=cut

has portlet_actions         => ( is => 'rw',    isa => 'ArrayRef',  default => sub { [] } );

=head2 search_actions
    This should be an Array Ref of HashRef's pertaining the actions that are Portlet's
=cut

has search_actions         => ( is => 'rw',    isa => 'ArrayRef',  default => sub { [] } );

=head2 create_action
    Hook into the creation of the actions.
    Here we read the action attributes and act accordingly.
=cut

before create_action  => sub 
{ 
    my $self = shift;
    my %args = @_;

    if ( defined $args{attributes}{AppKitForm} )
    {
        # add an ActionClass to this action.. so when it is called, some extra code is excuted....
        push @{ $args{attributes}{ActionClass} }, "OpusVL::AppKit::Action::AppKitForm";
    }

    if ( defined $args{attributes}{NavigationHome} )
    {
        # This action has been identified as a Home action...
        $self->home_action
        ( 
            {
                actionpath  => $args{reverse},
                actionname  => $args{name},
            }
        );
    }

    if ( defined $args{attributes}{NavigationName} )
    {
        # This action has been identified as a Navigation item..
        my $array = $self->navigation_actions;
        $array = [] unless defined $array;
        push 
        ( 
            @$array,
            {
                value       => $args{attributes}{NavigationName}->[0],
                actionpath  => $args{reverse},
                actionname  => $args{name},
            }
        );
        $self->navigation_actions( $array );
    }

    if ( defined $args{attributes}{PortletName} )
    {
        # This action has been identified as a Portlet action...
        my $array = $self->portlet_actions;
        $array = [] unless defined $array;
        push 
        ( 
            @$array,
            {
                value       => $args{attributes}{PortletName}->[0],
                actionpath  => $args{reverse},
                actionname  => $args{name},
            }
        );
        $self->portlet_actions ( $array );
    }

    if ( defined $args{attributes}{SearchName} )
    {
        # This action has been identified as a Search action...
        my $array = $self->search_actions;
        $array = [] unless defined $array;
        push 
        ( 
            @$array,
            {
                value       => $args{attributes}{SearchName}->[0],
                actionpath  => $args{reverse},
                actionname  => $args{name},
            }
        );
        $self->search_actions ( $array );
    }
};

##################################################################################################################################
# controller actions.
##################################################################################################################################

sub date_long {
    my ($self, $dt) = @_;
    
    return join '',
        $dt->day_name,
        ', ',
        sprintf("%02d ",$dt->day),
        $dt->month_name,
        ' ',
        $dt->year;
}

##
1;
