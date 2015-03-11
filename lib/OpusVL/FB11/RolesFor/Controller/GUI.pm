package OpusVL::FB11::RolesFor::Controller::GUI;

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

        FB11Form
            Behaves like FormConfig option in FormFu Controller, except it loads form from the 
            ShareDir of namespace passed in 'fb11_myclass'
            
        SearchName
            Tells the GUI this action is a search action and what its name should be
    
=head1 METHODS

=cut

##################################################################################################################################
# use lines.
##################################################################################################################################
use strict;
use Moose::Role;

##################################################################################################################################
# moose calls.
##################################################################################################################################

has fb11                      => ( is => 'ro',    isa => 'Int',                       default => 1 );
has fb11_name                 => ( is => 'rw',    isa => 'Str',                       default => 'FB11' );
has fb11_myclass              => ( is => 'ro',    isa => 'Str',                       );
has fb11_shared_module        => ( is => 'rw',    isa => 'Str');
has navigation_items_merged     => ( is => 'rw',    isa => 'Bool', default => 0 );
has fb11_method_group_order   => ( is => 'rw',    isa => 'Int', default => 0);
has fb11_method_group         => ( is => 'rw',    isa => 'Str', default => '');
has fb11_order                => ( is => 'rw',    isa => 'Int', default => 0);

has _default_order              => ( is => 'rw',    isa => 'Int', default => 0);

=head2 home_action

    This should be the hash of action details that pertain the the 'home action' of a controller.
    If there is none defined for a controller, it should be undef.

=cut

has home_action             => ( is => 'rw',    isa => 'HashRef'        );

=head2 navigation_actions

    This should be an Array Ref of HashRef's pertaining the actions that make up the navigation

=cut

has navigation_actions      => ( is => 'rw',    isa => 'ArrayRef',  default => sub { [] } );

=head2 navigation_actions_grouped

    This should be an Array Ref of HashRef's pertaining the actions that make up the navigation
    grouped by fb11_method_group.

=cut

has navigation_actions_grouped      => ( is => 'rw',    isa => 'ArrayRef',  default => sub { [] } );

=head2 portlet_actions

    This should be an Array Ref of HashRef's pertaining the actions that are Widgets

=cut

has portlet_actions         => ( is => 'rw',    isa => 'ArrayRef',  default => sub { [] } );

=head2 search_actions

    This should be an Array Ref of HashRef's pertaining the actions that are Widgets

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
    if ( defined $args{attributes}{FB11Form} ) { push @{ $args{attributes}{ActionClass} }, "OpusVL::FB11::Action::FB11Form"; }

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
        $self->_default_order($self->_default_order+1);
        my $order;
        if(defined $args{attributes}{NavigationOrder})
        {
            $order = $args{attributes}{NavigationOrder}->[0] 
        }
        else
        {
            $order = $self->_default_order;
        }

        my $hide = {};
        if ($args{attributes}{Hide}) {
            my ($key, $value) = split(':', $args{attributes}{Hide}->[0]);
            if ($key && $value) {
                $hide = {
                    hidden => 1,
                    as     => $key,
                    with   => $value
                };
            }
        }

        push 
        ( 
            @$array,
            {
                value       => $args{attributes}{NavigationName}->[0],
                actionpath  => $args{reverse},
                actionname  => $args{name},
                title       => $args{attributes}{Description}->[0],
                controller  => $self,
                sort_index  => $order,
                hide_as     => $hide->{as}||0,
                hide_with   => $hide->{with}||0,
            }
        );

        $self->navigation_actions( $array );
    }
    
    if ( defined $args{attributes}{Widget} )
    {
        # This action has been identified as a Widget action...
        my $array = $self->portlet_actions;
        $array = [] unless defined $array;
        push 
        ( 
            @$array,
            {
                value       => $args{attributes}{Widget}->[0],
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
        $DB::single = 1;
    }
};

=head2 intranet_action_list

Returns a sorted list of actions for the menu filtered by what the user can access.

=cut
sub intranet_action_list
{
    my $self = shift;
    my $c = shift;

    my $actions = $self->navigation_actions;
    return $self->_sorted_filtered_actions($c, $actions);
}

sub _sorted_filtered_actions
{
    my $self = shift;
    my $c = shift;
    my $actions = shift;

    return [] if !$actions;
    my @actions = sort { $a->{sort_index} <=> $b->{sort_index} } 
        grep { $c->can_access($_->{controller}->action_for($_->{actionname})) } @$actions;
    return \@actions;
}

=head2 application_action_list

Returns a sorted list of actions for the menu filtered by what the user can access.

It returns a list of hashes containing two keys, group (the group name) and actions, a list of 
the actions for that group.

=cut
sub application_action_list
{
    # this list includes groups too.
    my $self = shift;
    my $c = shift;

    my $grouped_actions = $self->navigation_actions_grouped;
    return [] if !$grouped_actions;
    my @groups;
    for my $group (@$grouped_actions)
    {
        my $filtered = $self->_sorted_filtered_actions($c, $group->{actions});
        push @groups, { group => $group->{group}, actions => $filtered } if @$filtered;
    }
    return \@groups;
}


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
    
    return if !$dt;
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
    return if !$dt;
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
    return if !$dt;

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
    return if !$dt;

    return join '',
        sprintf('%02d', $dt->hour),
        ':',
        sprintf('%02d', $dt->minute);

}

