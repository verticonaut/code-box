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
  1. The code value is used for I18n translation (e.g. nationality_code: 'GER' -> nationality: 'Germany' (when locale is 'en')).
  1. The code value is used to lookup a specific code object (code objects are not persisten - at least not AR persisted).
  1. The code value is a foreign key on a specific AR code object (code objects are persisted).

#### Lookup through I18n

Example

    class Person
      iclude CodeBox::CodeAttribute

      attr_accessor :nationality_code
    end

The include will create the following method in Person:

  `#nationality` Will return the nationality looked up through I18n on key: `activerecord.values.person.nationality_code.de: Germany`, where de would 'de' the nationality code (Note: The 'activerecord' keyelement is named to accroding AR localization).



#### Lookup through code object

Example

    class Person
      iclude CodeBox::CodeAttribute

      attr_accessor :nationality_code

      code_attribute :nationality, :lookup_type => :lookup
    end

    class Code::Nationality
      attr_accessor :code, :name

      def self.lookup(code)
        return the correct Code::Nationality for the passed code
      end
    end

The include will create the following method in Person:

  `#nationality` Will return the nationality looked through lookup on the associated code object.



#### Lookup through associated AR Code Object

The code value is interpreted as a foreign key on an associated AR Code object.

    class Person < ActiveRecord::Base
      iclude CodeBox::CodeAttribute

      code_attribute :nationality, :lookup_type => :activerecord
    end

    class Code::Nationality < ActiveRecord::Base
      # has attribute 'code' of type string
    end

The include and code specification will create the following methods in Person:

  * `#nationality` Will return the nationality looked through AR association on the associated code object - implemented through an AR association

      belongs_to :nationality, :class_name => 'Codes::Nationality', :foreign_key => :nationality_code, :primary_key => :code



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
