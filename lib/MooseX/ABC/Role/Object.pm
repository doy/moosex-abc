package MooseX::ABC::Role::Object;
use Moose::Role;

sub new {
    my $class = shift;
    Class::MOP::class_of($class)->throw_error(
        "$class is abstract, it cannot be instantiated"
    );
}

no Moose::Role;
1;
