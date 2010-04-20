
package OpusVL::AppKit::LoginValidator::SMS;

use Moose;

BEGIN { extends 'OpusVL::AppKit::LoginValidator' };

################################################################################################################################
# Extended methods from the Base Class
################################################################################################################################

override _build_formfu => sub 
{
    return 
    {
        indicator       => 'submitbutton',
        auto_fieldset   => 1,
        elements        => 
        [ 
            { 
                type        => "Text",
                name        => "validation_code",
                label       => "Validation Code",
                constraints     => 
                [ 
                    { type        => "Number", },
                ]
            },
            { name => "submitbutton", type => "Submit", value => "Validate My Login" },
        ],
        constraints     => 
        [ 
            { type        => "SingleValue", },
            { type        => "Required", },
        ],
    };
};

override validate => sub 
{
    my $self    = shift;
    my ($c)     = @_;

    my $code = $self->get_valid_code( $c->user );

    if ( $code )
    {
        if ( $code eq $c->req->params->{validation_code} )
        {
            return 1;
        }
    }
    else
    {
        $c->stash->{error_msg} = "Your code seems to have expired";
    }

    return 0;
};

override pre_validate => sub 
{
    my $self    = shift;
    my ($c)     = @_;

    # if we have a valid code, get it...
    my $code = $self->get_valid_code( $c->user );
    # .. if no code, generate it...
    $code = $self->generate_code( $c->user ) unless ( $code );

    $c->stash->{status_msg} = "We have sent you an SMS message to: " . $c->user->tel . " .. not really, I'm just testing, so here it is: $code";
};

override post_validate => sub 
{
    my $self    = shift;
    my ($c)     = @_;

    # clean up the epoch.. just incase...
    my ( $vald_code, $vald_epoch ) = $self->get_code_and_epoch( $c->user );
    $vald_epoch->delete;
};


################################################################################################################################
# Methods that are specific to this.
################################################################################################################################

sub get_valid_code
{
    my $self = shift;
    my ($user) = @_;

    # 5 mins until code become invalid.
    my $secs_until_invalid = 60 * 5; 

    # get the validation data..
    my ( $vald_code, $vald_epoch ) = $self->get_code_and_epoch( $user );

    if ( ( $vald_code->value ) && ( $vald_epoch->value ) && ( ($vald_epoch->value + $secs_until_invalid) > time ) )
    {
        return $vald_code->value;
    }
    return 0;
}

sub generate_code
{
    my $self = shift;
    my ($user) = @_;

    # .. generate code...
    my @chars = ( 0 .. 9 );
    my $code  = join("", @chars[ map { rand @chars } ( 1 .. 6 ) ]);

    # get the validation data..
    my ( $vald_code, $vald_epoch ) = $self->get_code_and_epoch( $user );

    $vald_code->update( { value => $code } );
    $vald_epoch->update( { value => time } );

    return $code;
}

sub get_code_and_epoch
{
    my $self = shift;
    my ($user) = @_;

    # find and validation data in the AppKitAuthDB ...
    my $vald_code   = $user->find_or_create_related( 'validation_data', { key => 'LoginValidator::SMS->code' } );
    my $vald_epoch  = $user->find_or_create_related( 'validation_data', { key => 'LoginValidator::SMS->epoch' } );

    return ($vald_code, $vald_epoch);
}

1;
__END__
