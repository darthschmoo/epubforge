module EpubForge
  module Action
    class Epub < Action2
      define_action( "epub" ) do |action|
        # include_standard_options
        action.help( "Create ebooks in various formats from the .markdown files in the project's book/ and notes/ subdirectories." )
      # keyword( "forge" )
      # desc( "forge", "Wraps the project up in a .epub (ebook) file.")
        action.execute do
          epub_common( "book" )
        end
      end
      
      define_action( "epub:notes" ) do |action|
        action.help( "Create ebooks for your story bible, instead of your main book" )
        
        action.execute do
          epub_common( "notes" )
        end
      end
      
      define_action( "epub:unzip" ) do |action|
        action.help( "Unzip your generated .epub file into a temporary directory." )
        action.execute do
          book = @project.filename_for_book.ext("epub")
          raise "Error unzipping epub: No ebook at #{book}" unless book.file?
          tmpdir = book.dirname.join("tmp").timestamp.touch_dir
          debugger
          `unzip #{book} -d #{tmpdir}`
        end
      end
      
      protected
      def epub_common( target, opts = {} )
        # opts[:page_order] ||= project.config["pages"][target]
        case target
        when "book"
          opts[:book_dir] ||= project.book_dir
          outfile = opts.delete(:outfile) || project.filename_for_book.ext("epub")
        when "notes"
          opts[:book_dir] ||= project.notes_dir
          outfile = opts.delete(:outfile) || project.filename_for_notes.ext("epub")
        else
          # Hope the caller knows what it's doing.
          opts[:book_dir] ||= project.book_dir.up.join( target )
          outfile = opts.delete(:outfile) || project.root_dir.join( "#{project.default_project_basename}.#{target}.epub" )
        end
        
        opts[:verbose] = verbose?
        builder = EpubForge::Builder::Epub.new( project, opts )

        builder.build
        builder.package( outfile )
        builder.clean
        say_all_is_well( "Done building epub <#{outfile}>" )
      end
    end
  end
end


