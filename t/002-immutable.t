#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 5;
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

__PACKAGE__->meta->make_immutable;

package main;
my $foosub;
lives_ok { $foosub = Foo::Sub1->new }
    'instantiating concrete subclasses works';
isa_ok($foosub, 'Foo', 'inheritance is correct');
throws_ok { Foo->new } qr/Foo is abstract, it cannot be instantiated/,
    'instantiating abstract classes fails';
