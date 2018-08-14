package OpusVL::FB11::Form::Admin::Users::Edit;

use OpusVL::FB11::Plugin::FormHandler;

has_field 'username' => (
    type        => 'Text',
    label       => 'Username',
    required    => 1,
    # Stops chrome trying to populate it like a login form
    element_attr => {
        autocomplete => 'new-username',
    }
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
);

has_field 'status' => (
    type        => 'Select',
    widget      => 'RadioGroup',
    options     => [
        { value => 'enabled', label => 'Enabled', attributes => { checked => 'checked' } },
        { value => 'disabled', label => 'Disabled' },
    ],
);

has_field 'submit-it'   => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => '<i class="fa fa-check"></i> Submit',
    element_attr => { value => 'submitok', class => ['btn', 'btn-primary'] }
);

no HTML::FormHandler::Moose;
1;
__END__
