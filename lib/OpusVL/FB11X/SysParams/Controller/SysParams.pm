package OpusVL::FB11X::SysParams::Controller::SysParams;

use strict;
use Moose;
use namespace::autoclean;
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
    fb11_css           => ['/static/sysparams/sysparams.css']
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

    my $namespaces = $c->stash->{namespaces} = [ map { $_->namespace } OpusVL::FB11::Hive->hats('sysparams::consumer') ];
    my $params = $c->stash->{sysparams} = {
        map {
            $_ => [
                OpusVL::FB11::Hive
                ->service('sysparams::management')
                ->for_component($_)
                ->all_params_fulldata
            ]
        }
        @$namespaces
    };

    $c->stash->{widget_for_value} = sub {
        my $val = shift;
        if (my $r = ref $val) {
            return lc $r;
        }
    };
}

sub edit_param
    : Path('edit')
    : Args(1)
    : FB11Feature('System Parameters')
{
    my ($self, $c, $name) = @_;
    my $manager = OpusVL::FB11::Hive
        ->service('sysparams::management')
        ->for_all_components;

    my $meta = $manager->metadata_for($name)
        // $c->detach('/not_found');

    my $value = $manager->value_of($name);
    my $is_multi = !!ref $value;
    my $is_enum = $meta->{data_type}->{type} eq 'enum';

    # As with every other HTML form module, formhandler totally misses the point
    # about the difference between a schema and the HTML representation of that
    # schema. The choice between Text and Select should be done as the very LAST
    # thing, but HTML form modules force you to decide as the FIRST thing.
    #
    # This is therefore completely the wrong thing to do but it appears to be
    # the only way to do it. Note that I am also working around this module's
    # problems in the template as well, which is why it doesn't matter the order
    # in which these fields get created.
    my %field_list = (
        value => {
            type => 'Text',
            do_label => 0
        },
        'values.contains' => {
            do_label => 0,
            do_wrapper => 0,
            type => 'Text',
            element_attr => {
                class => 'js-repeatable',
                'data-repeatable-format' => '(values\.)(\d+)'
            }
        }
    );

    if ($is_enum) {
        for (qw/value values.contains/) {
            $field_list{$_}->{type} = 'Select';
            $field_list{$_}->{options} = $meta->{data_type}->{parameters};
        }
    }

    if ($c->req->param ('cancelbutton')) {
        $c->flash->{status_msg} = 'System parameter not changed';
        $c->res->redirect($c->uri_for($self->action_for('list_params')));
        $c->detach;
    }

    my $form = $self->edit_form(
        field_list => [ %field_list ]
    );
    $c->stash->{form} = $form;

    # We only send values or value, so the template can draw a repeatable or not
    # as necessary
    my $init_obj = {
        $is_multi ? (values => $value) : (value => $value),
        name => $name,
        %$meta
    };

    $form->process(
        params => $c->req->params,
        posted => $c->req->method eq 'POST',
        init_object => $init_obj,
    );

    # Another formhandler workaround. Woe betide you ever accidentally empty the
    # array if the controller doesn't do this
    if ($is_multi and not @$value) {
        $form->field('values')->add_extra(1)
    }

    if ($form->validated) {
        if ($is_multi) {
            $manager->set_value($name, $form->field('values')->value);
        }
        else {
            $manager->set_value($name, $form->field('value')->value);
        }
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
