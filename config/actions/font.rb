module EpubForge
  module Action
    class Font < Action2
      define_action( "font:admin:update_descriptions" ) do |action|
        action.help( "Should probably be in local actions, not handed out to everyone?" )
        action.project_not_required
        
        action.execute do
          if continue?( "This is usually only done by the gem maintainer, and will take up a lot of disk space." )          
            if EpubForge::Fonts.config.local_repo.directory?
              puts "Updating cache repo (stored at #{EpubForge::Fonts.config.local_repo})"
              `cd #{EpubForge::Fonts.config.local_repo} && git pull`
            else
              puts "Cloning repo...."
              `git clone #{EpubForge::Fonts.config.remote_repo_url} #{EpubForge::Fonts.config.local_repo}`
            end
            
            collect_font_data
            hashify_font_data
            write_descriptions_file
          end
        end
      end
      
      define_action( "font:list" ) do |action|
        action.help( "List available fonts.  Enter a substring to narrow down the choices." )

        action.project_not_required
        
        action.execute do
          parse_args( *args )
          
          load_font_data
          
          families = @font_descriptions.lookup( @lookup_string )
          
          for family in families
            font_summary = family.fonts.map{ |font| 
              "(#{font.weight},#{font.style})" + (font.downloaded? ? " (downloaded)".paint(:green) : "")
            }.join(", ")
            
            puts "#{family.name}    (#{family.category})   #{font_summary}"
          end
          
          if families.length == 0
            say_error "No font by name of '#{@lookup_string}' found."
          end
          
        end
      end
      
      define_action( "font:install" ) do |action|
        action.help( "install a font" )
        action.usage( "\"Font Family Name\"")
        
        action.execute do
          book_dir = @project.book_dir
          font_dir = book_dir.join( "fonts" )
          font_dir.touch_dir
          
          css_dir = book_dir.join( "stylesheets" )
          css_dir.touch_dir
          
          font_cache_dir = EpubForge::USER_SETTINGS.join( "fonts", "cache" )
      
          parse_args( *args )
          font_family_to_install = get_font_family( @lookup_string )
          
          if font_family_to_install
            install_font_css( font_family_to_install, css_dir )

            font_family_to_install.download
            
            for font in font_family_to_install.fonts
              font_cache_dir.join( font.filename ).cp( font_dir )
            end
          else
            say_error( "No font found: #{@lookup_string}" )
          end
        end
      end

      protected
      def install_font_css( font_family_to_install, css_dir )
        template = EpubForge::TEMPLATES_DIR.join( "fonts", "font_face.%font_family.filenameize%.css.template" )
        FunWith::Templates::TemplateEvaluator.write( template, css_dir, :font_family => font_family_to_install )
      end
      
      def get_font_family( lookup_string )
        load_font_data
        font_family_to_install = @font_descriptions[ @lookup_string ]
        
        if font_family_to_install.nil?
          font_family_candidates = @font_descriptions.lookup( @lookup_string ).map{ |ff| [ff.name, ff] }
          font_family_candidates.push( ["None of the above", nil] )
          if font_family_candidates.length > 1
            font_family_to_install = ask_from_menu( "Which font did you mean?", font_family_candidates )
          end
        end
        
        font_family_to_install
      end
      
      def collect_font_data
        @font_data = {}


        for font_dir in EpubForge::Fonts.config.local_repo.join("fonts").glob( :all, :recurse => false )  # warning: hardcoded subdirectory
          metadata_file = font_dir.join( "METADATA.json" )



          if metadata_file.file?
            metadata = JSON.parse( metadata_file.read )
          else
            warn( "Metadata not available for font folder #{font_dir}")
            next
          end


          unless metadata_file.file?
            for path in font_dir.glob(:all).map(&:to_s)
              puts "        #{path}".paint(:yellow)
            end
            next
          end
          
          font_family = EpubForge::Fonts::FontFamilyDescription.set_from_hash( metadata )
          
          for font in font_family.fonts
            font.url = EpubForge::Fonts.config.download_root + font_dir.split.last + "/" + font.filename + "?raw=true"
          end
          # 
          # 
          # for font_hash in metadata[ "fonts" ]
          #   font = EpubForge::Fonts::FontDescription.set_from_hash( font_hash )
          #   font.url = EpubForge::Fonts.config.download_root + font_dir.split.last + "/" + font.filename
          #   
          #   font_family.fonts << font
          # end
          
          @font_data[ metadata[ "name" ] ] = font_family
        end
      end
      
      def hashify_font_data
        @final_hash = {}
        
        for name, data in @font_data
          @final_hash[name] = data.to_hash
        end
      end
      
      def write_descriptions_file
        EpubForge::Fonts.config.font_descriptions_file.write( @final_hash.to_yaml )
      end
      
      def load_font_data
        # returns a... font looker upper thingy?
        @font_descriptions = EpubForge::Fonts::FontFamilyDescription.from_yaml_file( EpubForge::Fonts.config.font_descriptions_file )
      end
      
      def parse_args( *args )
        args.pop if args.last =~ /^--proj/
        @lookup_string = args.map(&:strip).join(" ")
        @lookup_string = nil if @lookup_string.fwf_blank?
      end
    end
  end
end
