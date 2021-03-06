#!/usr/bin/perl
#
# Usage:
#
#    env_config.pl <other commands>
#
# Reads a nginx.conf template source file (defaults to
# `/etc/nginx/nginx.conf.tmpl`), replaces all environment
# variables found, and writes to `/etc/nginx/nginx.conf.
#
# You can defined an alternative nginx.conf.tmpl file using the
# NGINX_CONF_TMPL environment variable.
#
# Afterwards, exec's <other command>
#
# Works fine as entrypoint script, no dependencies

use strict;
use warnings;

my (@cmd) = @ARGV;
@cmd = ('nginx', '-g', 'daemon off;') unless @cmd;    ## default command: start nginx
@cmd = ('/bin/sh') if @cmd == 1 and $cmd[0] and $cmd[0] eq 'sh';    ## shell shortcut
usage() if @cmd == 1 and $cmd[0] and $cmd[0] eq 'usage';            ## usage shortcut
help() if @cmd == 1 and $cmd[0] and ($cmd[0] eq 'help' or $cmd[0] eq 'readme');    ## readme

my $dest   = '/etc/nginx/nginx.conf';
my $source = $ENV{NGINX_CONF_TMPL} || '/etc/nginx/nginx.conf.tmpl';
usage('missing <source> file') unless $source and -r $source;

open(my $in,  '<:raw', $source) or fatal("failed to open file '$source'");
open(my $out, '>:raw', $dest)   or fatal("failed to create file '$dest'");

while (<$in>) {
  s/\$\{(\w[\w\d_]*)(?::-(.+?))?\}/exists $ENV{$1}? $ENV{$1} : defined($2)? $2 : fatal("ENV $1 required but not declared")/gsme;
  print $out $_;
}
close($in);
close($out);

exec(@cmd) if @cmd;
die "FATAL: failed to exec '@cmd': $?";


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

sub help {
  exec('/bin/cat', '/README.md');
  die "FATAL: failed to exec '/bin/cat': $?";
}

sub fatal {
  print STDERR "FATAL: @_\n";
  exit(1);
}

__DATA__
