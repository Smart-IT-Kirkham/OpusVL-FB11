package OpusVL::FB11::Schema::Parameters::Result::User;

use Moose;
use MooseX::NonMoose;

use DBIx::Class::Candy
    -components => ['InflateColumn::Serializer'];

table 'user_parameters';

primary_column id => {
    data_type => 'int',
};

column prefs_json => {
    data_type => 'jsonb',
    serializer_class => 'JSON',
};

belongs_to user => 'OpusVL::FB11::Schema::FB11AuthDB::Result::User' => 'id';

1;
