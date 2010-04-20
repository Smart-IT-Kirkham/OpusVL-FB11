package TestX::CatalystX::Validator::Token;

use Moose;

BEGIN { extends 'OpusVL::AppKit::LoginValidator' }

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
                label       => "Token Code",
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
    return 0;
};

override pre_validate => sub
{
    my $self    = shift;
    my ($c)     = @_;
};

override post_validate => sub
{
    my $self    = shift;
    my ($c)     = @_;
};

################################################################################################################################
# Methods that are specific to this.
################################################################################################################################




1;
__END__
