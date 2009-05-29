package MooseX::ABC::Role::Object;
use Moose::Role;

around new => sub {
    my $orig = shift;
    my $class = shift;
    my $meta = Class::MOP::class_of($class);
    $meta->throw_error("$class is abstract, it cannot be instantiated")
        if $meta->has_required_methods;
    $class->$orig(@_);
};

no Moose::Role;
1;
