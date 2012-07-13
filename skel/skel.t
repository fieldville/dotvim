#!/usr/bin/env perl
# vim: foldmethod=marker

use strict;
use warnings;

########################################
# 00-compile.t
########################################
#{{{
use Test::More;

BEGIN { use_ok '' }
require_ok ('');

done_testing;
#}}}

########################################
# 01-call_func.t
########################################
#{{{
use Test::More;

my @methods = qw/new/;

for my $method (@methods) {
    can_ok('', $method);
}

done_testing;
#}}}

########################################
# other
########################################
#{{{
use Test::More;
use Test::Exception;

sub test_func {
    my %specs = @_;
    my ( $input, $expects, $desc ) = @specs{qw/ input expects desc /};

    subtest $desc => sub {

    };

}

test_func(
    input   => +{},
    expects => +{},
    desc    => "test1",
);

done_testing;
#}}}
