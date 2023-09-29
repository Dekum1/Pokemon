#==============================================================================
# ■ ExitGenerique
# Pokemon Script Project - Sphinx
# 11/11/09
#-----------------------------------------------------------------------------
# Scène à ne modifier que si vous savez ce que vous faites
#-----------------------------------------------------------------------------
# Générique de fin
#-----------------------------------------------------------------------------
module ExitGenerique
  include POKEMON_S
  def self.start
    sprite = Sprite.new
    sprite.z = 50000
    bool = true
    i = 0
    while bool
      begin
        while i < POKEMON_S::EXIT_IMGS.size
          Graphics.freeze
          sprite.bitmap = RPG::Cache.title("Generique/#{POKEMON_S::EXIT_IMGS[i]}")
          Graphics.transition(5)
          tmp = 0
          while tmp < (((POKEMON_S::EXIT_TPS.to_f / POKEMON_S::EXIT_IMGS.size) * Graphics.frame_rate).round - 5)
            Graphics.update
            tmp += 1
          end
          i += 1
        end
        bool = false
      rescue SystemExit
        if POKEMON_S::EXIT_MSG
          print POKEMON_S::EXIT_MSG
        else
          return
        end
      end
    end
  end
end