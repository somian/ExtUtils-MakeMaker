#!/bin/bash

declare +x MODULE_NAME=$1
perl -w -Mversion=qv -MExtUtils::Installed -MModule::List=list_modules -l \
  -e'my @eu= (qv(ExtUtils::Installed->VERSION),qv("2.0_01"));' \
  -e'die sprintf qq[Version of ExtUtils::Installed too old: %s not >= %s],$eu[0],$eu[1]' \
  -e'    if $eu[0] < $eu[1];' \
  -e'my($v,$e,$st,@ec); my $mp = $ARGV[0]=~m{::\z} ? $ARGV[0]:"$ARGV[0]::";' \
  -e'my $bn = $ARGV[0]=~m{::\z} ? substr($ARGV[0],-2):$ARGV[0];' \
  -e'my $i=ExtUtils::Installed->new();' \
  -e'for my $s ($bn, sort keys %{list_modules($mp,{list_modules=>1,recurse =>1})}){' \
  -e'printf qq[    ...analysing "%s"\n], $s;' \
  -e'if((not eval {$i->packlist($s)}) or $@){ $e=$@;' \
  -e'$e=~s{ is not installed at .+line \d}' \
  -e' { could not be detected [prob in CORE, or has no packlist of its own]};' \
  -e'chomp $e; my @p=split(q{ },$e,2); push @ec,\@p; next}' \
  -e'else{ $st++; $v=$i->version($s); my $wha=$i->modspec($s);my $pls=$i->packlistspec($s);' \
  -e'warn qq[No modspec for $s] unless $wha;' \
  -e'eval "require $s"; my $wr=sprintf q[%s],($INC{$wha}||q[BLANK]);' \
  -e'printf qq[    %s tells us that\n    %s v %s (%s) put files under:\n],$pls,$s,$v,$wr;' \
  -e'print for map{s;\\+;/;g;$_}$i->directories($s,q[all])}' \
  -e'}' \
  -e'if(@ec){printf STDERR qq[%-40s %s\n],$_->[0],$_->[1] for @ec};' \
  -e'if(!$st) {eval "require $bn";my $ha=$bn; $ha=~s[::][/]g;' \
  -e'my $wr=sprintf q[%s],($INC{"$ha.pm"}||q[BLANK]);' \
  -e'printf qq[Checking that %s can be found ...at %s\n], $bn, $wr;' \
  -e'print q[]}' "$MODULE_NAME"
