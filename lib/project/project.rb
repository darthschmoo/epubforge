module EpubForge
  class Project
    SETTINGS_FOLDER = "settings"
    CONFIG_FILE_NAME = "config.rb"
    PROJECT_ACTIONS_DIRECTORY = "actions"

    attr_reader :target_dir, :config_file, :config, :book_dir,
                :notes_dir, :project_basename, :filename_for_epub_book, 
                :filename_for_mobi_book, :filename_for_epub_notes, 
                :filename_for_mobi_notes, :actions_dir
                
    def initialize( target_dir )
      @target_dir = FunWith::Files::FilePath.new( target_dir ).expand
      
      load_configuration

      @notes_dir = config.notes_dir || @target_dir.join( "notes" )
      @book_dir  = config.book_dir  || @target_dir.join( "book" )
    
      @project_basename = default_project_basename
      @filename_for_epub_book = @target_dir.join( "#{default_project_basename}.epub" )
      @filename_for_mobi_book = @target_dir.join( "#{default_project_basename}.mobi" )
      @filename_for_epub_notes = @target_dir.join( "#{default_project_basename}.notes.epub" )
      @filename_for_mobi_notes = @target_dir.join( "#{default_project_basename}.notes.mobi" )
    end 
    
    # shorthand string that 'names' the project, like the_vampire_of_the_leeky_hills.  Variable-ish, used within filenames
    def default_project_basename
      config.filename || @target_dir.basename.to_s.gsub( /\.epubforge$/ , '' )
    end

    # TODO: should test be more definitive?
    def self.is_project_dir?( dir )
      dir = dir && (dir.is_a?(String) || dir.is_a?(FunWith::Files::FilePath)) ? dir.fwf_filepath : nil
      return false if dir.nil?
      
      ( dir.exist? && dir.join( SETTINGS_FOLDER, CONFIG_FILE_NAME ).exist? && dir.join( "book" ).directory? ) ? dir : false
    end
    
    def project_exists?
      @target_dir.exist? && config_file.exist?
    end
    
    def settings_folder(*args)
      @settings_folder ||= @target_dir.join( SETTINGS_FOLDER )
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
    
    def load_configuration
      self.install_fwc_config_from_file( config_file )
    end
  end
end