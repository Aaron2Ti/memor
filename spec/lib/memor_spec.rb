require 'spec_helper'
require 'memor'

describe Memor do
  class Foo
    extend Memor
    include Memor

    @static_calls = 0

    def self.static_calls
      @static_calls
    end

    def self.static_fun
      memor binding do
        @static_calls += 1

        :static_fun
      end
    end

    def initialize
      @calls = 0
    end

    def no_args
      memor binding do
        @calls += 1

        :ok
      end
    end

    def arg1(a)
      memor binding do
        @calls += 1

        a
      end
    end

    def splat_args(*args)
      memor binding do
        @calls += 1

        args
      end
    end

    def default_arg(a = 1)
      memor binding do
        @calls += 1

        a
      end
    end

    def query?
      memor binding do
        @calls += 1

        :query
      end
    end

    def bang!
      memor binding do
        @calls += 1

        :bang
      end
    end

    def calls
      @calls
    end
  end

  let(:foo) { Foo.new }

  it 'no_args' do
    foo.no_args

    expect(foo.no_args).to eq :ok
    expect(foo.calls).to   eq 1
  end

  it 'arg1' do
    foo.arg1 1

    expect(foo.arg1 1).to eq 1
    expect(foo.arg1 2).to eq 2

    expect(foo.calls).to  eq 2
  end

  it 'splat arguments' do
    foo.splat_args(1)
    foo.splat_args(2)
    foo.splat_args(2)

    expect(foo.calls).to eq 2
  end

  it 'query suffix' do
    foo.query?
    foo.query?

    expect(foo.calls).to eq 1
  end

  it 'bang suffix' do
    foo.bang!
    foo.bang!

    expect(foo.calls).to eq 1
  end

  it 'default_arg' do
    foo.default_arg
    foo.default_arg 1
    foo.default_arg 2

    expect(foo.calls).to eq 2
  end

  it 'memoize static_fun' do
    Foo.static_fun
    Foo.static_fun

    expect(Foo.static_calls).to eq 1
  end

  class Bar
    include Memor

    def initialize(age)
      @age = age

      @calls = 0
    end
    attr_accessor :age

    def age_in_coming_year
      memor binding, :age do
        @calls += 1

        @age + 1
      end
    end

    def calls
      @calls
    end
  end

  it 'explicitly depend on instance states' do
    bar = Bar.new 21

    bar.age_in_coming_year
    bar.age_in_coming_year

    expect(bar.calls).to eq 1

    bar.age = 31

    bar.age_in_coming_year
    bar.age_in_coming_year

    expect(bar.calls).to eq 2
  end
end
