package OpusVL::FB11::RolesFor::Plugin;

=head1 NAME

OpusVL::FB11::RolesFor::Plugin

=head1 DESCRIPTION

This role helps integrate your module into a catalyst app by adding to the paths setup so that the
auto directory contents are included in your app.  This includes, TT templates, HTML::FormHandler forms,
static content and Excel::Template::Plus templates.

=head1 SYNOPSIS

    with 'OpusVL::FB11::RolesFor::Plugin';


    after 'setup_components' => sub {
        my $class = shift;

        $class->add_paths(__PACKAGE__);

=head1 METHODS

=head2 add_paths

This sets up the paths for the TT templates and the L<Excel::Template::Plus> view.  Both views
are setup to point to the same directory, named C<templates>.  It also sets up the static content path
to point to the static directory.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

use Moose::Role;
use Carp;
use File::ShareDir qw/module_dir/;
use Try::Tiny;
use Data::Munge qw/elem/;

sub add_paths
{
    my $self = shift;
    my $module = shift;

    # FIXME: should I do a rel2abs here?
    my $module_dir = try
    {
        module_dir($module);
    };
    if($module_dir)
    {
        $self->_add_static_path($module_dir);
        $self->_add_template_path($module_dir);
    }
}

sub _add_template_path
{
    my $self = shift;
    my $module_dir = shift;

    my $tt_view       = $self->config->{default_view} || 'TT';
    my $template_path = $module_dir . '/root/templates';

    if($self->view('Excel'))
    {
        unless (elem $template_path => $self->view('Excel')->{etp_config}->{INCLUDE_PATH}) {
            push @{$self->view('Excel')->{etp_config}->{INCLUDE_PATH}}, $template_path;
        }
        $self->view('Excel')->{etp_config}->{AUTO_FILTER} = 'html';
        $self->view('Excel')->{etp_engine} = 'TTAutoFilter';
        unless (elem $template_path => $self->view($tt_view)->include_path) {
            push @{$self->view($tt_view)->include_path}, $template_path;
        }
    }
    else
    {
        my $excel_config = $self->config->{'View::Excel'};
        unless (elem $template_path => $excel_config->{etp_config}->{INCLUDE_PATH}) {
            push @{$excel_config->{etp_config}->{INCLUDE_PATH}}, $template_path;
        }
        $excel_config->{etp_config}->{AUTO_FILTER} = 'html';
        $excel_config->{etp_engine} = 'TTAutoFilter';
        my $inc_path = $self->config->{'View::FB11TT'}->{'INCLUDE_PATH'};
        push(@$inc_path, $template_path );
    }

}

sub _add_static_path
{
    my $self = shift;
    my $module_dir = shift;

    # .. add static dir into the config for Static::Simple..
    my $static_dirs = $self->config->{'Plugin::Static::Simple'}->{include_path};
    unshift(@$static_dirs, File::Spec->rel2abs($module_dir . '/root' ));
    $self->config->{'Plugin::Static::Simple'}->{include_path} = $static_dirs;
}

1;
