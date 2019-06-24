package TestApp::Brain::Hat::sysparams::consumer;

use Moose;

# A Hat should always have some sort of Role. The Role is defined by the system
# that is going to use the Hat. Each type of Hat should ideally be defined by
# only a single system, but in many cases, that system will be FB11 itself. That
# way, if you want to swap out your sysparams service, for example, you know
# that you can still rely on sysparams::consumers, and those consumers know they
# will be discovered.
#
# The point of the Hive is discoverability, so we prefer to define that in a
# place independent of the actual implementation of a particular service.
with 'OpusVL::SysParams::Role::Hat::sysparams::consumer';

# We don't make the namespace a property because there's no reason to, or way
# to, override it. This value ensures that any parameters with the same name
# in different components don't clobber one another
sub namespace { 'testapp' }

# Sysparams is defined as a bunch of configurable options that your system
# supports. It used to be an arbitrary list of values defined by the end user,
# but this meant there was no way to know what properties could be changed,
# what constraints they had, or what a sensible default might be. Now it is a
# big list collected bv the sysparams service by asking the Hive for
# sysparams::consumer hats and interrogating them.
#
# The data in this hashref will display on the UI if you include the
# OpusVL::FB11X::SysParams component in your application.
sub parameter_spec {
    {
        # The data type of a parameter refers to the formatting of the data in
        # it. The actual data *structure* is cemented by the value you supply at
        # this point. The array is an array because the value is an array.
        'array' => {
            label => "An array parameter, which may have multiple values",
            data_type => 'text',
            value => [ "Test item" ]
        },
        'text' => {
            label => "A text parameter",
            data_type => 'text',
            value => "Simple default",
        },
        'select' => {
            value => 'first',
            label => "A list of options",
            data_type => {
                type => 'enum',
                parameters => [
                    First => 'first',
                    Second => 'twoth',
                    Third => 'hunter22'
                ]
            }
        },
        'object.key1' => {
            value => "A value",
            label => "Key1 for Object type",
            data_type => 'text',
            comment => "You can construct an object type out of subkeys, by using a dot in the name."
        },
    }
}

1;
