#!/usr/bin/perl
#
# Usage:
#
#    env_config.pl <source> <dest> <other commands>
#
# Reads <source> file, replaces all environment variables found, and writes to <dest>.
#
# Afterwards, exec's <other command>
#
# Works fine as entrypoint script, no dependencies

use strict;
use warnings;

my ($source, $dest, @cmd) = @ARGV;
@cmd = ('nginx', '-g', 'daemon off;') unless @cmd;    ## default command: start nginx
@cmd = ('/bin/sh') if @cmd == 1 and $cmd[0] and $cmd[0] eq 'sh';    ## shell shortcut
usage() if @cmd == 1 and $cmd[0] and $cmd[0] eq 'usage';    ## usage shortcut

usage('missing <source> file') unless $source and -r $source;
usage('missing <dest> file') unless $dest;

open(my $in,  '<:raw', $source) or fatal("failed to open file '$source'");
open(my $out, '>:raw', $dest)   or fatal("failed to create file '$dest'");

while (<$in>) {
  s/\$\{(\w[\w\d_]*)(?::-(.+?))?\}/exists $ENV{$1}? $ENV{$1} : defined($2)? $2 : fatal("ENV $1 required but not declared")/gsme;
  print $out $_;
}
close($in);
close($out);

exec(@cmd) if @cmd;


sub usage {
  print STDERR "ERROR: @_\n" if @_;

  seek(DATA, 0, 0);
  while (<DATA>) {
    chomp;
    next if /^#!/;
    if   (/^#\s?(.*)/) { print "$1\n" }
    else               {last}

  }
  exit(2);
}

sub fatal {
  print STDERR "FATAL: @_\n";
  exit(1);
}

__DATA__
