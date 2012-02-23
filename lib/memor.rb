require 'memor/version'

module Memor

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
  def memor(context_binding)
    callee = context_binding.eval '__callee__'

    memor_name = "@_memor_#{callee}".gsub('?', '_question_mark')
                                    .gsub('!', '_bang')

    memor_method = method(callee)

    if memor_method.arity == 0 # no argument
      _memor_with_no_arg(memor_name) { yield }

    else
      # FIXME args may be insufficient
      args = _memor_args(memor_method, context_binding)

      _memor_with_args(memor_name, args) { yield }
    end
  end


  def _memor_args(memor_method, context_binding)
    arg_names = _memor_arg_names(memor_method)

    arg_names.map do |arg_name|
      context_binding.eval arg_name.to_s
    end
  end
  private :_memor_args

  def _memor_arg_names(memor_method)
    # parameters is like [[:req, :a], [:req, :b], [:rest, :c], [:block, :d]]
    value_parameters = memor_method.parameters.map do |pp|
      if pp[0] == :req or pp[0] == :rest
        pp[1]
      end
    end.compact
  end
  private :_memor_arg_names

  def _memor_with_no_arg(memor_name)
    unless instance_variable_defined? memor_name
      instance_variable_set memor_name, yield
    end

    instance_variable_get memor_name
  end
  private :_memor_with_no_arg

  def _memor_with_args(memor_name, args)
    unless instance_variable_defined? memor_name
      instance_variable_set memor_name, {}
    end

    memor = instance_variable_get memor_name
    key = [* args] # use the args array as the cache key

    unless memor.has_key?(key)
      memor[key] = yield
    end

    memor[key]
  end
  private :_memor_with_args

end
