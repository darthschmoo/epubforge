# have to make a tweak to configurator to allow it to work with project class instances
module Configurator
  def self.extended(base)
    if base.respond_to?(:class_eval)
      base.class_eval { remove_instance_variable(:@configuration) if defined? @configuration }
    else
      puts "EXTENDING #{base} AS WE SPEAK"
      base.instance_variable_set( :@got_extended, true )
      # base.instance_variable_set( :@configuration, nil )
    end
  end
end

module EpubForge
  module Utils
    class Settings
      def self.thing_to_configure( *args )
        if( args.length >= 1 )
          @thing_to_configure = args.first
        end
        @thing_to_configure
      end
      
      # Takes a configurator object and (optionally) a settings file to write it out to.
      def initialize( configable, file = nil )
        @configable = configable
        @file = file.fwf_filepath.expand if file
        install_configuration
      end
      
      def act_on_string( keqv, set = :set )
        k,v = parse_kv( keqv )
        if set == :unset
          unset( k )
        elsif set == :set
          set( k, v )
        end
      end
      
      def set( key, val )
        setting, last_key = descend_key( key )
        setting[last_key] = val
      end
      
      def unset( key )
        setting, last_key = descend_key( key )
        setting.delete( last_key )
      end
    
      def write_settings_file( settings_file = nil )
        settings_file ||= @file
        settings_file = settings_file.fwf_filepath
        @depth = 0
        str = indented_line("EpubForge::Utils::Settings.thing_to_configure.config do")
        str += write_config( @configable.config.to_hash )
        str += indented_line("end")
        settings_file.write( str ) 
      end

      protected
      def install_configuration
        debugger
        self.class.thing_to_configure( @configable )
        self.class.thing_to_configure.extend( Configurator )
        require @file
        self.class.thing_to_configure( nil )
      end

      def indented_line( str )
        puts " " * @depth + str + "\n"
        " " * @depth + str + "\n"
      end

      def write_config( h )
        str = ""
        @depth += 2
        for k, v in h
          if v.is_a?(Hash)
            str += indented_line( "#{k} do" )
            str += write_config( v )
            str += indented_line( "end" )
          else
            str += indented_line( "#{k} #{stringify_value( v )}" )
          end
        end
        @depth -= 2

        str
      end

      def stringify_value( v )
        case v
        when Regexp
          "/#{v.source}/"
        when Numeric
          "#{v}"
        when String
          escape_string( v )
        when FunWith::Files::FilePath
          escape_string( v ) + ".fwf_filepath"
        when Array                                 # TODO: Is there a way to enter arrays?
          "[ #{ v.map{ |item| stringify_value(item) }.join(', ') } ]"
        when NilClass
          "nil"
        when TrueClass
          "true"
        when FalseClass
          "false"
        end
      end

      def escape_string( s )
        s.inspect
      end

      # If given a hierarchical setting key like git:host:url,
      # returns the hash attached to config[:git][:host], so the caller can say
      # rval[:url] = "bannedsorcery.com".  Creates empty hashes as it descends,
      # if neccessary.
      def descend_key( k )
        keychain = k.split(":").map{ |key| :"#{key}" }

        s = @configable.config

        for key in keychain[0..-2]
          s[key] ||= {}
          s = s[key]
        end

        [s, keychain.last]
      end

      def parse_kv( str )
        if m = str.match( /^([a-z0-9_:]+)=(.*)$/ )
          discard, k, v = m.to_a
        elsif m = str.match( /^([a-z0-9_:]+)$/ )
          discard, k = m.to_a
          v = nil
        else
          k = v = nil
        end

        [k, v]
      end
    end
  end
end