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
    foo.no_arg.should == 'slow'
    foo.no_arg.should == 'slow'

    foo.slows.should == 1
  end

  it 'normal arguments' do
    foo.with_args1(1, 2).should == [1, 2]
    foo.with_args1(1, 2).should == [1, 2]
    foo.with_args1(2, 2).should == [2, 2]
    foo.with_args1(2, 2).should == [2, 2]

    foo.slows.should == 2
  end

  it 'splat arguments' do
    foo.with_args2(1).should == [1]
    foo.with_args2(1).should == [1]
    foo.with_args2(2).should == [2]
    foo.with_args2(2).should == [2]

    foo.slows.should == 2
  end

  it 'normal arguments and splat arguments' do
    foo.with_args3(1, 4).should == [1, 4]
    foo.with_args3(1, 4).should == [1, 4]
    foo.with_args3(1, 5).should == [1, 5]
    foo.with_args3(1, 5).should == [1, 5]

    foo.slows.should == 2
  end

  it 'default value args' do
    foo.with_args4(1).should == 1
    foo.with_args4(1).should == 1
    foo.with_args4(2).should == 2
    foo.with_args4(2).should == 2

    foo.slows.should == 2
  end

  it '! in method name' do
    foo.bang!.should == 'slow'
    foo.bang!.should == 'slow'

    foo.slows.should == 1
  end

  it '? in method name' do
    foo.query?.should == 'slow'
    foo.query?.should == 'slow'

    foo.slows.should == 1
  end

  it 'class methods' do
    Bar.bar
    Bar.bar.should == 'bar'

    Bar.slows.should == 1
  end

  it 'explicit depend value' do
    foo.explicit_depend_value.should == nil
    foo.explicit_depend_value.should == nil

    foo.slows.should == 1

    foo.the_explicit_depend_value = 3

    foo.explicit_depend_value.should == 3
    foo.explicit_depend_value.should == 3

    foo.slows.should == 2
  end
end
