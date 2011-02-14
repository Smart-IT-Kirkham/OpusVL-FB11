package OpusVL::AppKit::RolesFor::Controller::GUI;

=head1 NAME

    OpusVL::AppKit::RolesFor::Controller::GUI - Role for Controllers wanting to interact with AppKit

=head1 SYNOPSIS

    package MyApp::Controller::SomeFunkyThing;
    use Moose;
    BEGIN{ extends 'Catalyst::Controller' };
    with 'OpusVL::AppKit::RolesFor::Controller::GUI';

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

    If you use this Moose::Role with a controller it can be intergrated into the OpusVL::AppKit.

    You can just do: 
        use Moose;
        with 'OpusVL::AppKit::RolesFor::Controller::GUI';

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
use strict;
use Moose::Role;

##################################################################################################################################
# moose calls.
##################################################################################################################################

has appkit                  => ( is => 'ro',    isa => 'Int',                       default => 1 );
has appkit_name             => ( is => 'ro',    isa => 'Str',                       default => 'AppKit' );
has appkit_myclass          => ( is => 'ro',    isa => 'Str',                       );
has appkit_shared_module => ( is => 'ro', isa => 'Str');
has navigation_items_merged => ( is => 'rw', isa => 'Bool', default => 0 );

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

    # add any ActionClass's to this action.. so when it is called, some extra code is excuted....
    if ( defined $args{attributes}{AppKitForm} ) { push @{ $args{attributes}{ActionClass} }, "OpusVL::AppKit::Action::AppKitForm"; }

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
                controller  => $self,
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

=head2 date_long

Provides a standard L<DateTime> formatting function that is also mirrored (and called) from TT using
the date_long() function.

Monday, 10 May 2010

=cut
sub date_long 
{
    my ($self, $dt) = @_;
    
    return join '',
        $dt->day_name,
        ', ',
        sprintf("%02d ",$dt->day),
        $dt->month_name,
        ' ',
        $dt->year;
}

=head2 date_short

Provides a short date format function for DD-MM-YYYY display.

=cut
sub date_short
{
    my ($self, $dt) = @_;
    return join '',
        sprintf("%02d", $dt->day),
        '-',
        $dt->month_abbr,
        '-',
        $dt->year;
}

=head2 time_long

Provides a long time format function, HH:MM:SS

=cut
sub time_long
{
    my ($self, $dt) = @_;

    return join '',
        sprintf('%02d', $dt->hour),
        ':',
        sprintf('%02d', $dt->minute),
        ':',
        sprintf('%02d', $dt->second);

}

=head2 time_short

Provides a short time format function, HH:MM

=cut
sub time_short
{
    my ($self, $dt) = @_;

    return join '',
        sprintf('%02d', $dt->hour),
        ':',
        sprintf('%02d', $dt->minute);

}

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

##
1;
