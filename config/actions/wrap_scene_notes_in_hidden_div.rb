module EpubForge
  module Action
    class WrapSceneNotesInHiddenDiv < ThorAction
      description "Assumes scenes are in book/scene-XXXX.markdown, and that the scene description is above the first horizontal row (a.k.a. ***** in Markdown)."
      keywords    :wrap_scene_notes
      usage       "#{$PROGRAM_NAME} wrap_scene_notes<project_directory (optional if current directory)>\n\tfollow with 'undo' to reverse transformation."
      
      START_SCENE = 0
      IN_SCENE    = 1
      IN_STORY    = 2
      ABORTING    = 3
      
      START_OF_SCENE_MARKER = "<!-- EPUBFORGE::SCENE_DESCRIPTION -->\n"
      END_OF_SCENE_MARKER = "<!-- /EPUBFORGE::SCENE_DESCRIPTION -->\n"
      
      desc( "do:wrap_scene_notes", "Wrap scene notes (obsolete. Do not use.)")
      def do( project, *args )
        @project = project
        
        if args.first == "undo"
          unwrap_files  
        else
          wrap_files
        end
      end
      
      protected
      def wrap_files
        transform_each_scene do |ft|
          for line in ft.readlines
            case @mode
            when START_SCENE
              if line =~ /epubforge_scene_description/
                puts "scene description is already wrapped. skipping..."
                @mode = ABORTING
                break
              end
              
              ft << START_OF_SCENE_MARKER
              ft << line
              @mode = IN_SCENE
            when IN_SCENE
              if line =~ /^\*{3,}\s*$/    # looking for '******'
                ft << END_OF_SCENE_MARKER
                @mode = IN_STORY
              end
              ft << line
            when IN_STORY
              ft << line
            end
          end
          
          # what if you never find the end?
          if @mode == IN_SCENE
            ft << END_OF_SCENE_MARKER
          end
        end
      end
    
      def unwrap_files
        transform_each_scene do |ft|
          for line in ft.readlines
            # puts "---------------------------- #{ft.original_filename} - #{ft.finished?} -----------------------------------"
            #             puts "#{@mode} : #{line}"
            #             puts File.size?(ft.transformed_filename)
            #             puts ""
            
            case @mode
            when START_SCENE
              if line =~ /#{START_OF_SCENE_MARKER}/
                @mode = IN_SCENE
              else
                ft << line
              end
            when IN_SCENE
              if line =~ /#{END_OF_SCENE_MARKER}/
                @mode = IN_STORY
              else
                ft << line
              end
            when IN_STORY
              ft << line
            end
          end
        end
      end
      
      def transform_each_scene &block
        @transformed_files = []   # save output until the end, then mv them all 
                                  # when you're sure the process was successful
        
        each_scene do |scene|
          ft = FileTransformer.new( scene )
          @transformed_files << ft
          @mode = START_SCENE
          
          yield ft
        end
        
        if ask( "Finalize?" ) == "Y"
          @transformed_files.each do |t|
            t.finalize
          end
        else
          @transformed_files.each do |t|
            t.abort
          end
        end
      end
      
      def each_scene(&block)
        for scene in Dir["#{@project.book_dir}/scene-????.markdown"].entries
          yield scene
        end
      end
    end
  end
end