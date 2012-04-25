package MooseX::ABC;
use Moose 0.94 ();
use Moose::Exporter;
# ABSTRACT: abstract base classes for Moose

=head1 SYNOPSIS

  package Shape;
  use Moose;
  use MooseX::ABC;

  requires 'draw';

  package Circle;
  use Moose;
  extends 'Shape';

  sub draw {
      # stuff
  }

  my $shape = Shape->new; # dies
  my $circle = Circle->new; # succeeds

  package Square;
  use Moose;
  extends 'Shape'; # dies, since draw is unimplemented

=head1 DESCRIPTION

This module adds basic abstract base class functionality to Moose. Doing C<use
MooseX::ABC> turns the using class into an abstract class - it cannot be
instantiated. It also allows you to mark certain methods in the class as
L</required>, meaning that if a class inherits from this class without
implementing that method, it will die at compile time. Abstract subclasses are
exempt from this, however - if you extend a class with another class which uses
C<MooseX::ABC>, it will not be required to implement every required method (and
it can also add more required methods of its own). Only concrete classes
(classes which do not use C<MooseX::ABC>) are required to implement all of
their ancestors' required methods.

=cut

=func requires METHOD_NAMES

Takes a list of methods that classes inheriting from this one must implement.
If a class inherits from this class without implementing each method listed
here, an error will be thrown when compiling the class.

=cut

sub requires {
    shift->add_required_method(@_);
}

Moose::Exporter->setup_import_methods(
    with_meta => [qw(requires)],
);

sub init_meta {
    my ($package, %options) = @_;

    Carp::confess("Can't make a role into an abstract base class")
        if Class::MOP::class_of($options{for_class})->isa('Moose::Meta::Role');

    Moose::Util::MetaRole::apply_metaroles(
        for             => $options{for_class},
        class_metaroles => {
            class => ['MooseX::ABC::Trait::Class'],
        },
    );
    Moose::Util::MetaRole::apply_base_class_roles(
        for   => $options{for_class},
        roles => ['MooseX::ABC::Role::Object'],
    );

    Class::MOP::class_of($options{for_class})->is_abstract(1);

    return Class::MOP::class_of($options{for_class});
}

=head1 SEE ALSO

L<Moose>

L<Moose::Role>

=begin Pod::Coverage

  init_meta

=end Pod::Coverage

=cut

1;
