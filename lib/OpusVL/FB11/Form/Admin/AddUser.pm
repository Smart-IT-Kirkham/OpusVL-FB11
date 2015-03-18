package OpusVL::FB11::Form::Admin::AddUser;

use OpusVL::FB11::Plugin::FormHandler;
with 'OpusVL::FB11::Form::Role::Users';

has_field 'username' => (
    type        => 'Text',
    label       => 'Username',
    required    => 1,
);

has_field 'password' => (
    type        => 'Password',
    label       => 'Password',
    required    => 1,
);

has_field 'name' => (
    type        => 'Text',
    label       => 'Name',
    required    => 1,
);

has_field 'email' => (
    type        => 'Email',
    label       => 'Email',
    required    => 1,
);

has_field 'tel' => (
    type        => 'Text',
    label       => 'Telephone',
    required    => 1,
);

has_field 'status' => (
    type        => 'Select',
    widget      => 'RadioGroup',
    options     => [
        { value => 'enabled', label => 'Enabled', attributes => { checked => 'checked' } },
        { value => 'disabled', label => 'Disabled' },
        { value => 'deleted', label => 'Deleted' },
    ],
);

has_field 'submit'   => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => '<i class="fa fa-check"></i> Submit',
    element_attr => { value => 'submitok', class => ['btn', 'btn-primary'] }
);

before 'validate_form' => sub {
    my ($self) = @_;
    if ($self->update_only) {
        my @fields = qw(username password name email tel status);
        $self->field($_)->required(0)
            for @fields;
    }
};

no HTML::FormHandler::Moose;
1;
__END__