package MooseX::ABC;
use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

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
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class       => $options{for_class},
        metaclass_roles => ['MooseX::ABC::Trait::Class'],
    );
    return Class::MOP::class_of($options{for_class});
}

=for motivation

22:41 <@rjbs> So, say I wanted to write 'shape'
22:41 <@rjbs> as a class
22:41 <@rjbs> but an abstract base class
22:41 <@rjbs> I could say: requires 'area'
22:41 <@rjbs> except I can't, because a class can't be abstract in that sense,
              in Perl
22:41 <@rjbs> er, in Moose
22:42 <@rjbs> so to use a delegate is a compromise
22:42 <@rjbs> It isn't what I want: an ABC
22:42 <@rjbs> It isn't entirely what I don't wnat: a role
22:42 <@doy> i wonder if something like a lazy role would work
22:42 <@rjbs> lazy role?
22:42 <@doy> instead of dying if all required methods aren't satisfied at
             compile time, do it at instantiation time
22:43 <@doy> applying a role and not satisfying all requires turns that class
             into an abstract class
22:43 <@rjbs> but now we're back to instantiation time!
22:43 <@rjbs> I want compile time.
22:44 <@rjbs> package Shape; use Moose::ABC; # now you get no new method, you
              can't instantiate directly, and you have "requires" sugar
22:44 <@rjbs> and if you "extends 'Shape'" without fulfilling rqeuires, you die
22:44 <@doy> yeah, that would be nicer

=cut

1;
