require 'memor'

describe Memor do
  class Foo
    include Memor

    attr_reader :slows

    def initialize
      @slows = 0
    end

    def no_arg
      memor __callee__ do
        slow_method
      end
    end

    def with_args1(a, b)
      memor __callee__, a, b do
        slow_method
      end
    end

    def with_args2(*args)
      memor __callee__, args do
        slow_method
      end
    end

    def query?
      memor __callee__ do
        slow_method
      end
    end

    def bang!
      memor __callee__ do
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

  it 'fix arguments' do
    foo.with_args1(1, 2).should == 'slow'
    foo.with_args1(1, 2).should == 'slow'

    foo.slows.should == 1
  end

  it 'splat arguments' do
    foo.with_args2('bar').should == 'slow'
    foo.with_args2('bar').should == 'slow'

    foo.slows.should == 1
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
end
