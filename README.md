# CodeBox::CodeAttribute

Lets you define attributes as codes, instead keys (ids). For simple option storage saving a string code is often more simple an conveniant the storing an artificial id-key referencing a special code object.
CodeBox lets you access define codes as strings and access the associated code objects in various ways.

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
  1. The code value is used for I18n translation (e.g. nationality_code: 'SUI' -> nationality: 'Switzerland' (when locale is 'en')).
  1. The code value is used to lookup a specific code object that implements `.for_code`.
  1. The code value is a foreign key on a specific ActiveRecord code object.

#### Lookup through I18n

Example

    class Person
      iclude CodeBox::CodeAttribute

      attr_accessor  :nationality_code

      code_attribute :nationality
    end

The include will create the following method in Person:

  `#nationality` Will return the nationality text for the value stored in `nationality_code`. For the code 'SUI' the I18n key would look like: `model.values.person.nationality_code.SUI` (Note: The key is build like the stndard I18n keys for activerecord classes or attribute - except for the name element 'model' instead 'activerecord').



#### Lookup through code object

Example

    class Person
      iclude CodeBox::CodeAttribute

      attr_accessor :nationality_code

      code_attribute :nationality, :lookup_type => :lookup
    end

    class Code::Nationality
      attr_accessor :code, :name

      def self.for_code(code)
        # return the correct Code::Nationality for the passed code
      end
    end


The include will create the following method in Person:

  `#nationality` Will return the nationality object looked up using the method '.for_code' on the code class.
  Translation then can be done within this class with the first method described above.



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

  `#nationality` - will return the nationality looked up through AR association on the associated code object - implemented through below AR association:

      belongs_to :nationality,
        :class_name  => 'Codes::Nationality',
        :foreign_key => :nationality_code,
        :primary_key => :code



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
