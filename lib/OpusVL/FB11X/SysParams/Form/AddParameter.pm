package OpusVL::FB11X::SysParams::Form::AddParameter;

use OpusVL::FB11::Plugin::FormHandler;
with 'HTML::FormHandler::TraitFor::Model::DBIC';

has '+item_class' => ( default => 'SysInfo' );
has_field 'name' => (
    type    => 'Text',
    unique => 1,
    unique_message => "This parameter already exists.",
    apply   => [
        {
            check => \&_correct_format,
            message => "Must be of format 'category.name'"
        }
    ],
    required => 1
);

has_field 'label' => (
    type    => 'Text',
    unique => 1,
    unique_message => "This parameter already exists.",
    required => 1
);

has_field 'value' => ( type => 'Text' );
has_field 'data_type' => ( 
    type => 'Select', 
    options => [
        { value => 'text', label => 'Text' },
        { value => 'textarea', label => 'Multi-line text' },
        { value => 'json', label => 'JSON' },
        { value => 'array', label => 'Array' },
        { value => 'bool', label => 'Boolean' },
    ],
);
has_field 'submitbutton' => (
    type    => 'Submit',
    widget  => 'ButtonTag',
    widget_wrapper => 'None',
    value   => '<i class="fa fa-check"></i> Submit',
    element_attr => { value => 'Save', class => ['btn', 'btn-success'] }
);

sub _correct_format {
    my ($value, $field) = @_;
    $value =~ s/^\s+//g;
    $value =~ s/\s+$//g;
    return $value =~ /^[0-9a-zA-Z_]+\.[0-9a-zA-Z\.-_\-]+$/;
}
 
no HTML::FormHandler::Moose;
1;
__END__

=head1 NAME

OpusVL::FB11X::SysParams::Form::AddParameter

=head1 DESCRIPTION

=head1 METHODS

=head1 ATTRIBUTES

=head2 name

=head2 label

=head2 value

=head2 data_type

=head2 submitbutton


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
