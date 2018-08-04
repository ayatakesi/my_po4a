#! /usr/bin/perl
# DIA module tester.

#########################

use strict;
use warnings;

my @tests;

mkdir "t/tmp" unless -e "t/tmp";

$tests[0]{'run'}  = 'perl ../po4a-gettextize -f dia -m t-06-dia/extract.dia -p tmp/dia_extract.po';
$tests[0]{'test'} = 'perl compare-po.pl t-06-dia/extract.po-ok tmp/dia_extract.po';
$tests[0]{'doc'}  = 'get only needed strings';

$tests[1]{'run'}  = 'perl ../po4a-translate -f dia -m t-06-dia/transl.dia -p t-06-dia/transl.po -l tmp/transl.dia';
$tests[1]{'test'} = 'diff -u t-06-dia/transl.dia-ok tmp/transl.dia 1>&2';
$tests[1]{'doc'}  = 'test translations with new-lines';

use Test::More tests =>2*2; # tests * (run+validity)

for (my $i=0; $i<scalar @tests; $i++) {
    chdir "t" || die "Can't chdir to my test directory";

    my ($val,$name);

    my $cmd=$tests[$i]{'run'};
    $val=system($cmd);

    $name=$tests[$i]{'doc'}.' runs';
    ok($val == 0, $name);
    diag(%{$tests[$i]{'run'}}) unless ($val == 0);

    SKIP: {
        skip ("Command don't run, can't test the validity of its return",1)
          if $val;
	
	my $ret_dos2unix = system("dos2unix -qk tmp/*"); # Just in case this is Windows

        $val=system($tests[$i]{'test'});
        $name=$tests[$i]{'doc'}.' returns what is expected';
        ok($val == 0,$name);
        unless ($val == 0) {
            diag ("Failed (retval=$val) on:");
            diag ($tests[$i]{'test'});
            diag ("Was created with:");
            diag ($tests[$i]{'run'});
	    diag ("(dos2unix failed earlier)") unless ($ret_dos2unix == 0);
        }
    }

#    system("rm -f tmp/* 2>&1");

    chdir ".." || die "Can't chdir back to my root";
}

0;
