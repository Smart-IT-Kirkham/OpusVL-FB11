package OpusVL::SysParams::Role::Hat::sysparams::consumer;

# ABSTRACT: Defines a Hat that has a sysparams spec for us

our $VERSION = '1';

use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

requires 'parameter_spec';
sub namespace {}

1;

=head1 DESCRIPTION

The sysparams service makes parameters available because components need them.
The component makes this requirement known by putting this Hat on its Brain.

The Hat is intended to create a list of parameters that the rest of the
component will rely on. It is therefore an error to request a parameter that
doesn't exist; you should probably not be asking for parameters from someone
else's namespace but if you are going to do that you have the responsibility of
keeping up with changes to their list.

=head1 METHODS

=head2 namespace

Provide a namespace for your parameters. The default for this is no value, which
means all your stuff goes in the global namespace. This is not just rude but it
risks your parameters being clobbered.

=head2 parameter_spec

This part is definitely required. Return a hashref specifying your parameters.

The keys to your hashref are the names of your parameters; easy. Your names can
really be anything but we recommend sticking to dots and dashes for separating
bits of the name.

The values define the defaults for your parameters, as more hashrefs:

=head3 value

The value key defines the default value of your parameter. This is required.

If you set this to an arrayref then your value will be an array forever.
Otherwise, it will be a scalar forever. Hashrefs are not supported.

To emulate a hashref, simply append the keys to the name of the parameter to
create multiple parameters. We recommend using a dot to do this. This ensures
related parameters remain related in the UI when the user comes to edit them.

We don't support hashrefs because they're too complicated to render, and you
can't have different types for each value.

A parameter can never be turned from a scalar to an array or vice-versa. If you
want to do that, you should create a new parameter with a different name;either
pluralise or unpluralise it, and use the new one. The sysparams API does not
define renaming a property because this is a temporal operation and sysparams
is a stateless service.

=head3 data_type

Also required (although we might default to C<text> in future), this
I<validates> the data inside your data structure. As you can imagine, this means
that your entire data structure must have the same thing inside it.

This can either be a simple string, or an object. Providing a string is exactly
equivalent to providing an object with a C<type> key with that string as the
value.

=over

=item B<text>: A single line of text

=item B<textarea>: A block of text

=item B<date>, B<time>, B<datetime>: These are separate to allow for things like durations

=item B<boolean>: A simple toggle

=item B<enum>: A more complex data type that provides a list of options

The enum type is always provided as an object (with C<type> set to C<enum> - see
above), because it needs C<parameters>. The parameters are provided exactly the
same as L<HTML::FormHandler::Field::Select/options>, which is a reasonably sensible
format, so we borrowed it.

=back

=head3 label

Also required, this is the human-readable name for this property. Avoid making
this too long; you can put help text in the comment.

=head3 comment

This is entirely there to be rendered as help text in the form. It also clues
developers in when they come to read your parameters spec later.
