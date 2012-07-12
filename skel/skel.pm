package Hoge::Base::Fuga;
use strict;
use warnings;
use base qw( Hoge::Base );

use Carp;

sub new {
    my $class = shift;
    my $hash  = {};
    bless $hash, $class;
    return $hash;
}

1;
