package OpusVL::FB11::Form::Access::RoleManagement;

our $VERSION = '1';

use OpusVL::FB11::Plugin::FormHandler;

has_field 'can_change_any_role'   => ( type => 'Boolean', label => 'Can change any role' );
#has_field 'roles_allowed_roles'   => ( type => 'CheckboxGroup', label => 'Roles allowed to modify/apply' );

no HTML::FormHandler::Moose;
1;
__END__
