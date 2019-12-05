package OpusVL::FB11::Form::Confirm;

our $VERSION = '1';

use OpusVL::FB11::Plugin::FormHandler;

has_field 'submitok'   => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => '<i class="fa fa-check"></i> OK',
    element_attr => {
        value => 'submitok',
        class => ['btn', 'btn-primary']
    }
);

has_field 'cancel'   => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => '<i class="fa fa-remove"></i> Cancel',
    element_attr => { 
        value => 'cancel',
        class => ['btn', 'btn-danger']
    }
);

no HTML::FormHandler::Moose;
1;
__END__
