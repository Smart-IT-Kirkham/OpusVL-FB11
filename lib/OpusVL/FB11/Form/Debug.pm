package OpusVL::FB11::Form::Debug;

# ABSTRACT: A form for the debug page

our $VERSION = '1';

use OpusVL::FB11::Plugin::FormHandler;

has '+http_method' => (
    is => 'ro',
    default => 'get'
);

has_field module => (
    type => 'Text',
    label => "Module name",
    required => 1,
);

has_field submit => (  
    type => 'Submit',
    value => "Show me",
);

no HTML::FormHandler::Moose;

1;
