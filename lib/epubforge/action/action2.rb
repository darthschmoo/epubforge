module EpubForge
  module Action
    class Action2
      get_and_set( :project, :args )
      get_and_set_boolean( :verbose )
      
      include FunWith::Patterns::Loader
      loader_pattern_configure( :bracketwise_lookup, 
                                :warn_on_key_change, 
                                { :verbose => true } )
      
      
      
      include Chatterbox
      
      def self.loader_pattern_load_item( file )
        begin
          file.fwf_filepath.load
        rescue Exception => e
          puts "Error loading #{file}: #{e.message}"
          for line in e.backtrace
            puts "\t#{line}"
          end
        end
        
        nil    # returning true will break loader
      end
      
      def self.define_action( keyword, &block )
        puts "defining action #{keyword}" if EpubForge.gem_test_mode?
        definition = ActionDefinition.new
        definition.keyword( keyword )
        definition.klass( self )
        
        yield definition if block_given?
        
        EpubForge::Action::Action2.loader_pattern_register_item( definition )
      end
      
      # # Instead, use these instead of destination_root.  Thor gets strings instead of
      # # filepaths, like it wants, and I get filepaths instead of strings, like I want.
      # def destination_root_filepath
      #   self.destination_root.fwf_filepath
      # end
      # 
      # def destination_root_filepath=(root)
      #   @destination_root_file
      #   self.destination_root = root.to_s
      # end
      attr_accessor :destination_root_filepath
      
      def executable_installed?( name )
        name = name.to_sym
        
        if @executables.nil?
          @executables = {}
          for exe, path in (EpubForge.config[:exe_paths] || {})
            @executables[exe] = path.fwf_filepath
          end
        end
        
        @executables[name] ||= begin
          _which = `which #{name}`.strip
          (_which.length == 0) ? false : _which.fwf_filepath
        end
          
        @executables[name]  
      end
      
      def requirements
        @requirements ||= []
      end
      
      def add_requirement( *args, &block )
        @requirements ||= []
        @requirements.push( [args, block] )
      end
      
      def requires_executable( ex, fail_msg )
        add_requirement( ex, fail_msg ) do
          executable_installed?( ex, fail_msg )
        end
      end
      
      def must_target_a_project( project_dir )
        add_requirement( project_dir ) do
          Project.is_project_dir?( project_dir )
        end
      end
      
      def git_installed?
        executable_installed?('git')
      end
      
      def ebook_convert_installed?
        executable_installed?('ebook-convert')
      end
      
      def project_already_gitted?
        @project.root_dir.join( ".git" ).directory?
      end
      
      def quit_with_error( msg, errno = -1 )
        STDERR.write( "\n#{msg}\n")
        exit( errno )
      end
    end
  end
end