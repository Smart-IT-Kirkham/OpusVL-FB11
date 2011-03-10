package OpusVL::AppKit::Plugin::AppKitControllerSorter;


use strict;
use warnings;

use Moose::Role;
use CatalystX::NavigationMenu;
use namespace::autoclean;

use vars qw($VERSION);
$VERSION = '1.000';

# this plugin takes the appkit_app_order config setting and sets it against the controllers.

after setup_finalize => sub 
{
    my ($self, @args) = @_;

    my %appkitconntrollers = map { my $controller = $self->controller($_); ref $controller => $controller } 
                            grep { $self->controller($_)->can('appkit') && $self->controller($_)->home_action} $self->controllers;
    my @list;
    my $setting = $self->config->{appkit_app_order};
    @list = @$setting if $setting;
    my $count = scalar @list;
    if($count && $count < scalar keys %appkitconntrollers)
    {
        $self->log->warn('Application order is not completely set.  Update your appkit_app_order config setting');
        $self->log->warn('Expecting these controllers to be specified ' . join ', ', keys %appkitconntrollers);
    }
    for(my $i = 0; $i < $count; $i++)
    {
        my $class = $list[$i];
        my $controller = $appkitconntrollers{$class};
        if($controller)
        {
            $controller->appkit_order($i);
        }
        else
        {
            $self->log->warn("appkit_app_order mentions class $class which doesn't appear to be loaded.");
        }
    }
    if(!$count)
    {
        # if there wasn't a config setting for order do the default alphabetical sort.
        my @default_sort = sort { $a->appkit_name cmp $b->appkit_name } values %appkitconntrollers;
        $count = scalar @default_sort;
        for(my $i = 0; $i < $count; $i++)
        {
            $default_sort[$i]->appkit_order($i);
        }
    }
};

1;

