require 'spec_helper'
require 'memor'

describe Memor do
  class Bar
    extend Memor
    @slows = 0

    def self.bar
      memor binding do
        @slows += 1

        'bar'
      end
    end

    def self.slows
      @slows
    end
  end

  class Foo
    include Memor

    attr_reader :slows
    attr_accessor :the_explicit_depend_value

    def initialize
      @slows = 0
    end

    def explicit_depend_value
      memor binding, :the_explicit_depend_value do
        slow_method

        the_explicit_depend_value
      end
    end

    def no_arg
      memor binding do
        slow_method
      end
    end

    def with_args1(a, b)
      memor binding do
        slow_method

        [a, b]
      end
    end

    def with_args2(*args)
      memor binding do
        slow_method

        args
      end
    end

    def with_args3(a, *args)
      memor binding do
        slow_method

        [a, args].flatten
      end
    end

    def with_args4(a = 1)
      memor binding do
        slow_method

        a
      end
    end

    def query?
      memor binding do
        slow_method
      end
    end

    def bang!
      memor binding do
        slow_method
      end
    end

    def slow_method
      @slows += 1

      'slow'
    end
  end

  let(:foo) { Foo.new }

  it 'no argument' do
    expect(foo.no_arg).to eq 'slow'
    expect(foo.no_arg).to eq 'slow'

    expect(foo.slows).to eq 1
  end

  it 'normal arguments' do
    expect(foo.with_args1(1, 2)).to eq [1, 2]
    expect(foo.with_args1(1, 2)).to eq [1, 2]
    expect(foo.with_args1(2, 2)).to eq [2, 2]
    expect(foo.with_args1(2, 2)).to eq [2, 2]

    expect(foo.slows).to eq 2
  end

  it 'splat arguments' do
    expect(foo.with_args2(1)).to eq [1]
    expect(foo.with_args2(1)).to eq [1]
    expect(foo.with_args2(2)).to eq [2]
    expect(foo.with_args2(2)).to eq [2]

    expect(foo.slows).to eq 2
  end

  it 'normal arguments and splat arguments' do
    expect(foo.with_args3(1, 4)).to eq [1, 4]
    expect(foo.with_args3(1, 4)).to eq [1, 4]
    expect(foo.with_args3(1, 5)).to eq [1, 5]
    expect(foo.with_args3(1, 5)).to eq [1, 5]

    expect(foo.slows).to eq 2
  end

  it 'default value args' do
    expect(foo.with_args4(1)).to eq 1
    expect(foo.with_args4(1)).to eq 1
    expect(foo.with_args4(2)).to eq 2
    expect(foo.with_args4(2)).to eq 2

    expect(foo.slows).to eq 2
  end

  it '! in method name' do
    expect(foo.bang!).to eq 'slow'
    expect(foo.bang!).to eq 'slow'

    expect(foo.slows).to eq 1
  end

  it '? in method name' do
    expect(foo.query?).to eq 'slow'
    expect(foo.query?).to eq 'slow'

    expect(foo.slows).to eq 1
  end

  it 'class methods' do
    Bar.bar
    expect(Bar.bar).to eq 'bar'

    expect(Bar.slows).to eq 1
  end

  it 'explicit depend value' do
    expect(foo.explicit_depend_value).to eq nil
    expect(foo.explicit_depend_value).to eq nil

    expect(foo.slows).to eq 1

    foo.the_explicit_depend_value = 3

    expect(foo.explicit_depend_value).to eq 3
    expect(foo.explicit_depend_value).to eq 3

    expect(foo.slows).to eq 2
  end
end
