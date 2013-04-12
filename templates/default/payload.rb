dir '/'
  dir 'book'
    template 'title_page.markdown'
    template 'foreword.markdown'
    template 'afterword.markdown'
    sequence 'scene-{04i}.markdown'
    dir 'images'
      file 'cover.png'
    dir 'stylesheets'
      template 'stylesheet.css'
  dir 'notes'
    sequence 'character.{name}.markdown'
  dir 'settings'
    template 'config'
    file 'htmlizers.rb'
    template 'wordcount'
    dir 'actions'
      file 'local_action.rb.example'
    

class Munition
end

class FileSequence < Munition
end

class DirectorySequence < Munition
end

class TemplateFile < Munition
end



class Payload
  def initialize( src, &block )
    @munitions = []
    yield self if block_given?
  end
  
  def dir( name, &block )
    
    yield if block_given?
  end
  
  def root( dir = nil )
    @root = dir.epf_filepath if dir
    @root
  end
  
  def sequence( name, count )
    
  end
  
  def deploy( dst )
    @munitions.each do |munition|
      munition.deploy( dst )
    end
  end
end

Template::Payload.new do |t|
  dir.template 
  
end