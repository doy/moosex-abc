package MooseX::ABC;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

=head1 NAME

MooseX::ABC - abstract base classes for Moose

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

This module adds basic abstract base class functionality to Moose. Doing
C<use MooseX::ABC> turns the using class into an abstract class - it cannot be
instantiated. It also allows you to mark certain methods in the class as
L</required>, meaning that if a class inherits from this class without
implementing that method, it will die at compile time.

=cut

=head1 EXPORTS

=cut

=head2 requires METHOD_NAMES

Takes a list of methods that classes inheriting from this one must implement.
If a class inherits from this class without implementing each method listed
here, an error will be thrown when compiling the class.

=cut

sub requires {
    my $caller = shift;
    my $meta = Class::MOP::class_of($caller);
    $meta->add_required_method($_) for @_;
}

Moose::Exporter->setup_import_methods(
    with_caller => [qw(requires)],
);

sub init_meta {
    shift;
    my %options = @_;
    Moose->init_meta(%options);
    Moose::Util::MetaRole::apply_base_class_roles(
        for_class       => $options{for_class},
        roles           => ['MooseX::ABC::Role::Object'],
    );
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class       => $options{for_class},
        metaclass_roles => ['MooseX::ABC::Trait::Class'],
    );
    return Class::MOP::class_of($options{for_class});
}

=head1 TODO

Probably want a way to extend abstract classes without dying, making the
inheriting class abstract.

=head1 BUGS

No known bugs.

Please report any bugs through RT: email
C<bug-moosex-abc at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-ABC>.

=head1 SEE ALSO

L<Moose>, L<Moose::Role>

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc MooseX::ABC

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-ABC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-ABC>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-ABC>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-ABC>

=back

=head1 AUTHOR

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
