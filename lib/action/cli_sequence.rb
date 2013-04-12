module EpubForge
  module Action
    class CliSequence
      def initialize
        @defaults = {}
        @local_dir
        @commands = []
        @completed = []
      end
      
      def default( k, v )
        if k == :remote
          @remote = v
        else
          @defaults[k] = v
        end
      end
      
      def add_local_command( command, undo = nil, opts = {} )
        add_command( command, undo, opts )
      end
      
      def add_remote_command( command, undo = nil, opts = {} )
        opts[:remote] ||= @remote         # the default username/host can be overridden by sending a different opts[:remote]
        add_command( command, undo, opts)
      end
      
      def execute
        @failed = false
        while (cmd = @commands.shift) && (@failed == false)
          @failed = true unless cmd.execute.success?
          @completed.push( cmd )
        end
        
        undo unless @failed == false
        !@failed
      end
      
      def undo
        while cmd = @completed.pop
          result = cmd.undo
          @commands.unshift( cmd )
        end
      end
      
      def add_command( command, undo = "", opts = {} )
        for default, setting in @defaults
          opts[default] ||= setting
        end
        
        @commands.push( CliCommand.new(command, undo, opts) )
      end
    end
  end
end