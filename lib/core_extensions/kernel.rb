module Kernel
  # yields an alternate reality block where instance methods
  # are different from what they were.  At the end of the block
  # it resets the initial values of the instance variables.
  def with_locals locals = {}, &block
    old_local_vars = {}

    for k, v in locals
      var = :"@#{k}"
      old_local_vars[k] = instance_variable_get(var)
      instance_variable_set( var, v )
    end

    yield
  ensure      # make all as it once was
    for k, v in old_local_vars
      var = :"@#{k}"
      instance_variable_set( var, v )
    end
  end
  
end