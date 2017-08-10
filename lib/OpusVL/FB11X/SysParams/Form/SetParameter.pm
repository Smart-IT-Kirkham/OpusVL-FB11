package OpusVL::FB11X::SysParams::Form::SetParameter;

use OpusVL::FB11::Plugin::FormHandler;

has 'param_label' => ( is => 'rw', default => sub { "Nothing defined" } );
has_field 'name'  => ( type => 'Display', label => 'Parameter' );
has_field 'value' => ( type => 'Text' );
has_field 'submitbutton' => (
    type    => 'Submit',
    widget  => 'ButtonTag',
    widget_wrapper => 'None',
    value   => '<i class="fa fa-check"></i> Submit',
    element_attr => { value => 'Save', class => ['btn', 'btn-success'] }
);

sub html_name {
    my ($self, $field) = @_;
    return "<h3>" . $field->value . "</h3>";
}

no HTML::FormHandler::Moose;
1;
__END__
