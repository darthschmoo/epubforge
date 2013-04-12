
module EpubForge
  module Action
    class Init < AbstractAction
      description "Create a new epubforge project."
      keywords    :oldinit
      usage       "#{$PROGRAM_NAME} init <project_directory> (directory shouldn't exist)"
      project_not_required
      
      def do( project, *args )
        parse_args(*args)
        create_project
      end
      
      def create_project
        Utils::DirectoryBuilder.create( @dst_dir ) do |d|
          d.dir( "book" ) do
            src = @src_dir.join( "book", "foreword.markdown" )
            dir.template( src, "foreword.markdown", {} )

            src = @src_dir.join( "book", "afterword.markdown" )
            dir.template( src, "foreword.markdown", {} )

            src = @src_dir.join( "book", "title_page.markdown" )
            dir.template( src, "title_page.markdown", {} )

            1.upto( @chapter_count ) do |i|
              src = @src_dir.join( "book", "chapter.xx.markdown")
              dir.template( src, "chapter.#{ sprintf("%04i", i)}.markdown", {} )
            end
            
            d.dir( "images" ) do
              d.copy( @src_dir.join( "book", "images", "cover.png" ) )
            end
            
            d.dir( "stylesheets" ) do
              
            end
          end
          
          d.dir( "notes" ) do
            d.dir( "images" ) do
              
            end
            
            d.dir( "stylesheets" ) do
              
            end
          end
          
          d.dir( "settings" ) do
            d.dir( "actions" ) do
              
            end
          end
        end
        # for entry in @src_dir.glob( "**", "*" )
        #   # `cp -R #{@src_dir} #{@dst_dir}`
        #   debugger
        #   puts entry
        # end
      end
      
      def parse_args(*args)
        target_dir = args.pop

        if target_dir.nil?
          puts "You must specify a target directory."
          puts usage
          puts "\n"
          exit(0)
        end
        
        @project = Project.new( target_dir )
        @template_name = "default"
        @chapter_count = 20
                
        @src_dir = EpubForge::TEMPLATE_DIR.join( @template_name )
        @dst_dir = @project.target_dir
        
        if @dst_dir.exist?
          puts "Directory already exists.  No action taken.  Please choose an empty directory."
          exit(0)
        elsif !@src_dir.exist?
          puts "No template resides in directory : #{@src_dir}.  No action taken."
          exit(0)
        end
      end
    end
  end
end