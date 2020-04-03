package OpusVL::FB11::Plugin::FB11ControllerSorter;


use strict;
use warnings;
no warnings 'experimental::signatures';;

use Moose::Role;
use namespace::autoclean;

our $VERSION = '2';

# this plugin takes the fb11_app_order config setting and sets it against the controllers.

after setup_finalize => sub 
{
    my ($self, @args) = @_;

    my %fb11conntrollers = map { my $controller = $self->controller($_); ref $controller => $controller } 
                            grep { $self->controller($_)->can('fb11') && $self->controller($_)->home_action} $self->controllers;
    my @list;
    my $setting = $self->config->{fb11_app_order};
    @list = @$setting if $setting;
    my $count = scalar @list;
    if($count && $count < scalar keys %fb11conntrollers)
    {
        $self->log->warn('Application order is not completely set.  Update your fb11_app_order config setting');
        $self->log->warn('Expecting these controllers to be specified ' . join ', ', keys %fb11conntrollers);
    }
    for(my $i = 0; $i < $count; $i++)
    {
        my $class = $list[$i];
        my $controller = $fb11conntrollers{$class};
        if($controller)
        {
            $controller->fb11_order($i);
        }
        else
        {
            $self->log->warn("fb11_app_order mentions class $class which doesn't appear to be loaded.");
        }
    }
    if(!$count)
    {
        # if there wasn't a config setting for order do the default alphabetical sort.
        my @default_sort = sort { $a->fb11_name cmp $b->fb11_name } values %fb11conntrollers;
        $count = scalar @default_sort;
        for(my $i = 0; $i < $count; $i++)
        {
            $default_sort[$i]->fb11_order($i);
        }
    }
    my @all_controllers = map { $self->controller($_) } grep { $self->controller($_)->can('fb11') } $self->controllers;
    for my $controller (@all_controllers)
    {
        $self->merge_controller_actions($controller, \@all_controllers);
    }
};

=head2 merge_controller_actions
    Looks at other controllers in the app to see if any of the navigation actions
    need to be merged up together.  This allows us to have multiple controllers
    that are all part of the same module.

    This is called by the template to ensure the parts are merged up before we 
    go on.
=cut

sub merge_controller_actions
{
    my $self = shift;
    my $controller = shift;
    my $fb11_controllers = shift;

    return [] if !$controller->does('OpusVL::FB11::RolesFor::Controller::UI'); 
    my @navItems = @{$controller->navigation_actions};
    @navItems = () if(!@navItems);
    my @second = @navItems;
    my $group_process = { 
                $controller->fb11_method_group => { 
                    group => $controller->fb11_method_group, 
                    order => $controller->fb11_method_group_order,
                    actions => \@second } 
                };
    my @grouped;
    @grouped = ( $group_process->{$controller->fb11_method_group} );
    if($controller->fb11_shared_module && !$controller->navigation_items_merged)
    {
        my $controllers = $fb11_controllers;
        for my $c (@$controllers)
        {
            if($c != $controller && $c->does('OpusVL::FB11::RolesFor::Controller::UI'))
            {
                if($c->fb11_shared_module && $c->fb11_shared_module eq $controller->fb11_shared_module)
                {
                    if($c->navigation_items_merged)
                    {
                        # we've alraedy done the merge when we did this controller
                        # so just short cut the process.
                        # and use it's result.
                        @navItems = @{$c->navigation_actions};
                        @grouped = @{$c->navigation_actions_grouped};
                        last;
                    }
                    push @navItems, @{$c->navigation_actions};
                    my $group = $group_process->{$c->fb11_method_group};
                    if($group)
                    {
                        push @{$group->{actions}}, @{$c->navigation_actions} if $c->navigation_actions; 
                    }
                    else
                    {
                        my @copy = @{$c->navigation_actions};
                        $group_process->{ $c->fb11_method_group } = { 
                            group => $c->fb11_method_group, 
                            order => $c->fb11_method_group_order,
                            actions => \@copy,
                        } if($c->navigation_actions);
                    }
                }
            }
            # FIXME: figure out what this does because I've forgoten now.
            # sort the group
            @grouped = map { $group_process->{$_} } sort { $group_process->{$a}->{order} <=> $group_process->{$b}->{order} } keys %$group_process;
                
        }
        # sort the items so that they appear
        # in a consistent order regardless of controller.
        my @sorted = sort { $a->{actionpath} cmp $b->{actionpath} } @navItems;
        $controller->navigation_actions( \@sorted );
        $controller->navigation_actions_grouped( \@grouped );
        $controller->navigation_items_merged(1);
    }
}

1;

