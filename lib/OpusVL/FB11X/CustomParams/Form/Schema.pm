package OpusVL::FB11X::CustomParams::Form::Schema;

# ABSTRACT: Form to create and edit parameter schema

use v5.24;
use Switch::Plain;
use OpusVL::FB11::Plugin::FormHandler;

=head1 DESCRIPTION

This form backs a corresponding template and marshals fields by which a user can
edit the OpenAPI schemata stored in the CustomParams database.

It only supports a fairly simple selection of field options because the more we
support the more we have to support.

=head1 FIELDS

=head2 fields

This entire form is a single, repeatable, compound field called C<fields>, plus
a submit button.

=head3 label

The user is prompted to provide a label but not a name. We construct the field's
HTML name from the label they provide. This field is required.

=head3 arity

The user may select whether the field has a single value or multiple. This
ultimately determines whether we draw a repeatable field or not.

=head3 format

The format of the field determines what control we draw. Specific attention
shoudl be paid to enum and boolean.

An enum format will provide a list of options to a select box. If the arity is
multiple, the select box will be multiple. If checkbox is selected, the same set
of options is drawn with checkboxes instead.

The enum type makes use of the options field; the checkbox type only makes use
of the options field if the arity is multiple.

=head2 options

A field to contain the options for the format field. This is used for enum
fields as well as checkboxes when the arity is multiple.

=cut

# NOTE: Even though we have the js-repeatable.js file now, I don't fancy
# rewriting this to use it. I stole the template and its associated JS from the
# CMS form builder and it seems to Just Work...
has_field fields => (
    type => 'Repeatable',
);
has_field 'fields.label' => (
    required => 1,
    element_class => [qw/ field field-label data-text /],
);
has_field 'fields.arity' => (
    type => 'Select',
    widget => 'RadioGroup',
    wrapper_class => [qw/ field field-arity data-enum /],
    options => [
        single => "Single",
        multi => "Multiple",
    ]
);
has_field 'fields.format' => (
    type => 'Select',
    element_class => [qw/ field field-format data-enum /],
    options => [
        none => "Free text",
        boolean => "Checkbox",
        number => "Numeric",
        datetime => "Date and time",
        date => "Date only",
        time => "Time only",
        enum => "Select from list",
    ],
);
has_field 'fields.options' => (
    type => 'Repeatable',
    num_extra => 1,
    # This field uses shown-with but that is done in the template
);
has_field 'fields.options.contains' => (
    do_label => 0,
    element_class => [qw/ field field-option data-text /],
);

has_field submit_button => (
    type => 'Submit',
    element_class => ['btn','btn-primary'],
);

=head1 METHODS

=head2 to_openapi

This converts the data from the form into an OpenAPI C<properties> object, which
can then be packed up in a schema object and sent to ObjectParams.

=cut

sub to_openapi {
    my $self = shift;
    my @fields = $self->value->{fields}->@*;

#    fields => [
#         { arity => "single", format => "datetime", label => "arararr", options => [] },
#       ],
#    }

    my $openapi = {};

    for my $f (@fields) {
        my $name = lc($f->{label} =~ s/\s+/_/gr);
        my $is_multi = $f->{arity} eq 'multi';

        my $property = {
            type => 'text', # This may change below
        };

        sswitch ($f->{format}) {
            case 'boolean': {
                # A multi checkbox is really just a different way of drawing
                # a multi select, i.e. an array of text values
                if ($is_multi) {
                    $property->{enum} = $f->{options};
                    $property->{'x-options'} = [ map { $_, $_ } $f->{options}->@* ];

                    # FIXME: OpusVL::FB11::Form handles this. We might later
                    # change how we define this information.
                    $property->{'x-widget'} = 'CheckboxGroup';
                }
                else {
                    $property->{type} = 'boolean';
                }
            }

            case 'enum': {
                $property->{enum} = $f->{options};
                $property->{'x-options'} = [ map { $_, $_ } $f->{options}->@* ]
            }

            default: {
                $property->{format} = $_;
            }
        }

        if ($is_multi) {
            my $real_property = {
                type => 'array',
                items => $property,
                uniqueItems => \1,  # This should be JSON true
            };

            $real_property->{'x-widget'} = delete $property->{'x-widget'} if $property->{'x-widget'};
            $property = $real_property;

        }

        # This goes last in case we demoted the original $property to items
        $property->{label} = $f->{label};

        $openapi->{$name} = $property;
    }

    return $openapi;
}

=head2 from_openapi

This is a I<class> method that turns the OpenAPI C<properties> object into an
C<init_object> for your form. This is provided instead of just creating a form
for you because you probably already have a form from your controller.

=cut

sub from_openapi {
    my $class = shift;
    my $openapi = shift;

    my $init_obj = { fields => [] };

    for my $name (keys %$openapi) {
        my $property = $openapi->{$name};
        my $field_spec = {
            label => $property->{label},
        };

        my $arity = $property->{type} eq 'array' ? 'multi' : 'single';

        if ($arity eq 'multi') {
            $property = $property->{items}
        }

        my $format = $property->{format};

        if ($property->{'x-widget'} // '' eq 'CheckboxGroup') {
            $format = 'checkbox';
        }

        elsif ($property->{enum}) {
            $format = 'enum';
        }

        $field_spec->{format} = $format;
        $field_spec->{arity} = $arity;
        $field_spec->{options} = $property->{enum};

        push $init_obj->{fields}->@*, $field_spec;
    }

    return $init_obj;
}

1;
