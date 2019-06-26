package TestApp::Brain;

# This is a pretty basic Brain. You should check out the documentation for
# OpusVL::FB11::Hive and associated modules.
use Moose;

# We always set this as a 'has' so it can be provided to the constructor. This
# allows Brains to be renamed in the Hive. The only reason this should ever
# happen is if you have two Brains with the same short_name, but this is
# extremely unlikely to happen. You might also do it if the default name
# changes, and it's easier to rename it in your Hive than catch up with the new
# name.
#
# In theory, you could also just set the name of the Brain so you know what it
# is and therefore don't have to read the docs.
has short_name => (
    is => 'ro',
    default => 'testapp'
);

with 'OpusVL::FB11::Role::Brain';

sub hats {
    # Without any special configuration, the Hive will look in
    # BRAINNAME::Hat::HATNAME, for example
    # TestApp::Brain::Hat::sysparams::consumer. Check out all the modules in the
    # Hat directory for more info.
    'sysparams::consumer',

    # *With* special configuration you can tell the Hive which class to use.
    # FB11 defines a basic Hat that your Brain can wear to say it has the
    # webapp. The + syntax here is familiar from other CPAN modules that let you
    # specify an absolute class name in a place where it would normally
    # construct one for you.
    #
    # The class we use here accepts a constructor parameter, but this is not
    # true of all Hats.
    #
    # This stanza just says, expose TestApp as the PSGI-capable web app.
    'fb11::app' => {
        class => '+OpusVL::FB11::Hat::fb11::simple_app',
        constructor => {
            appname => 'TestApp'
        }
    }

}

sub provided_services {
    # A service is provided by using a hat with the same name. That Hat should
    # ideally consume a Role appropriate to the service, so that you can be sure
    # that when people actually call it, they get what they expected.
    #
    # When you configure your Hive you tell it that this brain is the one to
    # use; this way, many Brains can provide the same service, but only one is
    # used to actually fulfil it.
    qw/fb11::app/
}

sub dependencies {
    # This doesn't do much except ensure that the Hive is consistent when built.
    # If you forget to put any of these as a service in your Hive, this will
    # cause it to die instead of running broken. This list can also be used by
    # other Brains to make sure their dependencies are initialised first.
    #
    # We require sysparams because we declare some, and sysparams::management
    # because this brain provides the fb11::app, and that app includes the FB11X
    # component for editing them. If we missed any of these, it would die at
    # runtime instead of compile time.
    services => [qw/
        sysparams
        sysparams::management
    /]
    # You can also rely on Brains by their short_name but this forces a very
    # close coupling. Only ever do this if your Brain is an extension to a very
    # explicit single other Brain; otherwise, it is best to use the Hive to
    # expose services to Brains by means of a shared API.
}

1;
