#!perl

use 5.010;
use strict;
use warnings;

use JSON::Decode::Regexp qw(from_json);
#use JSON::PP; sub from_json { JSON::PP->new->allow_nonref->decode(shift) } # for comparison

use Test::Exception;
use Test::More 0.98;

is_deeply(from_json(q(null)), undef, "scalar (null)");

is_deeply(from_json(q(2)), 2, "scalar (num)");

ok(from_json(q(true)), "scalar (bool, true)");

ok(!from_json(q(false)), "scalar (bool, false)");

ok(from_json(q([1, -2, "3", "four"])), "simple array");

ok(from_json(q({"a":1, "b":2, "c":{}, "d":null})), "simple hash");

is_deeply(from_json(q([null, "", "a\nb c", 2, -3, 4.5, [], [1, "a", []], {}, {"0":null, "1":1, "b":"b", "c":[], "d":{}}])),
          [undef, "", "a\nb c", 2, -3, 4.5, [], [1, "a", []], {}, {0=>undef, 1=>1, b=>"b", c=>[], d=>{}}], "more comprehensive test");

dies_ok { from_json(q([)) } "invalid 1";
dies_ok { from_json(q(})) } "invalid 2";
dies_ok { from_json(q(nul)) } "invalid 3";

DONE_TESTING:
done_testing;
