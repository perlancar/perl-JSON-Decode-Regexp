package JSON::Decode::RegexpDebug;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

#use Data::Dumper;
use DD;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(from_json);

our $FROM_JSON = qr{

(?&VALUE) (?{ print "D:value: \$^R = "; dd $^R; $_ = $^R->[1] })

(?(DEFINE)

(?<OBJECT>
  \{\s*
    (?{ print "D:obj: "; dd [$^R, {}] })
    (?: (?&KV) # [[$^R, {}], $k, $v]
      (?{ # warn Dumper { obj1 => $^R };
	 print "D:obj first kv: \$^R = "; dd $^R; print "  "; dd [$^R->[0][0], {$^R->[1] => $^R->[2]}] })
      (?: \s*,\s* (?&KV) # [[$^R, {...}], $k, $v]
        (?{ # warn Dumper { obj2 => $^R };
	   print "D:obj next kv: \$^R = "; dd $^R;
           $^R->[0][1]{ $^R->[1] } = $^R->[2];
           print "  "; dd $^R->[0] })
      )*
    )?
  \s*\}
)

(?<KV>
  (?&STRING) # [$^R, "string"]
  \s*:\s* (?&VALUE) # [[$^R, "string"], $value]
  (?{ # warn Dumper { kv => $^R };
     print "D:kv: \$^R = "; dd $^R; print "  "; dd [$^R->[0][0], $^R->[0][1], $^R->[1]] })
)

(?<ARRAY>
  \[\s*
    (?{ print "D:array: "; dd [$^R, []] })
    (?: (?&VALUE) (?{ print "D:array 1st elem: \$^R = "; dd $^R; print "  "; dd [$^R->[0][0], [$^R->[1]]] })
      (?: \s*,\s* (?&VALUE) (?{ # warn Dumper { atwo => $^R };
			 print "D: array next elem: \$^R = "; dd $^R;
                         push @{$^R->[0][1]}, $^R->[1];
                         print "  "; dd $^R->[0] })
      )*
    )?
  \s*\]
)

(?<VALUE>
  \s*
  (
      (?&STRING)
    |
      (?&NUMBER)
    |
      (?&OBJECT)
    |
      (?&ARRAY)
    |
    true (?{ print "D:true: "; dd [$^R, 1]; })
  |
    false (?{ print "D:false: "; dd [$^R, 0] })
  |
    null (?{ print "D:null: "; dd [$^R, undef] })
  )
  \s*
)

(?<STRING>
  (
    "
    (?:
      [^\\"]+
    |
      \\ ["\\/bfnrt]
#    |
#      \\ u [0-9a-fA-f]{4}
    )*
    "
  )

  (?{ print "D:str: "; dd [$^R, eval $^N] })
)

(?<NUMBER>
  (
    -?
    (?: 0 | [1-9]\d* )
    (?: \. \d+ )?
    (?: [eE] [-+]? \d+ )?
  )

  (?{ print "D:num: "; dd [$^R, 0+$^N] })
)

) }xms;

sub from_json {
    local $_ = shift;
    local $^R;
    eval { m{\A$FROM_JSON\z}; } and return $_;
    die $@ if $@;
    die 'no match';
}

1;
# ABSTRACT: JSON parser as a single Perl Regex (debug version)

=head1 SYNOPSIS

 use JSON::Decode::RegexpDebug qw(from_json);
 my $data = from_json(q([1, true, "a", {"b":null}]));

=head1 DESCRIPTION
