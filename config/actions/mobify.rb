module EpubForge
  module Action
    class Forge < ThorAction
      # TODO: These should be user-specific settings
      KINDLE_DEVICE_DIR = "/".fwf_filepath.join( "Volumes", "Kindle" )
      KINDLE_PUSH_DIR   = KINDLE_DEVICE_DIR.join( "documents", "fic-mine" )
      
      method_option :push, :type => :string, :default => KINDLE_PUSH_DIR
      
      desc( "forge:mobi", "Create a .mobi book. Optionally, try to push it to your Kindle.  Conversion requires Calibre (esp. the ebook-convert command-line utility)." )
      def mobi( *args )
        before_start
        @push_dir = (@options[:push] ? @options[:push].fwf_filepath.expand : nil)
        
        @args = args
        @push, @push_to = self.push?
        @src_epub = @project.filename_for_epub_book.fwf_filepath
        @dst_mobi = @project.filename_for_mobi_book.fwf_filepath
        
        @regenerate_epub = !!( @args.include?( "--no-cache" ) )
        
        mobify
        push if @push_dir
      end
      
      protected
      def mobify
        return false unless fulfill_requirements
        
        say "converting from #{@src_epub} to #{@dst_mobi}"
        cmd = "ebook-convert #{@src_epub} #{@dst_mobi}"
        say "executing: #{cmd}"
        `#{cmd}`

        if $?.success? && @dst_mobi.exist?
          say_all_is_well "Formatted for Kindle (.mobi file).  File at #{@dst_mobi}."
        else
          warn( "Something went wrong during the conversion process." )
          warn( "#{@dst_mobi} exists, but may not be complete or correct." ) if @dst_mobi.exist?  
          false
        end
      end
      
      def push
        if @push_dir.directory?
          FileUtils.copy( mobi_file, @push_dir )
          say_all_is_well "File pushed to Kindle."
          true
        else
          say_error "#{@push_dir} does not exist.  eBook NOT installed.  Your device may not be plugged in."
          false
        end   
      end
      
      
      def fulfill_requirements
        unless ebook_convert_installed?
          say_error( "ebook-convert is not installed.  Quitting." )
          return false 
        end
        
        if !@src_epub.exist? || @regenerate_epub
          Forge.new.do( @project ) 
        end
        
        unless @src_epub.exist?
          say_error( "Cannot find source .epub #{src_epub}" )
          return false
        end

        true
      end
    end
  end
end