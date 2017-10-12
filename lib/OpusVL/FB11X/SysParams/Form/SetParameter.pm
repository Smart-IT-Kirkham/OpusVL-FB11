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

=head1 NAME

OpusVL::FB11X::SysParams::Form::SetParameter

=head1 DESCRIPTION

=head1 METHODS

=head2 html_name

=head1 ATTRIBUTES

=head2 param_label

=head2 name

=head2 value

=head2 submitbutton


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
