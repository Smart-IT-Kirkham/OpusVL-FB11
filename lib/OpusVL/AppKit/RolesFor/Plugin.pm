package OpusVL::AppKit::RolesFor::Plugin;

use Moose::Role;
use File::ShareDir qw/module_dir/;

sub add_form_path
{
    my $self = shift;
    my $module = shift;

    $self->config->{'Controller::HTML::FormFu'} = { constructor => { config_file_path => [] }} if !$self->config->{'Controller::HTML::FormFu'};
    $self->config->{'Controller::HTML::FormFu'}->{constructor} = { config_file_path => [] } if !$self->config->{'Controller::HTML::FormFu'}->{constructor};
    $self->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path} = [] if !$self->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path};
    push @{$self->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path}}, 
            module_dir($module) .  '/root/forms';
}

1;
