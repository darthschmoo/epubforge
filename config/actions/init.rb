module EpubForge
  module Action
    class Init < ThorAction
      keywords  :init, :initialize, :new
      project_not_required
      
      desc("do:init", "create a new epubforge project")
      def do( project, *args )
        unless project.nil? 
          say_error "Project already exists.  Quitting."
          return false
        end
        
        return false unless parse_args( *args )
        
        @template_dir = EpubForge.root.join( "templates", @template_to_use )
        src_entries = @template_dir.glob( "**", "*" ).map{ |entry|
          entry.relative_to( @template_dir )
        }
        
        self.source_paths.push( @template_dir )
        src_dirs = src_entries.select{ |d| @template_dir.join(d).directory? }.uniq
        
        for dir in src_dirs
          empty_directory( self.destination_root_filepath.join( dir ) )
        end
        
        for entry in src_entries - src_dirs
          case entry.ext
          when "template"
            dst = self.destination_root_filepath.join( entry ).without_ext
            template( entry, dst )
          when "sequence"
            @chapter_count ||= @opts[:answers][:chapter_count] if @opts[:answers]
            @chapter_count ||= ask_prettily("Setting up chapter files.\n  How many chapters will your book have (you can add more later)? >>> ").to_i
        
            1.upto( @chapter_count ) do |i|
              @i = i
              dst = self.destination_root_filepath.join( entry ).gsub( /%i%/, sprintf( "%04i", @i) ).without_ext
              template( entry, dst )
            end
          when "form"
            configure_configuration( @opts[:answers] || {} )
            dst = self.destination_root_filepath.join( entry ).without_ext
            template( entry, dst, @template_options )
            say_all_is_well( "Your configuration is all set up!" )
            say_instruction( "run 'epubforge gitify' to initialize the backup repository." )
          else
            copy_file( entry, self.destination_root_filepath.join( entry ) )
          end
        end
      end
      
      protected
      def configure_configuration(opts = {})
        say_instruction( "Don't think too hard about these next few questions.  You can always change your mind by editing settings/config" )
        
        opts[:title] ||= ask_prettily("What is the name of your book?")
        opts[:author] ||= ask_prettily( "What is the name of the author?" )
        opts[:license] ||= ask_from_menu "What license do you want your book under?", [ "All Rights Reserved", 
                                                                                     "Creative Commons Non-Commercial, No Derivatives License", 
                                                                                     "Creative Commons Non-Commercial, Share-Alike License",
                                                                                     "GNU Free Documentation License",
                                                                                     "Public Domain",
                                                                                     "Other" ]
        if opts[:license] == "Other"
          opts[:license] = ask_prettily( "Type in the license you wish to use : " )
        end
        
        @template_options = opts
        
        if git_installed?
          if opts[:use_git] || opts[:use_git].nil? && yes_prettily?( "Do you want to back up your project using git?" )
            configure_git( opts[:git] || {} )
          end
        else
          say_in_warning("The program 'git' must be installed and locatable if you want epubforge to back up your project.")
        end
      end
      
      
      
      def configure_git( opts = {})
        opts[:remote] = "Back up to a remote host."
        opts[:thumb]  = "Back up to an external or thumb drive."
        opts[:backup_type] ||= ask_from_menu( "Where would you like to back up your project to?", 
                                                                                 [ opts[:remote], 
                                                                                   opts[:thumb] ] )
                                                                 
        opts[:repo_id] ||= rand(16**32).to_s(16)
        
        if opts[:backup_type] == opts[:remote]
          opts[:host] ||= ask_prettily("Enter the name of the remote host : ")
          opts[:user] ||= ask_prettily("Enter your user name : ")
          opts[:repo] ||= ask_prettily("Enter the name of the folder on the remote host. A folder called #{backup_folder_name} will be created there : ")
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
      
      def backup_folder_name
        (@template_options[:title] || "").epf_underscorize + ".epubforge.git"
      end
      
      def parse_args( *args )
        @opts = args.last.is_a?(Hash) ? args.pop : {}
        root = args.shift
        
        if root.nil?
          say_error "No destination directory given."
          return false
        end

        self.destination_root_filepath = root.fwf_filepath
        debugger if self.destination_root_filepath != root.fwf_filepath.expand
        
        if self.destination_root_filepath.exist? && 
            (!(self.destination_root_filepath.empty?) || !(self.destination_root_filepath.directory?))
          say_error "This action must create a new directory or act upon an empty directory.  Quitting."
          return false
        end
        
        @template_to_use = "default"
        true
      end
    end
  end
end