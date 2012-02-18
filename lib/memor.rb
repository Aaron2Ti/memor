require "memor/version"

module Memor

  # Example
  #
  # class Foo
  #   include Memor
  #
  #   def slow(a, b)
  #     memor(__callee__, a, b) do
  #       # slow stuff
  #     end
  #   end
  # end
  #
  def memor(callee, *args)
    memor_name = "@_memor_#{callee}".gsub('?', '_question_mark')
                                    .gsub('!', '_bang')

    if args.nil? # methods without arguments
      unless instance_variable_defined? memor_name
        instance_variable_set memor_name, yield
      end

      return instance_variable_get memor_name

    else
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
  end

end
