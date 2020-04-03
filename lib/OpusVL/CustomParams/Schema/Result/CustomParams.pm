package OpusVL::CustomParams::Schema::Result::CustomParams;

use strict;
use warnings;
no warnings 'experimental::signatures';;
use DBIx::Class::Candy;

# ABSTRACT: Stores parameter schemata to supply to ObjectParams
our $VERSION = '2';

__PACKAGE__->load_components('InflateColumn::Serializer');

=head1 DESCRIPTION

This class represents a simple table that just stores OpenAPI JSON objects against semantic class names.

=head1 COLUMNS

=head2 type

The semantic type name being augmented with this schema

=head2 schema

A JSON field containng the OpenAPI schema.

=cut

table 'custom_params';

primary_column type => {
    data_type => 'text'
};

column schema => {
    data_type => 'jsonb',
    serializer_class => 'JSON',
    serializer_options => { allow_nonref => 1 },
};

1;
