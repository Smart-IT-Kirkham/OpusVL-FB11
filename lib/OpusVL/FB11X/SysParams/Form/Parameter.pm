package OpusVL::FB11X::SysParams::Form::Parameter;

use strict;
use warnings;

our $VERSION = '0';

# ABSTRACT: A form to set the value of a parameter

use OpusVL::FB11::Plugin::FormHandler;

has_field name  => ( type => 'Display', label => 'Parameter' );
has_field label => ( type => 'Display', label => 'Label' );
has_field comment => ( type => 'Text' );
has_field value => ( type => 'Text' );
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

no HTML::FormHandler::Moose;

1;
