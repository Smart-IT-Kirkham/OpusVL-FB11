package OpusVL::AppKit::RolesFor::Plugin;

=head1 NAME

OpusVL::AppKit::View::Excel

=head1 DESCRIPTION

This role helps integrate your module into a catalyst app by adding to the paths setup so that the
auto directory contents are included in your app.  This includes, TT templates, HTML::FormFu forms,
static content and Excel::Template::Plus templates.

=head1 SYNOPSIS

    with 'OpusVL::AppKit::RolesFor::Plugin';


    after 'setup_components' => sub {
        my $class = shift;

        $class->add_paths(__PACKAGE__);

=head1 METHODS

=head2 add_paths

This calls the other functions to hook up all the paths you need for your module.  This means you only need the
one call from your module.  The others are simply exposed in case you need to do anything funky.

=head2 add_static_path

Sets up the static path for the module to be picked up.  This is called by the add_paths method.
=head2 add_form_path

This sets up the HTML::FormFu include directory so that it will pick up your forms.  The AppKitForm attribute
also has some logic to pull forms from the current module but that doesn't allow you to do includes on other forms,
either within your own module, or across modules.  This is called by the add_paths method.

=head2 add_template_path

This sets up the paths for the TT templates and the L<Excel::Template::Plus> view.  Both views
are setup to point to the same directory, named C<templates>.

This is called by the add_paths method.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

use Moose::Role;
use File::ShareDir qw/module_dir/;

sub add_form_path
{
    my $self = shift;
    my $module_dir = shift;

    $self->config->{'Controller::HTML::FormFu'} = { constructor => { config_file_path => [] }} if !$self->config->{'Controller::HTML::FormFu'};
    $self->config->{'Controller::HTML::FormFu'}->{constructor} = { config_file_path => [] } if !$self->config->{'Controller::HTML::FormFu'}->{constructor};
    $self->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path} = [] if !$self->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path};
    push @{$self->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path}}, 
            $module_dir .  '/root/forms';
}

sub add_paths
{
    my $self = shift;
    my $module = shift;

    # FIXME: should I do a rel2abs here?
    my $module_dir = module_dir($module);
    $self->add_form_path($module_dir);
    $self->add_static_path($module_dir);
    $self->add_template_path($module_dir);
}

sub add_template_path
{
    my $self = shift;
    my $module_dir = shift;

    my $tt_view       = $self->config->{default_view} || 'TT';
    my $template_path = $module_dir . '/root/templates';

    unless ($self->view('Excel')->{etp_config}->{INCLUDE_PATH} ~~ $template_path) {
        push @{$self->view('Excel')->{etp_config}->{INCLUDE_PATH}}, $template_path;
    }

    unless ($self->view($tt_view)->include_path ~~ $template_path) {
        push @{$self->view($tt_view)->include_path}, $template_path;
    }
}

sub add_static_path
{
    my $self = shift;
    my $module_dir = shift;

    # .. add static dir into the config for Static::Simple..
    my $static_dirs = $self->config->{static}->{include_path};
    unshift(@$static_dirs, File::Spec->rel2abs($module_dir . '/root' ));
    $self->config->{static}->{include_path} = $static_dirs;
}

1;
