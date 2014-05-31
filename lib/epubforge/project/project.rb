module EpubForge
  class Project
    SETTINGS_FOLDER = "settings"
    CONFIG_FILE_NAME = "config.rb"
    PROJECT_ACTIONS_DIRECTORY = "actions"

    attr_reader :root_dir, :config_file, :config, :book_dir,
                :notes_dir, :project_basename, :filename_for_book, 
                :filename_for_notes, :actions_dir
                
    def initialize( root_dir )
      @root_dir = FunWith::Files::FilePath.new( root_dir ).expand
      
      load_configuration

      @notes_dir = config.notes_dir || @root_dir.join( "notes" )
      @book_dir  = config.book_dir  || @root_dir.join( "book" )
    
      @project_basename = default_project_basename
      @filename_for_book = @root_dir.join( "#{default_project_basename}" )
      @filename_for_notes = @root_dir.join( "#{default_project_basename}.notes" )
    end 
    
    # shorthand string that 'names' the project, like the_vampire_of_the_leeky_hills.  Variable-ish, used within filenames
    def default_project_basename
      config.filename || @root_dir.basename.to_s.gsub( /\.epubforge$/ , '' )
    end

    # TODO: should test be more definitive?
    def self.is_project_dir?( dir )
      dir = dir && (dir.is_a?(String) || dir.is_a?(FunWith::Files::FilePath)) ? dir.fwf_filepath : nil
      return false if dir.nil?
      
      ( dir.exist? && dir.join( SETTINGS_FOLDER, CONFIG_FILE_NAME ).exist? && dir.join( "book" ).directory? ) ? dir : false
    end
    
    def project_exists?
      @root_dir.exist? && config_file.exist?
    end
    
    def settings_folder(*args)
      @settings_folder ||= @root_dir.join( SETTINGS_FOLDER )
      @settings_folder.join( *args )
    end
    
    def config_file
      settings_folder( CONFIG_FILE_NAME )
    end
    
    def actions_directory
      settings_folder( ACTIONS_DIRECTORY )
    end
    
    def chapters
      @book_dir.glob("chapter-????.*")
    end
    
    
    def pages( orderer = nil )
      case orderer
      when NilClass
        orderer = Utils::FileOrderer.new( self.config.pages.book || [] )
      when Utils::FileOrderer
        # pass
      when Array
        orderer = Utils::FileOrderer.new( orderer )
      else
        raise "Project#pages cannot take #{order.class} as an ordering object."
      end
      
      orderer.reorder( @book_dir.glob( ext: EpubForge::Builder::PAGE_FILE_EXTENSIONS ) )
    end
    
    def load_configuration
      puts "NO CONFIGURATION FILE DETECTED" unless config_file.file?
      
      begin
        self.install_fwc_config_from_file( config_file )
        true
      rescue SyntaxError => e
        puts "Syntax Error in project configuration file #{config_file}. Quitting.".paint(:red)
        puts e.message
        exit(-1)
      end
    end
  end
end