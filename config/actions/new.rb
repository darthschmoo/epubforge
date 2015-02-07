module EpubForge
  module Action
    class New < Action2
      define_action( "new" ) do |action|
        action.project_not_required
        
        action.help( "Create a brand new project." )
        action.usage( "<DIRECTORY_NAME>" )
        action.default( :verbose, false )

        action.execute do
          if @project.is_a?(Project)
            say_error "The directory given (#{@project.root_dir}) is already an EpubForge project.  Quitting."
            false
          elsif parse_args( *args )
            get_template_filepath_from_options
            configure_configuration( @opts[:answers] || {} )
            FunWith::Templates::TemplateEvaluator.write( @template_dir, self.destination_root_filepath, @template_options )
          else
            false
          end
        end
      end
        # 
        # 
        # 
        # 
        # 
        # src_dirs = src_entries.select{ |d| @template_dir.join(d).directory? }.uniq
        # 
        # for dir in src_dirs
        #   puts "creating dir #{dir}"
        #   empty_directory( self.destination_root_filepath.join( dir ) )
        # end
        # 
        # for entry in src_entries - src_dirs
        #   case entry.ext
        #   when "template"
        #     dst = self.destination_root_filepath.join( entry ).without_ext
        #     puts dst.inspect
        #     puts entry.inspect
        #     FunWith::Files::FilePath.template( entry, dst )
        #   when "sequence"
        #     @chapter_count ||= @opts[:answers][:chapter_count] if @opts[:answers]
        #     @chapter_count ||= ask_prettily("Setting up chapter files.\n  How many chapters will your book have (you can add more later)? >>> ").to_i
        # 
        #     1.upto( @chapter_count ) do |i|
        #       dst = self.destination_root_filepath.join( entry ).gsub( /%i%/, sprintf( "%04i", i) ).without_ext
        #       FunWith::Files::FilePath.template( entry, dst, {:i => i} )
        #     end
        #   when "form"
        #     configure_configuration( @opts[:answers] || {} )
        #     dst = self.destination_root_filepath.join( entry ).without_ext
        #     FunWith::Files::FilePath.template( entry, dst, @template_options )
        #     say_all_is_well( "Your configuration is all set up!" )
        #     say_instruction( "run 'epubforge gitify' to initialize the backup repository." )
        #   else
        #     copy_file( entry, self.destination_root_filepath.join( entry ) )
        #   end
        # end
      # end
      
      protected
      def configure_configuration(opts = {})
        say_instruction( "Don't think too hard about these next few questions.  You can always change your mind by editing settings/config" )

        opts[:book]    ||= {}
        opts[:book][:title]   ||= ask_prettily( "What is the name of your book?" )
        opts[:book][:author]  ||= ask_prettily( "What is the name of the author?" )
        opts[:license] ||= ask_from_menu( "What license do you want your book under?", [ "All Rights Reserved", 
                                                                                        "Creative Commons Non-Commercial, No Derivatives License", 
                                                                                        "Creative Commons Non-Commercial, Share-Alike License",
                                                                                        "GNU Free Documentation License",
                                                                                        "Public Domain",
                                                                                        "Other" ] )
        if opts[:license] == "Other"
          opts[:license] = ask_prettily( "Type in the license you wish to use : " )
        end
        
        opts[:chapter] ||= (1..(ask_prettily( "How many chapters?" ).to_i))
        
        @template_options = opts
        
        if git_installed?
          if opts[:use_git] || opts[:use_git].nil? && yes_prettily?( "Do you want to back up your project using git?" )
            configure_git( opts[:git] || {} )
          end
        else
          warn( "The program 'git' must be installed and locatable if you want epubforge to back up your project." )
        end
        
        configure_character
      end
      
      
      
      def configure_git( opts = {} )
        opts[:remote] = "Back up to a remote host."
        opts[:thumb]  = "Back up to an external or thumb drive."
        opts[:backup_type] ||= ask_from_menu( "Where would you like to back up your project to?", 
                                                                                 [ opts[:remote], 
                                                                                   opts[:thumb] ] )
                                                                 
        opts[:repo_id] ||= rand(16**32).to_s(16)
        
        if opts[:backup_type] == opts[:remote]
          opts[:host] ||= ask_prettily("Enter the name of the remote host : ")
          opts[:user] ||= ask_prettily( "Enter your user name", :default => ENV['USER'] )
          opts[:repo] ||= ask_prettily( "Enter the name of the folder on the remote host. A folder called #{backup_folder_name} will be created there : ")
        elsif opts[:backup_type] == opts[:thumb]
          opts[:repo] ||= ask_prettily("Enter the full path to the backup folder. A folder called #{backup_folder_name} will be created there: ")
        else
          say_error("I'm confused by the requested backup style <#{opts[:backup_type]}>.  Skipping git configuration.")
          opts = nil
          return false
        end
        
        # TODO: What if the target file system uses a different file separator?
        opts[:repo] = opts[:repo].fwf_filepath.join( backup_folder_name ) if opts[:repo].is_a?(String)
        @template_options[:git] = opts
        true
      end
      
      def configure_character
        @template_options[:character] = {
          :name          => "Mr. Example Protagonist",
          :name_for_file => "mister_example_protagonist",
          :description   => "Tall, red hair, angry complexion, indifferent to fashion and hygiene.",
          :summary       => "Example once drove a man to drink, because the guy's liver once killed his dad.",
          :age           => 23
        }
      end
      
      def backup_folder_name
        (@template_options[:book][:title] || "").epf_underscorize + ".epubforge.git"
      end
      
      # Expects the following arguments: 1:<project directory (shouldn't exist)>, 2: options hash.
      # Options hash includes: 
      def parse_args( *args )
        @opts = args.last.is_a?(Hash) ? args.pop : {}
        project_root = args.shift
        
        case project_root
        when NilClass
          say_error "No destination directory given."
          return false
        when Project
          say_error "You seem to be creating a project within a project.  Cut it out."
          return false
        end
        
        self.destination_root_filepath = project_root.fwf_filepath
        
        if self.destination_root_filepath.exist? && 
            (!(self.destination_root_filepath.empty?) || !(self.destination_root_filepath.directory?))
          say_error "This action must create a new directory or act upon an empty directory.  Quitting."
          return false
        end
        
        true
      end
      
      # TODO: Shouldn't the user settings / project settings also be searchable?
      # Wouldn't preference be given to project, then user settings?
      def get_template_filepath_from_options
        @template_to_use = (@opts[:template] || "project").fwf_filepath  # TODO: should turn into an option 
        if @template_to_use.absolute?
          @template_dir = @template_to_use
        else
          @template_dir = EpubForge.root.join( "templates", @template_to_use )
        end
        
        
      end
    end
  end
end