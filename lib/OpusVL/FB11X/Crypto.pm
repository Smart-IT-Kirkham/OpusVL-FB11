package OpusVL::FB11X::Crypto;

with 'OpusVL::FB11::RolesFor::Plugin';

our $VERSION = '0.039';

after 'setup_components' => sub {
    my $class = shift;

    my $moduledir = $class->add_paths(__PACKAGE__);

    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::Crypto::Model::Crypto',
        as        => 'Model::Crypto'
    );
}

1;
