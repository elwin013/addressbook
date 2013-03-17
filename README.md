adressbook
=============

A simple (or not) address book with records stored in text file. Written in Perl.

Required Perl modules
---------------------
  * Switch
  * Term::ANSIColor
  * File::Spec

Help
----

Syntax: ./addressbook action [ID/KEYWORD]

  * help - view this help
  * list - list all records
  * view ID - show record with specified ID
  * add - add new record (interactive)
  * edit ID - edit record with specified ID (interactive)
  * del ID - delete record with specified ID
  * search KEYWORD - search a KEYWORD in database and show results
  

License
-------

Copyright (c) 2012, Kamil "elwin013" Banach

Permission to use, copy, modify, and/or distribute this software for any 
purpose with or without fee is hereby granted, provided that the above 
copyright notice and this permission notice appear in all copies. 

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
