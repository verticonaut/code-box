[![Build Status](https://travis-ci.org/verticonaut/code-box.png)](https://travis-ci.org/verticonaut/code-box)
[![Code Climate](https://codeclimate.com/github/verticonaut/code-box.png)](https://codeclimate.com/github/verticonaut/code-box)

# Notes

If you re using ActiveRecord ~> 4.0.0 use the version ~> 0.6  
If you re using ActiveRecord ~> 3.0 use the version ~> 0.5.0

# CodeBox::CodeAttribute

Lets you define attributes as codes, instead keys (ids). For simple option storage saving a string code is often more simple an conveniant the storing an artificial id-key referencing a special code object.

CodeBox:

* lets you define code attributes
* provides translation of this codes __or__
* provides access to associated code objects (see below) in various ways
* __and__ furthermore enables an easy way to define code objects



## Installation

Add this line to your application's Gemfile:

    gem 'code-box'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install code-box



## Sample Usages

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
      include CodeBox::CodeAttribute

      attr_accessor  :nationality_code

      code_attribute :nationality
    end

The include will create the following methods in Person:

  `#nationality` Will return the nationality text for the value stored in `nationality_code`. For the code 'SUI' the I18n key would look like: `activerecord.values.person.nationality_code.SUI` (Note: The key is build like the standard I18n keys for activerecord classes or attribute by default. Since I dislike the `activerecord` naming and prefer `model` I made this configurable - see below).

  `.translate_nationality_code` Translates a code or an array of codes returning the translated code
  or an array of translated codes. If passing the option `:build => :zip` the method returns an array
  of arrays with translation and code which can be used to build html options.


#### Lookup through code object

Example

    class Person
      include CodeBox::CodeAttribute

      attr_accessor :nationality_code

      code_attribute :nationality, :lookup_type => :lookup
    end

    # Note: Below class is a plain sample implementation. Code objects can be built easier with
    #       'ActsAsCode' include (see below)
    class Code::Nationality
      attr_accessor :code, :name

      def self.for_code(code)
        # return the correct Code::Nationality for the passed code
      end
    end


The include will create the following method in Person:

  `#nationality` Will return the nationality object looked up using the method '.for_code' on the code class.
  Translation then can be done within this class with the first method described above ('acts_as_code' facilitates this as well).



#### Lookup through associated AR Code Object

The code value is interpreted as a foreign key on an associated AR Code object.

    class Person < ActiveRecord::Base
      include CodeBox::CodeAttribute

      code_attribute :nationality, :lookup_type => :associated
    end

    # Note: Below class is a plain sample implementation. Code objects can be built easier with
    #       'ActsAsCode' include (see below)
    class Code::Nationality < ActiveRecord::Base
      # has attribute 'code' of type string
    end

The include and code specification will create the following methods in Person:

  `#nationality` - will return the nationality looked up through AR association on the associated code object - implemented through below AR association:

      belongs_to :nationality,
        :class_name  => 'Codes::Nationality',
        :foreign_key => :nationality_code,
        :primary_key => :code

  Above options can be overwritten in the 'code_attribute' option.



### Defining code classes (acts_as_code)

Above described code_attributes can reference code objects. Code objects can be defined using 

    acts_as_code(*codes, options)

Options are:

  * `:code_attribute => :code`  
     Name of the attribute holding the code (default 'code').
  * `:sti => false` 
    If `true` the uniqueness validation is scoped by the attribute `type` (default false).
  * `:uniqueness_case_sensitive => true`  
    If `true` the the uniqueness validation is case sensitive (default true).
  * `:position_attr => :position`  
    If present, the order when fetching the codes is done with this expression (default scope - means - if you want to omit the order used `unscoped` on any AR operation).

  All options except `:code_attribute` are used __only__ for ActiveRecord models.

If `*codes` are provided the following code constants will be defined as shown in the example below.  

__IMPORTANT__ Code object constants will only be created when the code object is not an ActiveRecord model!

    class Gender
      include CodeBox::ActsAsCode['male', 'female'] # Code attribute name will be 'code'
      # Above is a shortcut for...
      # include CodeBox::ActsAsCode
      # acts_as_code('male', 'female') # Code attribute name will be 'code'


      # Given codes 'male' and 'female' the following constants will be defined:
      #
      # module Codes
      #   Male   = 'male'
      #   Female = 'female'
      #   All    = [Male, Female]
      # end
      #
      # Below constants are only currently only defined if the hosting class not an ActiveRecod model (as in this sample).
      # Male   = Gender.new('male')
      # Female = Gender.new('female')
      # All    = [Male, Female]
      #
    end


If `*codes` are provided - in addition the following test_methods are defined:

    class Gender
      include CodeBox::ActsAsCode['male', 'female'] # Code attribute name will be 'code'
      # Above is a shortcut for...
      # include CodeBox::ActsAsCode
      # acts_as_code('male', 'female') # Code attribute name will be 'code'


      # Given codes 'male' and 'female' the following constants will be defined:
      # ... al the stuff above
      # 
      # def male?
      #   code == Codes::Male
      # end
      # 
      # def female?
      #   code == Codes::Female
      # end
      # 
    end

  Pass the option `define_test_methods: false` if you don't want to have test-methods generated.
  If you prefer the all test-methods prefixed with e.g. `is_` so the methods above look like `is_male?` then you can configure this 
  globaly by defining `CodeBox.test_method_prefix='is_'`. 



In addition `acts_as_code` defines the following methods:

  * `.for_code(code)`  
    Answers the code object for the given code (fetched from cache)

  * `#translated_code(locale=I18n.locale, *other_locale_options)`  
    Translates the code stored in `code`

  * `.translate_code(codes_and_options)`  
    Translates a single code if `code` is a code, an array of codes of `code` is an array.
    If code is an array the option :build => :zip can be used to build a select option capable array (e.g `[['Switzerland', 'SUI'],['Germany', 'GER'],['Denmark', 'DEN']]`)

  * `.build_select_options(codes_and_options)`  
    Build an options array from the passed codes (all codes if no codes are passed). Add an empty option at the beginning if the option `:include_empty` is passed. If `:include_empty` is…

    * `true`, then options label is derived from the I18n tranlsation of the key defined in CodeBox.i18n_empty_options_key (default is `shared.options.pls_select` - you can change this default). The value of the option is `nil` by default.
    * `false` then no empty option is defined (default)
    * a String then the string is used as label. The value of the option is `nil` by default.
    * a String starting with `i18n.` the the string is considered as a tranlation key (without the `i18n.` part). Value is nil by default.
    * is a Hash then the value is take from the Hashs value for key `:value` (nil if not present), and the label is taken from the value of key `:label` (default CodeBox.i18n_empty_option_key). If a String is present it is interpreted as a plain label or I18n key as described above.

    ``Examples

    .build_select_options(include_empty: true)

    is same as …

    .build_select_options(include_empty: {})    

    is same as …

    .build_select_options(include_empty: {label: nil, value: nil})    

    is same as …

    .build_select_options(include_empty: {label: '<your default key in CodeBox.i18n_empty_options_key>', value: nil})    

  * `.clear_code_cache`  
    Clears the cache so its build up again lazy when needed form all codes.

  * Passing 


  __Note:__ The code name can be configures using the `:code_attribute` option.
  `:code_attribute => :iso_code` leads to methods like `#translate_iso_code` etc.


#### Plain old ruby object codes (:poro)

Assuming we have a simple ruby class with default code attribute 'code' we can defined such a class like:

    class Codes::MySpecificCode
      include CodeBox::ActsAsCode[]
      # Above is actually a shortcut for:
      #   include CodeBox::ActsAsCode
      #   acts_as_code

      # Above include creates the following:
      #
      # attr_accessor :code
      #
      # def initialize(code)
      #  @code = code
      # end
      #
      # def self.all
      #   raise "Sublass responsibility. You should implement '.all' returning all codes"
      # end

      # @return [Array] List if all code objects (instances of this) - is implemented when codes are defined.
      def self.all
        raise 'Class responsibility - implement method .all returning all code models.'
      end

    end


#### ActiveRecod code objects (:active_record)

Assuming we have an ActiveRecod code class with `code_attribute :code` we can defined such a class like

    class Codes::MySpecificCode < ActiveRecord::Base
      include CodeBox::ActsAsCode[]
      # Above is actually a shortcut for:
      #   include CodeBox::ActsAsCode
      #   acts_as_code

      # Above include creates the following:
      #
      # validates_presence_of   :code
      # validates_uniqueness_of :code
      #
      # default_scope order('code')

    end



### Examples
  TO BE DONE…

## Changelog

### Version 0.5.1
* Adding testing methods for codes objects. E.g. Code-Object with code 'my_code' get method `#codeObjectInstance.my_code?` defined.
* Method `.build_select_options` has been changed so you can pass in more flexible empty option configuration (see Readme).
* Ugrade of Rails 4 Version pending…

### Version 0.6.0
* Moving to activerecord 4.0.

### Version 0.5.0
* Change constant definition. Create code constants in a Codes module so the can be included in other places - an document it.
* Remove option `:model_type. The option is obsolte and can be derived from the including module.

### Version 0.4.*
* Define constant whens defining codes.

### Version 0.3.*
* Need to scan the logs…

## Contributing

1. Fork it!
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
