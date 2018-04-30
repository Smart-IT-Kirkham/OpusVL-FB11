package OpusVL::FB11X::Parameters::Model::ParametersDB;

use Moose;

BEGIN {
    extends 'Catalyst::Model::DBIC::Schema';
}

__PACKAGE__->config(
    schema_class => 'OpusVL::FB11::Schema::Parameters',
    traits => 'SchemaProxy',
);
1;
