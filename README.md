# tact

A command line rolodex.

## Installation

  `$ gem install tact`

## Usage

```
  -v                                Current version
  -h                                Help

  add first last                    Adds new name
  add index -p type num             Adds contact number
  add index -e address              Adds contact email
  rm index                          Deletes contact
  rm index -p num_index             Deletes contact number
  rm index -e e_index               Deletes contact email
  edit index first last             Edits contact name
  edit index -p num_index type num  Edits contact number
  edit index -e e_index address     Edits contact email
  find <param>                      Search by name
  find -p <param>                   Search by number
  find -e <param>                   Search by email
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ollieshmollie/tact.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

