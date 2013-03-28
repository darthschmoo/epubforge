module Kernel
	def puts_nowhere( &block )
		puts_elsewhere( "/dev/null", &block )
	end

	def puts_elsewhere( dest, &block )
		@puts_nowhere_keep_old_stdout ||= []
	  @puts_nowhere_keep_old_stdout << $stdout 
	  if dest.is_a?(String)
  	  $stdout = File.open( dest, "w" )
  	else
  		$stdout = dest
  	end

	  $stdout.sync = true

	  yield

	  $stdout = @puts_nowhere_keep_old_stdout.pop 
	end
end