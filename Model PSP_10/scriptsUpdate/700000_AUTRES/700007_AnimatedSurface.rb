#==============================================================================
# ■ AnimatedSurface - module Yuki
#   Par Nuri Yuri
#------------------------------------------------------------------------------
module Yuki
  class AnimatedSurface < ::Sprite
    attr_accessor :no_animation
    
    def define_animation(nb_of_frame, frame_needed = 1, direction = :vertica, no_animation = false)
      return print("Veuillez charger un bitmap avant de définir l'animation !") unless self.bitmap
      bmp = self.bitmap
      @no_animation = no_animation
      return if no_animation
      @delta_frame = frame_needed
      @direction = direction
      @counter = 0
      self.src_rect.set(0, 0, direction != :vertical ? bmp.width / nb_of_frame : bmp.width, direction == :vertical ? bmp.height / nb_of_frame : bmp.height)
    end
  
    def update
      return if @no_animation
       @counter += 1
       #> Mise à jour de l'animation
       if((@counter % @delta_frame) == 0)
         if(@direction == :vertical)
           self.src_rect.y += self.src_rect.height
           if(self.src_rect.y >= self.bitmap.height)
             @counter = self.src_rect.y = 0
          end
         else
           self.src_rect.x += self.src_rect.width
           if(self.src_rect.x >= self.bitmap.width)
             @counter = self.src_rect.x = 0
           end
         end
       end
      super
    end
  end
end