module EpubForge
  class Project
    include Configurator
    
    SETTINGS_FOLDER = "settings"
    CONFIG_FILE_NAME = "config.rb"
    PROJECT_ACTIONS_DIRECTORY = "actions"

    attr_reader :target_dir, :config_file, :config, :book_dir,
                :notes_dir, :project_basename, :filename_for_epub_book, 
                :filename_for_mobi_book, :filename_for_epub_notes, 
                :filename_for_mobi_notes, :actions_dir
                
    def initialize( target_dir )
      @target_dir = Utils::FilePath.new( target_dir ).expand
      
      load_configuration
      @config = @config_file.exist? ? YAML.load( @config_file.read ) : {}
    
      @notes_dir = @config["notes_dir"] || @target_dir.join( "notes" )
      @book_dir  = @config["book_dir"]  || @target_dir.join( "book" )
    
      @project_basename = default_project_basename
      @filename_for_epub_book = @target_dir.join( "#{@config["filename"]}.epub" )
      @filename_for_mobi_book = @target_dir.join( "#{@config["filename"]}.mobi" )
      @filename_for_epub_notes = @target_dir.join( "#{@config["filename"]}.notes.epub" )
      @filename_for_mobi_notes = @target_dir.join( "#{@config["filename"]}.notes.mobi" )
    end 
    
    # shorthand string that 'names' the project, like the_vampire_of_the_leeky_hills.  Variable-ish, used within filenames
    def default_project_basename
      @config["filename"] || File.split( @target_dir ).last.gsub( /\.epubforge$/ , "" )
    end

    def self.is_project_dir?( dir )
      return false if dir.nil?
      dir = Utils::FilePath.new( dir )
      dir.exist? && dir.join( SETTINGS_FOLDER, CONFIG_FILE_NAME ).exist? && dir.join( "book" ).directory?
    end
    
    def project_exists?
      @target_dir.exist? && config_file.exist?
    end
    
    def settings_folder(*args)
      @target_dir.join( SETTINGS_FOLDER ).join( *args )
    end
    
    def config_file
      settings_folder( CONFIG_FILE_NAME )
    end
    
    def actions_directory
      settings_folder( ACTIONS_DIRECTORY )
    end
    
    def load_configuration
      EpubForge::Utils::Settings.new( self, config_file )
    end
  end
end