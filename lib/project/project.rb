module EpubForge
  TEMPLATE_DIR = EpubForge.root.join( "templates" )
  RECIPE_FILE_NAME = "recipe.epubforge"
  
  class Project
    attr_reader :target_dir, :recipe_file, :config, :book_dir,
                :notes_dir, :project_basename, :filename_for_epub_book, 
                :filename_for_mobi_book, :filename_for_epub_notes, 
                :filename_for_mobi_notes, :actions_dir
                
    def initialize( target_dir )
      @target_dir = target_dir.epf.blank? ? Utils::FilePath.new( Dir.pwd ) : Utils::FilePath.new( target_dir )
      @target_dir = target_dir.epf_filepath.expand
      
      @recipe_file = @target_dir.join( RECIPE_FILE_NAME )

      @config = @recipe_file.exist? ? YAML.load( @recipe_file.read ) : {}
    
      @notes_dir = @config["notes_dir"] || @target_dir.join( "notes" )
      @book_dir  = @config["book_dir"]  || @target_dir.join( "book" )
    
      @project_basename = default_project_basename
      @filename_for_epub_book = @target_dir.join( "#{@config["filename"]}.epub" )
      @filename_for_mobi_book = @target_dir.join( "#{@config["filename"]}.mobi" )
      @filename_for_epub_notes = @target_dir.join( "#{@config["filename"]}.notes.epub" )
      @filename_for_mobi_notes = @target_dir.join( "#{@config["filename"]}.notes.mobi" )
    end 
    
    # shorthand string for referring to the project.  Variable-ish, used within filenames
    def default_project_basename
      @config["filename"] || File.split( @target_dir ).last.gsub( /\.epubforge$/ , "" )
    end

    def self.is_project_dir?( dir )
      return false if dir.nil?
      dir = Utils::FilePath.new( dir )
      dir.exist? && dir.join( RECIPE_FILE_NAME ).exist? && dir.join( "book" ).directory?
    end
    
    def project_exists?
      @target_dir.exist? && @target_dir.join( RECIPE_FILE_NAME )
    end
  end
end