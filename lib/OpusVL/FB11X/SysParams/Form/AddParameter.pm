package OpusVL::FB11X::SysParams::Form::AddParameter;

use OpusVL::FB11::Plugin::FormHandler;
with 'HTML::FormHandler::TraitFor::Model::DBIC';

has '+item_class' => ( default => 'SysInfo' );
has '+unique_messages' => (
   default => sub {
      { name => "Name must be unique" }
   }
);

has_field 'name' => (
    type    => 'Text',
    apply   => [
        {
            check => \&_correct_format,
            message => "Must be of format 'category.name'"
        }
    ],
    required => 1
);

has_field 'value' => ( type => 'Text' );
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
