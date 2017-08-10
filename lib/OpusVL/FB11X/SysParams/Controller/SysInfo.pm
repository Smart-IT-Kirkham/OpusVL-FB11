package OpusVL::FB11X::SysParams::Controller::SysInfo;

use strict;
use Moose;
use namespace::autoclean;
use OpusVL::SysParams;
use Try::Tiny;


BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; }
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name          => 'System Parameters',
    fb11_icon          => 'cog',
    fb11_myclass       => 'OpusVL::FB11X::SysParams',  
    fb11_shared_module => 'Configuration',
    fb11_method_group  => 'Configuration',
	path                 => 'adm/sysinfo',
);

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

	$c->stash->{urls} = {
		sys_info_list => sub { $c->uri_for ( $self->action_for ('list_params')      ) },
		sys_info_set  => sub { $c->uri_for ( $self->action_for ('set_param'), shift ) },
		sys_info_set_ta  => sub { $c->uri_for ( $self->action_for ('set_textarea_param'), shift ) },
		sys_info_set_json  => sub { $c->uri_for ( $self->action_for ('set_json_param'), shift ) },
		sys_info_del  => sub { $c->uri_for ( $self->action_for ('del_param'), shift ) },
		sys_info_new  => sub { $c->uri_for ( $self->action_for ('new_param') ) },
	};
}

# FIXME: do we really want this to be Navigation Home?  I kind of suspect
# we either want to give this app a less generic name or allow it to be merged
# with other modules, in which case this navigation home could be a pain.
sub list_params
	: Path
	: NavigationName('System Parameters')
    : FB11Feature('System Parameters')
{
	my $self = shift;
	my $c    = shift;
	
	$c->stash->{sys_info} = $c->model ('SysParams::SysInfo')->search_rs;
}

sub set_textarea_param
	: Path('set_ta')
	: Args(1)
    : FB11Feature('System Parameters')
{
    my ($self, $c, $param) = @_;
    $c->stash->{template} = "modules/sysinfo/set_param.tt";
    $self->set_param($c, $param, 1);
}

sub set_param
	: Path('set')
	: Args(1)
    : FB11Feature('System Parameters')
{
    my ($self, $c, $param, $textarea) = @_;
	my $value = $c->model ('SysParams::SysInfo')->get ($param);
	my $return_url = $c->stash->{urls}{sys_info_list}->();
	#my $form  = $self->form($c, 'SetParameter');

	if ($c->req->param ('cancelbutton')) {
		$c->flash->{status_msg} = 'System Parameter not Changed';
		$c->res->redirect ($return_url);
		$c->detach;
	}

    my $form = HTML::FormHandler->new(
        widget_wrapper => 'Bootstrap3',
        name => 'role_management_form',
        field_list => [
            name => {
                type => 'Display',
                html => "<h3>" . $param . "</h3>",
            },

            value => {
                type => $textarea ? "TextArea" : "Text",
                label => 'Value',
            },

            'submitbutton' => {
                type    => 'Submit',
                widget  => 'ButtonTag',
                widget_wrapper => 'None',
                value   => '<i class="fa fa-check"></i> Submit',
                element_attr => { value => 'Save', class => ['btn', 'btn-success'] }
            },
        ],
    );

    $c->stash->{form} = $form;
    $form->process(params => $c->req->params, init_object => { name => $param, value => $value });
	if ($form->validated) {
		$c->model ('SysParams::SysInfo')->set ($param => $form->field('value')->value);
		$c->flash->{status_msg} = 'System Parameter Successfully Altered';
		$c->res->redirect ($return_url);
		$c->detach;
	}
}

sub set_json_param
	: Path('set_json')
	: Args(1)
    : FB11Feature('System Parameters')
{
	my $self  = shift;
	my $c     = shift;
	my $param = shift;
	my $value = $c->stash->{sys_params}->get_json($param);
    my $form  = $self->form($c, 'SetParameter');
    $c->stash->{form} = $form;
	my $return_url = $c->stash->{urls}{sys_info_list}->();

	if ($c->req->param('cancelbutton')) {
		$c->flash->{status_msg} = 'System Parameter not Changed';
		$c->res->redirect ($return_url);
		$c->detach;
	}

    $form->process(
        params => $c->req->params,
        init_object => {
            name    => $param,
            value   => $value,
        }
    );

	if ($form->validated) {
        my $success = 0;
        try {
            $c->stash->{sys_params}->set_json($param => $form->field('value')->value);
            $c->flash->{status_msg} = 'System Parameter Successfully Altered';
            $success = 1;
        }
        catch {
            $c->log->debug(__PACKAGE__ . '->set_json_param exception: ' . $_);
            $form->field('value')->add_error("There was a problem updating the value. Is it valid JSON?");
        };
        if($success) {
            $c->res->redirect($return_url);
            $c->detach;
        }
	}
}

sub del_param
	: Path('del')
	: Args(1)
    : FB11Feature('System Parameters')
{
    my ($self, $c, $param) = @_;
	my $value = $c->model ('SysParams::SysInfo')->get ($param);

    $c->stash->{question} = "Are you sure you want to delete the parameter: ${param}";
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
    else {
        $c->stash->{param_value} = $value;
        $c->stash->{param_name}  = $param;
    }
}

sub new_param
	: Path('new')
	: Args(0)
    : FB11Feature('System Parameters')
{
	my $self  = shift;
	my $c     = shift;
	my $form  = $self->form($c, 'AddParameter');
    $form->process(
        schema => $c->model('SysParams::SysInfo')->result_source->schema,
        params => $c->req->params
    );
    $c->stash->{form} = $form;
	
	my $return_url = $c->stash->{urls}{sys_info_list}->();

	if ($c->req->param ('cancelbutton')) {
		$c->flash->{status_msg} = 'System Parameter Not Set';
		$c->res->redirect ($return_url);
		$c->detach;
	}

	if ($form->validated) {
		my $name  = $form->field('name')->value;
		my $value = $form->field('value')->value;
		$c->model ('SysParams::SysInfo')->set ($name => $value);
		$c->flash->{status_msg} = 'System Parameter Successfully Created';
		$c->res->redirect ($return_url);
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
