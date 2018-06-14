#! /usr/bin/perl
# MAN module tester.

#########################

use strict;
use warnings;

my @tests;

my @formats=qw(pod);

mkdir "t/tmp" unless -e "t/tmp";

my $diff_pod_flags= " -I 'This file was generated by po4a' ";

$tests[0]{'doc'}  = "po4a-translate discards the fuzzy translation (and report so)";
$tests[0]{'run'}  = "perl ../po4a-translate -f pod -k 0 -m t-07-discard/pod -p t-07-discard/pod.po -l tmp/pod.fr";
$tests[0]{'test'} = "diff -u t-07-discard/pod.fr tmp/pod.fr $diff_pod_flags";

use Test::More tests =>2; # $formats * $tests * 2

foreach my $format (@formats) {
    for (my $i=0; $i<scalar @tests; $i++) {
        chdir "t" || die "Can't chdir to my test directory";

        my ($val,$name);

        my $cmd=$tests[$i]{'run'};
        $cmd =~ s/#format#/$format/g;
        $val=system($cmd);

        $name=$tests[$i]{'doc'}.' runs';
        $name =~ s/#format#/$format/g;
        ok($val == 0,$name);
        diag($cmd) unless ($val == 0);

        SKIP: {
            skip ("The command fails to run, I can't test the validity of its effect.",1)
              if $val;
            my $testcmd=$tests[$i]{'test'};
            $testcmd =~ s/#format#/$format/g;

            $val=system($testcmd);
            $name=$tests[$i]{'doc'}.' returns what is expected';
            $name =~ s/#format#/$format/g;
            ok($val == 0,$name);
            unless ($val == 0) {
                diag ("Failed (retval=$val) on:");
                diag ($testcmd);
                diag ("Was created with:");
                diag ("perl -I../lib $cmd");
            }
        }

#    system("rm -f tmp/* 2>&1");

        chdir ".." || die "Can't chdir back to my root";
    }
}

0;
