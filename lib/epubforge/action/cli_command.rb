module EpubForge
  module Action
    class CliCommand
      # undo is an action that would be expected to reverse the consequences of this
      # action.  You can do without it if the action can't fail, if it has no real
      # consequences, or if a prior action, when undone, will wipe out those consequences.
      # For example, if an earlier command created the directory that the current command
      # is writing a file to, the earlier command would be expected to delete the directory.
      def initialize( command, undo = nil, opts = {} )
        @command = command
        @undo = undo
        @opts = opts
        @remote = opts[:remote]   # Is this going to be executed here, or on a different server?  Usually in the form "username@host"
        @verbose = opts[:verbose]
        @local_dir = opts[:local_dir]     # the local directory to cd into before executing the command
        @remote_dir = opts[:remote_dir]   # the remote directory to cd into before executing the command
      end
      
      def execute( cmd = :cmd )
        @remote ? remote_exec( cmd ) : local_exec( cmd )
      end
      
      def undo
        execute( :undo )
      end
      
      protected
      def local_exec( cmd )
        cmd = (cmd == :undo ? @undo : @command)
        return pseudo_success if cmd.fwf_blank?

        execute_locally = @local_dir ? "cd #{@local_dir} && " : ""
        
        @msg = "attempting to run locally:  #{cmd}"
        `#{execute_locally}#{cmd}`
        print_result
        $?  
      end
      
      def remote_exec( cmd )
        cmd = (cmd == :undo ? @undo : @command)
        return pseudo_success if cmd.fwf_blank?

        execute_remotely = (@remote_dir ? "cd #{@remote_dir} && " : "") + cmd

        @msg = "attempting to run remotely (#{@remote}):  #{execute_remotely}"
        `ssh #{@remote} "#{execute_remotely}"`
        print_result
        $?
      end
      
      def print_result
        puts "#{$?.success? ? 'SUCCESS' : 'FAIL'}: #{@msg}" if @verbose
      end
      
      def pseudo_success
        unless @pseudo_success_object
          @pseudo_success_object = Object.new
          m = Module.new do
            def success?
              true
            end
          end
        
          @pseudo_success_object.extend( m )
        end
        
        @pseudo_success_object
      end
    end
  end
end