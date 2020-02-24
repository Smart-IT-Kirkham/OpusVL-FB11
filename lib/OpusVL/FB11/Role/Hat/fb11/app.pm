package OpusVL::FB11::Role::Hat::fb11::app;

# ABSTRACT: Defines a hat that provides webapp behaviour
our $VERSION = '1';

use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

=head1 DESCRIPTION

These hats are for providing the C<fb11::app> service, which is expected to act
like a modern webapp.

It is specifically expected to act like an I<FB11> app, and therefore defines
methods that allow users to interface with FB11 app features, as well as those
expected of a generic webapp.

=head1 REQUIRED METHODS

=head2 psgi

This is expected to run the app as a PSGI app and return the result.

You would normally implement this as C<<
MyApp->apply_default_middlewares(MyApp->psgi_app) >>, which is the default
behaviour if you just want to use the L<OpusVL::FB11::Hat::fb11::simple_app> hat
to provide the service.

=head2 auth_feature_list

This is expected to return all the features of your application that will be
used for authentication.

The actual format of this list is currently not specified, because the list
exists in FB11 already, and the format is at best unhelpful. Discussion will be
had.

=cut

requires qw/psgi auth_feature_list/;

1;
