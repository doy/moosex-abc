#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 9;
use Test::Exception;

package Foo;
use Moose;
use MooseX::ABC;

requires 'bar', 'baz';

__PACKAGE__->meta->make_immutable;

package Foo::Sub1;
use Moose;
::lives_ok { extends 'Foo' } 'extending works when the requires are fulfilled';
sub bar { }
sub baz { }

__PACKAGE__->meta->make_immutable;

package Foo::Sub2;
use Moose;
::throws_ok { extends 'Foo' } qr/Foo requires Foo::Sub2 to implement baz/,
    'extending fails with the correct error when requires are not fulfilled';
sub bar { }

package Foo::Sub::Sub;
use Moose;
::lives_ok { extends 'Foo::Sub1' } 'extending twice works';

__PACKAGE__->meta->make_immutable;

package main;
my $foosub;
lives_ok { $foosub = Foo::Sub1->new }
    'instantiating concrete subclasses works';
isa_ok($foosub, 'Foo', 'inheritance is correct');
my $foosubsub;
lives_ok { $foosubsub = Foo::Sub::Sub->new }
    'instantiating deeper concrete subclasses works';
isa_ok($foosubsub, 'Foo', 'inheritance is correct');
isa_ok($foosubsub, 'Foo::Sub1', 'inheritance is correct');
throws_ok { Foo->new } qr/Foo is abstract, it cannot be instantiated/,
    'instantiating abstract classes fails';
