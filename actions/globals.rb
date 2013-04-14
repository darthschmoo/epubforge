module EpubForge
  module Action
    class Globals < ThorAction
      description "Set up global defaults for things like author name, publisher, etc."
      keywords :global
      usage       "#{$PROGRAM_NAME} global <key>=\"<val>\"  or   global -i <asks you for defaults>"
      project_not_required
      
      desc( "do:global", "TODO: Words go here." )
      def do( project, *args )
        # project is ignored
        @settings = EpubForge::Utils::Settings.new( EpubForge, EpubForge::USER_GLOBALS_FILE )
        
        puts args
        if args.first == "-i"
          interactive
        elsif args.first == "unset"
          args.shift
          args.each do |kv|
            @settings.act_on_string( kv, :unset)
          end  
        else
          args.each do |kv|
            @settings.act_on_string( kv, :set )
          end
        end  
        
        @settings.write_settings_file
      end
      
      protected
      def interactive
        keys = []
        question = """
        
Enter 'Q' to quit, type
'set settinggroup:settingsubgroup:setting=value' to install or replace a setting, or type
'unset settinggroup:settingsubgroup:key' to remove a setting.
Examples:
  set gopher:name=Woodchuck McGreggor
  set gopher:handler=Ranger Rick
  set gopher:domicile=Burrow #83612, Yellowstone
  unset gopher                       # removes all the previous settings
  set my:hotdog:has:a:firstname=It's o-s-c-a-r.
  
>>> """
        while ( settings = ask( question ) ) != "Q"
          if settings.match( /^unset / )
            key = settings.gsub(/^unset /,'').strip
            @settings.act_on_string( key, :unset )
            key = "unset: #{key}"
          elsif settings.match( /^set / )
            key = settings.gsub(/^set /,'').strip
            @settings.act_on_string( key, :set )
            key = "set:   #{key}"
          else
            say_error( "I didn't understand that." )
            key = "???"
          end
          
          keys << key
          
          
          interactive_print_user_keys keys
        end
      end
      
      def interactive_print_user_keys( keys )
        say "\n\n"
        for key in keys
          say "\t#{key}"
        end
      end
    end
  end
end
    