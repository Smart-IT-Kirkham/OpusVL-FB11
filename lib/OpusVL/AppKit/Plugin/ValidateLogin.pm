package OpusVL::AppKit::Plugin::ValidateLogin;

use warnings;
use strict;
use namespace::autoclean;
use Moose::Role;

has loaded_validators => ( is => 'ro',  isa => 'HashRef',   lazy_build => 1 );
sub _build_loaded_validators
{
    my $c = shift;
    my $loaded_validators = {};
    foreach my $val_mod ( @{ $c->config->{validators} } )
    {
        # get and store the name of the validator module just loaded....
        $val_mod =~ m/\:\:(.[^\:]+)$/;
        $loaded_validators->{ $1 } = $val_mod;
    }
    return $loaded_validators;
}

after 'setup_finalize' => sub 
{
    my $c = shift;

    foreach my $val_mod ( @{ $c->config->{validators} } )
    {
        unless ( $val_mod =~ m/\:\:/ )
        {
            $val_mod = 'OpusVL::AppKit::LoginValidator::' . $val_mod
        }

        # TODO: check we have the  parameters in the AppKitAuthDB for these validators..

        Catalyst::Utils::ensure_class_loaded( $val_mod );
    }
};

1;
__END__
