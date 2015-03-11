package OpusVL::FB11::Form::Admin::Users;

use OpusVL::FB11::Plugin::FormHandler;

has_field 'user_roles' => (
	type 	=> 'Multiple',
	widget  => 'HorizCheckboxGroup',
	label   => 'Belongs to roles',
	options => [{value => '1', label => 'Test'}],
);

has_field 'submit_roles' => (
	type	=> 'Submit',
	widget  => 'ButtonTag',
	widget_wrapper => 'None',
	value 	=> '<i class="fa fa-check"></i> Submit',
	element_attr => { value => 'submit_roles', class => ['btn', 'btn-success'] }
);

no HTML::FormHandler::Moose;
1;
__END__