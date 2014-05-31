# class Object
#   def umethods( regex = /.*/ )
#     (self.methods.sort - Object.new.methods).grep( regex )
#   end
#   
#   def get_and_set( *method_names )
#     for name in method_names
#       if self.is_a?(Class) || self.is_a?(Module)
#         eval "define_method( :#{name} ) do |*args|
#                 self.instance_variable_set( :@#{name}, args.first ) if args.length == 1
#                 self.instance_variable_get( :@#{name} )
#               end"
#       else
#         m = Module.new
#         m.get_and_set( *method_names )
#         self.extend( m )
#       end
#       # define_method( name ) do |*args|
#       #   self.instance_variable_set( :"@#{__method__}", args.first ) if args.length == 1
#       #   self.instance_variable_get( :"@#{__method__}" )
#       # end
#     end
#   end
# end
