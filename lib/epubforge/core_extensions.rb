module EpubForge
  module CoreExtensions
    def install_extensions
      for klass in ["Array", "Kernel", "NilClass", "Object", "String"]
        puts "Installink #{klass} #{self}"
        Kernel.const_get( klass ).send( :include, self.const_get( klass ) )        
      end
    end
  end
end

EpubForge::CoreExtensions.extend( EpubForge::CoreExtensions )
