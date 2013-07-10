require 'memor/version'

module Memor
  class PrivateMemoizeInstance
    def initialize(the_caller, the_context_binding, explicit_dependents)
      @the_caller          = the_caller
      @the_context_binding = the_context_binding
      @explicit_dependents = explicit_dependents
    end

    def callee
      @the_context_binding.eval '__callee__'
    end

    def memor_name
     "@____memor_#{callee}".gsub('?', '_question_mark')
                           .gsub('!', '_bang')
    end

    def memor_method
      @the_caller.method callee
    end

    def memoize_wrap
      if memoize_lookup_key.empty?
        memoize_without_dependent { yield }

      else
        memoize_with_dependents { yield }
      end
    end

    def memoize_lookup_key
      args_values + explicit_dependents_values
    end

    def explicit_dependents_values
      @explicit_dependents.map do |ed_name|
        @the_context_binding.eval ed_name.to_s
      end
    end

    def args_values
      # parameters is like [[:req, :a], [:opt, :b], [:rest, :c], [:block, :d]]
      value_parameters = memor_method.parameters.map do |pp|
        if [:req, :rest, :opt].include? pp[0]
          pp[1]
        end
      end.compact.map do |arg_name|
        @the_context_binding.eval arg_name.to_s
      end
    end

    def memoize_without_dependent
      unless @the_caller.instance_variable_defined? memor_name
        @the_caller.instance_variable_set memor_name, yield
      end

      @the_caller.instance_variable_get memor_name
    end

    def memoize_with_dependents
      unless @the_caller.instance_variable_defined? memor_name
        @the_caller.instance_variable_set memor_name, {}
      end

      buckets = @the_caller.instance_variable_get memor_name

      unless buckets.has_key?(memoize_lookup_key)
        buckets[memoize_lookup_key] = yield
      end

      buckets[memoize_lookup_key]
    end

  end

private

  # Example
  #
  # class Foo
  #   include Memor
  #
  #   def foo(a, b)
  #     memor binding do
  #       # slow stuff
  #     end
  #   end
  #
  #   def bar(a, b)
  #     memor binding do
  #       # slow stuff
  #     end
  #   end
  # end
  #
  def memor(context_binding, *explicit_dependents)
    PrivateMemoizeInstance.new(self, context_binding, explicit_dependents)
                          .memoize_wrap { yield }
  end

end
