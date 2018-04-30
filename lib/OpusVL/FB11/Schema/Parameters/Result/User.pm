package OpusVL::FB11::Schema::Parameters::Result::User;

use Moose;
use MooseX::NonMoose;

with 'OpusVL::Preferences::RolesFor::Result::PrfOwner';

use DBIx::Class::Candy
    -components => ['InflateColumn::Serializer'];

table 'user_parameters';

primary_column id => {
    data_type => 'int',
};

column prf_owner_type_id => {
    data_type      => 'integer',
    is_nullable    => 1,
    is_foreign_key => 1
};


belongs_to prf_owner => 'OpusVL::Preferences::Schema::Result::PrfOwner',
    {
        'foreign.prf_owner_id'      => 'self.id',
        'foreign.prf_owner_type_id' => 'self.prf_owner_type_id'
    };

belongs_to prf_owner_type => 'OpusVL::Preferences::Schema::Result::PrfOwnerType',
    {
        'foreign.prf_owner_type_id' => 'self.prf_owner_type_id'
    };


belongs_to core_user => 'OpusVL::FB11::Schema::FB11AuthDB::Result::User' => 'id';

1;
