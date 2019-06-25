package OpusVL::FB11X::SysParams::Form::Parameter;

use strict;
use warnings;

our $VERSION = '0';

# ABSTRACT: A form to set the value of a parameter

use OpusVL::FB11::Plugin::FormHandler;

has_field name  => ( type => 'Display', label => 'Parameter' );
has_field label => ( type => 'Display', label => 'Label' );
has_field comment => ( type => 'Display', label => 'Comment' );

# I couldn't see a tidy way of creating a field that could be a repeatable or a
# single field depending on whether I wanted it to be an array or not. So I
# created two fields, and the controller picks.
has_field value => ( type => 'Text', do_label => 0 );

# "contains" is a special name for repeatable sub-fields; see
# HTML::FormHandler::Manual::Fields
has_field values => (
    type => 'Repeatable',
    do_wrapper => 0,
);
has_field 'values.contains' => (
    do_label => 0,
    do_wrapper => 0,
    type => 'Text',
    element_attr => {
        class => 'js-repeatable',
        'data-repeatable-format' => '(values\.)(\d+)'
    }
);

has_field submitbutton => (
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

sub html_label {
    my ($self, $field) = @_;
    return "<h4>" . $field->value . "</h4>";
}

sub html_comment {
    my ($self, $field) = @_;
    return '' unless $field->value;
    return "<p>" . $field->value . "</p>";
}

sub render_list {
    my $self = shift;

    my @render = qw/name label comment/;

    if ($self->field('values')->value) {
        push @render, 'values';
    }
    else {
        push @render, 'value'
    }

    push @render, 'submitbutton';

    return \@render;
}

no HTML::FormHandler::Moose;

1;
