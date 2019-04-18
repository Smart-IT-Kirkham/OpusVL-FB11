package OpusVL::FB11X::SysParams::Controller::SysParams;

use strict;
use Moose;
use namespace::autoclean;
use OpusVL::SysParams;
use Try::Tiny;
use HTML::Entities;


BEGIN { extends 'Catalyst::Controller'; }
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name          => 'Admin',
    fb11_icon          => 'cog',
    fb11_myclass       => 'OpusVL::FB11X::SysParams',
    fb11_shared_module => 'Admin',
    fb11_method_group  => 'System',
);

has_forms (
    edit_form => 'Parameter'
);

sub list_params
    : Path
    : NavigationName('Global Parameters')
    : FB11Feature('System Parameters')
{
    my $self = shift;
    my $c    = shift;

    my $params = $c->stash->{sysparams} = [
        OpusVL::FB11::Hive
            ->service('sysparams::management')
            ->for_all_components
            ->all_params_fulldata
    ];

    $c->stash->{widget_for_value} = sub {
        my $val = shift;
        if (my $r = ref $val) {
            return lc $r;
        }
    };
}

sub set_param
    : Path('set')
    : Args(1)
    : FB11Feature('System Parameters')
{
    my ($self, $c, $name) = @_;
    my $manager = OpusVL::FB11::Hive
        ->service('sysparams::management')
        ->for_all_components;

    # This is going to take some work so we'll do it later.
    $c->flash->{error_msg} = "Not yet implemented";
    $c->detach('/not_found');

    my $meta = $manager->metadata_for($name)
        // $c->detach('/not_found');

    my $value = $manager->value_of($name);

    my $label = $meta->{label};

    if ($c->req->param ('cancelbutton')) {
        $c->flash->{status_msg} = 'System parameter not changed';
        $c->res->redirect($c->uri_for($self->action_for('list_params')));
        $c->detach;
    }

    my $form = $self->edit_form;
    $c->stash->{form} = $form;

    $form->process(
        params => $c->req->params,
        posted => !!$c->req->method eq 'POST',
    );
    if ($form->validated) {
        $c->flash->{status_msg} = 'System Parameter Successfully Altered';
        $c->res->redirect($c->uri_for($self->action_for('list_params')));
        $c->detach;
    }
}

1;


=head1 NAME

OpusVL::FB11X::SysParams::Controller::SysInfo

=head1 DESCRIPTION

=head1 METHODS

=head2 auto

=head2 list_params

=head2 set_textarea_param

=head2 set_param

=head2 set_json_param

=head2 del_param

=head2 new_param

=head1 ATTRIBUTES


=head1 LICENSE AND COPYRIGHT

Copyright 2012 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
