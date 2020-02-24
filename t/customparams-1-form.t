use v5.24;
use Test::More 'no_plan';
use Test::Deep;
use OpusVL::FB11X::CustomParams::Form::Schema;

# This file is just going to be a bunch of form postdata and the expected
# OpenAPI field array that comes out of it.
subtest "Multi boolean" => sub {
    my $form = OpusVL::FB11X::CustomParams::Form::Schema->new;

    # Test that boolean with multi produces an array with CheckboxGroup widget

    my $postdata = {
       'fields.0.label' => 'Preferred Pizza Toppings',
       'fields.0.arity' => 'multi',
       'fields.0.format' => 'boolean',
       'fields.0.options.0' => 'Pineapple',
       'fields.0.options.1' => 'Pepperoni',
       'fields.0.options.2' => 'Just cheese',
       'fields.0.options.3' => 'Ham',
       'fields.0.options.4' => 'Ice',
       'fields.0.options.5' => '',
       'submit_button' => 'Save',
    };

    $form->process(
        params => $postdata,
        posted => 1,
    );

    is_deeply($form->to_openapi, {
        preferred_pizza_toppings => {
            type => "array",
            items => {
                enum => ["Pineapple", "Pepperoni", "Just cheese", "Ham", "Ice"],
                type => "string",
                "x-options" => [
                    "Pineapple", "Pineapple",
                    "Pepperoni", "Pepperoni",
                    "Just cheese", "Just cheese",
                    "Ham", "Ham",
                    "Ice", "Ice"
                ]
            },
            title => "Preferred Pizza Toppings",
            uniqueItems => \1,
            "x-widget" => 'CheckboxGroup'
        }
    });
};

done_testing;
