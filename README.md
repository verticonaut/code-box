# Code::Attr

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'code-box'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install code-box

## Usage

### Specifying attributes as codes

There are cases you want to store 'named codes' instead artificial keys.
Codes make sense for stable references and better readability of the raw data.

There are several options to specify an attribute as a code:
1. Attribute is a code. There is no associated object involved, but simple I18n translation of the code
2. Attribute is a code. There exists a code object that is looked up on access.
2. Attribute is a code. There exists an AR code object that is looked up through AR association.

#### Lookup through I18n

Example
class Person
  iclude CodeBox::CodeAttribute

  attr_accessor :nationality_code
end

The include will create the following methods in Person:

  #nationality Will return the nationality looked up through I18n on key: 'activerecord.values.person.nationality_code.de: Germany', where de would 'de' the nationality code.



#### Lookup through code object

Example
class Person
  iclude CodeBox::CodeAttribute

  attr_accessor :nationality_code, :lookup_type => :lookup
end

class Code::Nationality
  attr_accessor :code, :name

  def lookup(code)
    return the correct Code::Nationality for the passed code
  end
end

The include will create the following methods in Person:

  #nationality Will return the nationality looked through lookup on the associated code object.


#### Lookup through associated AR Code Object
to be completed ...


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
