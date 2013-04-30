module EpubForge
  module Utils
    class Downloader
      # stolen from:
      # http://stackoverflow.com/questions/2263540/how-do-i-download-a-binary-file-over-http-using-ruby
      def download( url, io )
        @uri = URI.parse( url )
        @io  = io
        
        open( url ) do |f|
          @io << f.read
        end
        
        # @io << Net::HTTP.get( @uri )
        
        # Net::HTTP.start( @uri.host, @uri.port ) do |http| 
        #   http.request_get( @uri.path ) do |request| 
        #     request.read_body do |seg|
        #       puts "==============================  #{seg} ============================="
        #       io << seg
        #       #hack -- adjust to suit:
        #       sleep 0.005 
        #     end
        #   end
        # end
      rescue Exception => e
        handle_network_errors( e )
      end
      
      def handle_network_errors( e )
        raise e
      rescue URI::InvalidURIError => e
        puts "Tried to get #{@uri.path} but failed with URI::InvalidURIError."
      rescue OpenURI::HTTPError => e
        STDERR.write( "Couldn't fetch podcast info from #{@uri.path}\n" )
        STDERR.write( "#{e}\n\n" )
      rescue SocketError => e
        STDERR.write( "Problem connecting to server (Socket error) when downloading #{@uri.path}." )
        STDERR.write( "#{e}\n\n" )
      rescue URI::InvalidURIError => e
        STDERR.write( "URI::InvalidURIError for #{@uri.path}." )
        STDERR.write( "#{e}\n\n" )
        # this may be too broad a filter
        # TODO: retry?
      rescue SystemCallError => e
        STDERR.write( "Problem connecting to server (System call error) when downloading #{@uri.path}" )
        STDERR.write( "#{e}\n\n" )
      rescue OpenSSL::SSL::SSLError => e
        STDERR.write( "OpenSSL::SSL::SSLError while downloading #{@uri.path}" )
        STDERR.write( "#{e}\n\n" )
      # rescue Timeout::Error
      #   STDERR.write( "Timeout error connecting to #{@uri.path}" )
      #   STDERR.write( "#{e}\n\n" )
      end
    end
  end
end

