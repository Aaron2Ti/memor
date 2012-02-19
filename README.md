# Memor

## USAGE
This lib has one utility method called **memor** which takes *__callee__* as
first argument and all the host methods other arguments, see the following example:

``` ruby
  require 'memor'

  class Foo
    include Memor

    def slow_method1
      memor(__callee__) do
        # slow stuff
      end
    end

    def slow_method2(a, b)
      memor(__callee__, a, b) do
        # slow stuff
      end
    end

    def slow_method3(a, *args)
      memor(__callee__, a, args) do
        # slow stuff
      end
    end
  end
```

Tested in ruby 1.9.2
[![Build Status](https://secure.travis-ci.org/Aaron2Ti/memor.png)](http://travis-ci.org/Aaron2Ti/memor)
