#!/usr/bin/env perl
# Copyright (c) 2012, Kamil "elwin013" Banach
# Permission to use, copy, modify, and/or distribute this software for 
# any purpose with or without fee is hereby granted, provided that the 
# above copyright notice and this permission notice appear in all copies. 
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES 
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE 
# FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY 
# DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER 
# IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING 
# OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use strict;
use Switch;
use Term::ANSIColor qw / colored /;
use File::Spec::Functions qw/ catfile /;

use vars qw /$DB @fields/;
$DB = catfile $ENV{HOME} ,".addressbook";     # Address book file
@fields = ("Name","Nick","E-mails","Phones","IMs","Address","Notes",);
{ foreach (@fields) { $_ = colored ['bold'], $_; } } # Add bold

sub by_id {               # sort subroutine
  my @a = split /;/, $a;
  my @b = split /;/, $b;
  $a[0] <=> $b[0];
}; 

sub msg { print colored ['bold'], "=> "; print "@_\n"; }
sub openInput { open IN, "<", $DB or die "I can't open file $DB: $!"; }

sub help {
  print <<HELP;
  Syntax: $0 action [ID/KEYWORD]
    help            - view this help
    list            - list all records
    view ID         - show record with specified ID
    add             - add new record (interactive)
    edit ID         - edit record with specified ID (interactive)
    del ID          - delete record with specified ID
    search KEYWORD  - search a KEYWORD in database and show results
HELP
}

sub sort {                # Sort 
  &openInput;
  my @lines = ();
  while(<IN>) {           # Skip empty lines
    chomp;
    if ($_ eq "") { next; }
    push @lines, $_."\n";
  }
  close IN;
  saveRecordsToFile(@lines);
}
sub resetCounter {        # Reset IDs (to avoid i.e. 1,2,5,23)
  @_ = sort by_id @_;
  my $counter = 1;
  foreach (@_) {      
    s/^[0-9]+/$counter/;
    $counter++;
  }
  return @_;
}

sub getByID {             # Get an record from file 
  my $wantedID = $_[0];
  unless ($wantedID) {
    &msg("You must specify ID!");
    exit;
  }
  &openInput;
  while(<IN>) {
    chomp;
    /^[0-9]+/;
    if($& == $wantedID) { 
      close IN;
      return split /;/, $_; 
    }
  }
  msg("There is no record!");
  close IN;
  exit;
}

sub getLastID {           # Get an last record ID from file 
  &openInput;
  my $_ = <IN>;
  unless ($_) { $_ = 0; }
  /^[0-9]+/;
  return $&;
  close IN;
}

sub saveRecord {
  open OUT, ">>", $DB or die "I can't open file $_: $!";
  print OUT $_[0]."\n";
  close OUT;
  &sort;
}

sub removeRecord {        # Return a db without record with some ID
  &openInput;
  my $wantedID = $_[0];
  my @lines = ();
  while(<IN>) {
    /^[0-9]+/;
    if($& == $wantedID) { next; }
    push @lines, $_;
  }
  close IN;
  @lines;
}

sub saveRecordsToFile {   # Save records to file
  my @lines = @_;
  open OUT, ">", $DB or die "I can't open file $DB: $!";
  @lines = &resetCounter(@lines);
  foreach (reverse @lines) { print OUT $_; }
  close OUT; 
}

sub view {                # View a record
  my($id, $name, $nick, $email, $phones, $im, $address, $notes) = &getByID($_[0]);
  my $record = "";
  &msg("Begin record #${id}");
  $record .= "$fields[0]: $name\n"          if $name;
  $record .= "$fields[1]: $nick\n"          if $nick;
  $record .= "$fields[2]: $email\n"         if $email;
  $record .= "$fields[3]: $phones\n"        if $phones;
  $record .= "$fields[4]: $im\n"            if $im;
  $record .= "$fields[5]: $address\n"       if $address;
  $record .= "$fields[6]: $notes\n"         if $notes;
  print $record;
  &msg("End record #${id}");
}

sub add {                 # Interactive adding record
  &msg("Adding new record");
  my @values = ("")x7;
  foreach (0..6) {
    print "$fields[$_]: "; 
    chomp($values[$_] = <STDIN>);
  }
  my $id = &getLastID+1;
  if($id == 0) { $id = 1; }
  my $record = join ";", ($id, @values);
  &saveRecord($record);
  &msg("Record added with ID $id");
}

sub del {
  my @lines = &removeRecord($_[0]);
  &saveRecordsToFile(@lines);
  &msg("Record removed");
}

sub list {
  &openInput;
  my @list = ();
  while(<IN>) {
    my($id, $name, $nick) = (split /;/)[0..2];
    push @list, "#$id: $name, $nick";
  }
  foreach (reverse @list) { print $_."\n"; }
  close IN;
}

sub search {
  &openInput;
  my $wanted = $_[0];
  my @list = ();
  while(<IN>) {
    if (/$wanted/i) {
      my($id, $name, $nick) = (split /;/)[0..2];
      push @list, "#$id: $name, $nick"; 
    }
  }
  foreach (reverse @list) { print $_."\n"; }
  close IN;
}

sub edit {              # Interactive editing files
  my $wantedID = $_[0];
  my(@values, @oldValues) = ()x7;
  (my $id, @oldValues) = &getByID($wantedID);
  foreach (0..6) {
    print "$fields[$_]"; 
    print " ['".$oldValues[$_]."']" if $oldValues[$_];
    print ": ";
    chomp($values[$_] = <STDIN>);
  }
  foreach (0..6) {
    if ($values[$_] eq "") { $values[$_] = $oldValues[$_]; }
  }
  my @lines = &removeRecord($wantedID);
  my $record = join ";", ($id, @values);
  push @lines, $record."\n";
  &saveRecordsToFile(@lines);
  &msg("Record saved")
}

sub main {
  my($action, $parameter) = @ARGV;
  switch ($action) {
    case "help"   { &help; } 
    case "view"   { &view($parameter); }
    case "edit"   { &edit($parameter); }
    case "add"    { &add; } 
    case "del"    { &del($parameter); }
    case "list"   { &list; }
    case "search" { &search($parameter); }
    else { &msg("Not enough or wrong parameters. Look $0 help"); }
  }
}

{ unless(-e $DB) {        # Is database file exist?
  open OUT, ">", $DB or die "I can't open file $DB: $!"; 
  close OUT; } }
&main;
