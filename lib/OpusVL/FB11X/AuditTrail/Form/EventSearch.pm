package OpusVL::FB11X::AuditTrail::Form::EventSearch;

use OpusVL::FB11::Plugin::FormHandler;

use warnings;
use strict;

has '+http_method' => (default => 'get');

# You will need to populate this in the controller after instantiating
has_field type_id => (
    type => 'Select',
    label => 'Event Type',
    multiple => 1,
    empty_select => 'All Events',
);

has_field username => (
    type => 'Text',
);

has_field ip_addr => (
    type => 'Text',
    label => 'IP Address',
);

has_field start_date => (
    type => 'Text',
    # TODO datetimepicker
    # TODO Inflate/deflate
);

has_field end_date => (
    type => 'Text',
    # TODO datetimepicker
    # TODO Inflate/deflate
);

has_field submit => (
    type => 'Submit',
    name => 'searchbutton',
    widget => 'ButtonTag',
    widget_wrapper => 'None',
    value => '<i class="fa fa-search"></i> Search',
    element_attr => { class => ['btn', 'btn-primary']},
);

1;

__END__

=head1 NAME

OpusVL::FB11X::AuditTrail::Form::EventSearch - Form for event search

=cut