=head2 add_breadcrumb

Adds the a breadcrumb on your breadcrumb trial.  Pass it the context object and the breadcumb info,

    $self->add_breadcrumb($c, { name => 'Title', url => $search_url });

=cut

sub add_breadcrumb
{
    my $self = shift;
    my $c = shift;
    my $args = shift;
    push @{$c->stash->{breadcrumbs}}, $args;
}

=head2 add_final_crumb

Adds the final breadcrumb on your trial.  Simply pass it the title of the breadcrumb.

    $self->add_final_crumb($c, 'Title');

=cut

sub add_final_crumb
{
    my $self = shift;
    my $c = shift;
    my $title = shift;
    push @{$c->stash->{breadcrumbs}}, { name => $title, url => $c->req->uri };
}

=head2 flag_callback_error

Flags an HTML::FormFu callback error.

Setup a callback constraint on your form,

  - type: Text
    name: project
    label: Project
    constraints:
      - type: Callback
        message: Project is invalid

Then within your controller you can do, 

    $self->flag_callback_error($c, 'project');

This will terminate the processing of the action too, by doing a $c->detach;

=cut

sub flag_callback_error
{
    my ($self, $c, $field_name, $message) = @_;
    return $self->flag_callback_error_ex($c, $field_name, { message => $message });
}

sub flag_callback_error_ex
{
    my ($self, $c, $field_name, $args) = @_;

    $args //= {};
    my $message = $args->{message};
    my $no_detach = $args->{no_detach};

    my $form = $c->stash->{form};
    my $constraint = $form->get_field($field_name)->get_constraint({ type => 'Callback' });
    $constraint->callback(sub { 0});
    $constraint->message($message) if $message;
    $form->process;
    $c->detach unless $no_detach;
}

sub has_forms {
    my (%forms) = @_;
    {
        no strict 'refs';
        for my $method (keys %forms) {
            my $form = $forms{$method};
            my $caller = scalar caller;
            # absolute module
            if (substr($form, 0, 1) eq '+') {
                $form =~ s/^\+//g;
            }
            else {
                my $base = $caller;
                $base =~ s/::Controller::(.+)//g;
                $form = "${base}::Form::${form}";
            }
            eval "use $form";
            if ($@) {
                die "Could not use form $form: $@\n";
            }
            *{"${caller}::${method}"} = sub { $form->new(name => $method) };
        }
    }
}

sub form {
    my ($self, $c, $form) = @_;
    my $base = scalar caller;
    $base =~ s/::Controller::(.+)//g;

    #if (not ref $c eq $base) {
    #    die "form() expects '${base}' object as second parameter. Received " . ref($c) . " instead\n";
    #}

    my $caller = scalar caller;
    # absolute module
    if (substr($form, 0, 1) eq '+') {
        $form =~ s/^\+//g;
    }
    else {
        $form = "${base}::Form::${form}";
    }
    eval "use $form";
    if ($@) {
        die "Could not use form $form: $@\n";
    }

    return $form->new(ctx => $c);
}

=head1 SEE ALSO

    L<CatalystX::AppBuilder>,
    L<OpusVL::FB11>,
    L<Catalyst>

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

##
1;
