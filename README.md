# tact

A command line rolodex.

## Installation

  `$ gem install tact`

## Usage

```     
  -v                                    Current version
  -h                                    Help
  -s                                    Sync Google contacts

  <param>                               Search by name
  -p <param>                            Search by number
  -e <param>                            Search by email
  -n <first> <last>                     Adds new name
  -np <index> <type> <num>              Adds contact number
  -ne <index> <address>                 Adds contact email
  -d <index>                            Deletes contact
  -dp <index> <num_index>               Deletes contact number
  -de <index> <e_index>                 Deletes contact email
  -u <index> <first> <last>             Edits contact name
  -up <index> <num_index> <type> <num>  Edits contact number
  -ue <index> <e_index> <address>       Edits contact email
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/olishmollie/tact.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

