# Memor

## USAGE
This lib has one utility method called **memor** which takes *binding* as an
 argument, see the following example:

``` ruby
  require 'memor'

  class Foo
    include Memor

    attr_accessor :age

    def slow_method1
      memor binding do
        # slow stuff
      end
    end

    def slow_method2(a, b)
      memor binding do
        # slow stuff
      end
    end

    def slow_method3(a, *args)
      memor binding do
        # slow stuff
      end
    end

    def double_age
      memor binding, :age do
        age * 2
      end
    end

  end

  foo = Foo.new

  foo.age = 2
  foo.double_age # 4

  foo.age = 3
  foo.double_age # 6
```

Tested in ruby 1.9.2, 1.9.3 and 2.0.0
[![Build Status](https://secure.travis-ci.org/Aaron2Ti/memor.png)](http://travis-ci.org/Aaron2Ti/memor)
