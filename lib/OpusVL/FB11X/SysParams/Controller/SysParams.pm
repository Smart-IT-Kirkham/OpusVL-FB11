package OpusVL::FB11X::SysParams::Controller::SysParams;

use strict;
use Moose;
use namespace::autoclean;
use OpusVL::SysParams;
use Try::Tiny;
use HTML::Entities;
use OpusVL::FB11X::SysParams::Form::SysParam;


BEGIN { extends 'Catalyst::Controller'; }
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name          => 'Admin',
    fb11_icon          => 'cog',
    fb11_myclass       => 'OpusVL::FB11X::SysParams',
    fb11_shared_module => 'Admin',
    fb11_method_group  => 'Configuration',
);

sub param_edit_form {
    OpusVL::FB11X::SysParams::Form::SysParam->new(
        item => $_[1],
        name => 'param_edit_form',
        field_list => [
            save => {
                type => 'Submit',
                value => 'Save',
            }
        ]
    )
}

sub auto 
    : Action
    : FB11Feature('System Parameters')
{
	my $self = shift;
	my $c    = shift;

	$c->stash->{section}      = 'System Parameters';
    push @{$c->stash->{page_options}}, {
        title => 'System Parameters',
        url   => $c->uri_for ($self->action_for ('list_params'))
    };
    my $schema = $c->model('SysParams')->schema;
    $c->stash->{sys_params} = OpusVL::SysParams->new({ schema => $schema });

    push @{$c->stash->{header}->{js}}, '/static/modules/sysinfo/sysinfo.js';
    push @{$c->stash->{header}->{css}}, '/static/modules/sysinfo/sysinfo.css';

	$c->stash->{urls} = {
		sys_info_list => sub { $c->uri_for ( $self->action_for ('list_params')      ) },
		sys_info_set  => sub { $c->uri_for ( $self->action_for ('set_param'), shift ) },
		sys_info_set_ta  => sub { $c->uri_for ( $self->action_for ('set_textarea_param'), shift ) },
		sys_info_set_json  => sub { $c->uri_for ( $self->action_for ('set_json_param'), shift ) },
		sys_info_del  => sub { $c->uri_for ( $self->action_for ('del_param'), shift ) },
		sys_info_new  => sub { $c->uri_for ( $self->action_for ('new_param') ) },
	};
}

sub list_params
	: Path
	: NavigationName('System Parameters')
    : FB11Feature('System Parameters')
{
	my $self = shift;
	my $c    = shift;
	
	$c->stash->{sys_info} = $c->model ('SysParams::SysInfo')->ordered->search_rs;
}

sub set_param
	: Path('set')
	: Args(1)
    : FB11Feature('System Parameters')
{
    my ($self, $c, $name, $textarea) = @_;
    $self->add_final_crumb($c, 'Edit');
	my $param = $c->model ('SysParams::SysInfo')->find({name => $name});
    $c->detach('/not_found') unless $param;

    my $value = $param->value;
    my $label = $param->label // $param->name;
	my $return_url = $c->stash->{urls}{sys_info_list}->();

	if ($c->req->param ('cancelbutton')) {
		$c->flash->{status_msg} = 'System parameter not changed';
		$c->res->redirect ($return_url);
		$c->detach;
	}

    my $form = $self->param_edit_form($param);
    $c->stash->{form} = $form;
    $c->stash->{param} = $param;

	if ($form->process( params => $c->req->params )) {
        $c->flash->{status_msg} = 'System Parameter Successfully Altered';
		$c->res->redirect($return_url);
		$c->detach;
	}
}

sub del_param
	: Path('del')
	: Args(1)
    : FB11Feature('System Parameters')
{
    my ($self, $c, $param) = @_;
	my $p = $c->model ('SysParams::SysInfo')->find({name => $param});
    $c->detach('/not_found') unless $p;
	my $value = $p->value;

    my $param_name  = $p->label // $p->name;
    $c->stash->{question} = "Are you sure you want to delete the parameter: ${param_name}";
    $c->stash->{template} = 'fb11/admin/confirm.tt';
    $c->stash->{form} = $self->form($c, '+OpusVL::FB11::Form::Confirm');
    my $form = $c->stash->{form};
    $form->process($c->req->params);
	my $return_url = $c->stash->{urls}{sys_info_list}->();

	if ($form->validated) {
        if ($c->req->params->{submitok}) {
		    $c->model('SysParams::SysInfo')->del ($param);
		    $c->flash->{status_msg} = 'System Parameter Successfully Deleted';
		    $c->res->redirect ($return_url);
		    $c->detach;
        }
        else {
            $c->flash->{status_msg} = 'System Parameter Not Deleted';
            $c->res->redirect ($return_url);
            $c->detach;
        }
	}
}

sub new_param
	: Path('new')
	: Args(0)
    : FB11Feature('System Parameters')
{
	my $self  = shift;
	my $c     = shift;

	my $return_url = $c->stash->{urls}{sys_info_list}->();
    my $param = $c->model('SysParams::SysInfo')->new_result({});

    my $form = $self->param_edit_form($param);
    $c->stash->{form} = $form;
    $c->stash->{param} = $param;

    my $ok = try {
        $form->process( 
            params => $c->req->params,
            init_object => { data_type => 'text' }
        )
    }
    catch {
        if (/UNIQUE/) {
            $form->field('name')->add_error("Parameter already exists");
        }
        else {
            die $_
        }
        0;
    };

    if ($ok) {
		$c->flash->{status_msg} = 'System Parameter Successfully Created';
		$c->res->redirect ($return_url);
		$c->detach;
	}

    $c->stash->{template} = 'modules/sysinfo/set_param.tt';
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
