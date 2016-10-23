# Dex
## A command line rolodex, version 1.2

Usage:
  -v                                Current version
  -h                                Help

  add first last type num           Adds new contact
  add -n first last                 Adds new name
  add -t index type num             Adds contact number
  add -e index address              Adds contact email
  delete index                      Deletes contact
  delete -t index num_index         Deletes contact number
  delete -e index e_index           Deletes contact email
  edit -n index first last          Edits contact name
  edit -t index num_index type num  Edits contact number
  edit -e index e_index address     Edits contact email
  find -n <param>                   Searches by name (DEFAULT)
  find -t <param>                   Searches by number
  find -e <param>                   Searches by email
  find -f <letter>                  Names by first name letter
  find -l <letter>                  Names by last name letter