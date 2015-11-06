package OpusVL::FB11::Controller::FB11::Ajax::Core;

use Moose;
use Cpanel::JSON::XS 'encode_json';
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_myclass              => 'OpusVL::FB11',
);

=head2 favourite

Usage: /fb11/ajax/core/favourite?title=Some+Title&url=/blah

TODO: Could do with moving a large portion of the parameter checking into 
a seperate method to use for future ajax requests

=cut

sub favourite
    : Path('favourite')
    : Args(0)
    : FB11Feature('Ajax')
{
    my ($self, $c) = @_;
    my $response = {};
    if (my $params = $c->req->query_params) {
        if ($params->{title} and $params->{url}) {
            my ($name, $page) = (
                $params->{title},
                $params->{url},
            );

            my $fav_rs = $c->model('FB11AuthDB::UsersFavourite')->search({ user_id => $c->user->id });
            if (my $fav_page = $fav_rs->find({ page => $page })) {
                $fav_page->delete();
                $response = {
                    error   => 0,
                    message => "DELETED",
                    url     => $page,
                    title   => $name,
                };
            }
            else {
                 $fav_rs->create({
                     page    => $page,
                     name    => $name,
                     user_id => $c->user->id,
                 });

                $response = {
                    error   => 0,
                    message => "SAVED",
                    url     => $page,
                    title   => $name,
                };
            }
        }
        else {
            $response = {
                error   => 1,
                message => "Title and URL required",
            };
        }
    }
    else {
        $response = {
            error   => 1,
            message => "Expecting query parameters with 'title' and 'url'",
        };
    }

    $c->res->body(encode_json($response));
}

1;
__END__
