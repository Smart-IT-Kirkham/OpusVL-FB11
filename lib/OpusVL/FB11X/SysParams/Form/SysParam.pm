package OpusVL::FB11X::SysParams::Form::SysParam;

use OpusVL::FB11::Plugin::FormHandler;
with 'HTML::FormHandler::TraitFor::Model::DBIC';

use JSON::MaybeXS qw/JSON/;
use List::MoreUtils qw/zip/;

has use_init_obj_over_item => (
    is => 'ro',
    default => 1,
);

has_field name  => ( 
    type => 'Text', 
    label => 'Parameter',
    element_class => 'field field-name',
);
has_field label => (
    type => 'Text',
    element_class => 'field field-label',
);
has_field data_type => (
    type => 'Select',
    widget => 'RadioGroup',
    wrapper_class => 'field field-data-type',
    default => 'text',
);
has_field value => ( 
    type => 'Text',
    element_class => 'field field-value',
    inflate_method => \&inflate_value,
    input_without_param => 0,
);
has_field comment => (
    type => 'Text',
    element_class => 'field field-comment',
);

sub options_data_type {
    my $self = shift;

    my $options = $self->item->viable_type_conversions;
    my $labels = +{
        &zip($self->item->column_info('data_type')->{extra}->{list},
             $self->item->column_info('data_type')->{extra}->{labels})
    };
    return map { $_, $labels->{$_} } @$options;
}

sub inflate_value {
    my ($field, $value) = @_;

    if ($field->form->field('data_type')->fif eq 'bool') {
        $value = $value ? \1 : \0;
    }

    return JSON->new->allow_nonref->encode($value);
}

sub validate_name {
    my ($self, $field) = @_;

    unless ($field->value =~ /\w\.\w/) {
        $field->add_error("Must be of format 'category.name'");
    }
}

1;
