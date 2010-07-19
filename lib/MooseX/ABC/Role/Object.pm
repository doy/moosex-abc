package MooseX::ABC::Role::Object;
use Moose::Role;
# ABSTRACT: base object role for L<MooseX::ABC>

=head1 DESCRIPTION

This is a base object role implementing the behavior of L<MooseX::ABC> classes
being uninstantiable.

=cut

around new => sub {
    my $orig = shift;
    my $class = shift;
    my $meta = Class::MOP::class_of($class);
    $meta->throw_error("$class is abstract, it cannot be instantiated")
        if $meta->is_abstract;
    $class->$orig(@_);
};

no Moose::Role;

1;
