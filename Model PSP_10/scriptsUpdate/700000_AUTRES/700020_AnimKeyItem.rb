module GamePlay
  class Anim_KeyItem
    def initialize(id=1,item=true,x=(640/2),y=(480/2))
      @running = true
      @viewport = Viewport.new(0,0,640,480)
      @viewport.z = 10001
      @item = Sprite.new(@viewport)
      @item.x = x 
      @item.y = y
      if item
        @item.bitmap = RPG::Cache.icon(POKEMON_S::Item.icon(id))
      else
        @item.bitmap = Bitmap.new(id)
      end
      @item.ox = @item.bitmap.width/2
      @item.oy = @item.bitmap.height/2
      @item.zoom_x = 0.4
      @item.zoom_y = 0.4
      @item.angle = 180
      @item.opacity = 0
      start_zoom
      @item.opacity = 255
      wait(10)
      tilt
      wait(10)
      disappear
      dispose
    end
         
    def start_zoom
      1.upto(30) do |i|
        @item.opacity += 8.5
        @item.zoom_x += 0.05*2
        @item.zoom_y += 0.05*2
        @item.angle -= 6
        Graphics.update
      end
    end
         
    def tilt 
      1.upto(5) do |i|
        @item.angle -= 2
        Graphics.update
      end
             
      1.upto(10) do |i|
        @item.angle += 2
        Graphics.update
      end
             
      1.upto(5) do |i|
        @item.angle -= 2
        Graphics.update
      end
    end
         
    def disappear
      1.upto(10) do |i|
        @item.zoom_x -= 0.2*2
        @item.zoom_y -= 0.2*2
        @item.opacity -= 25.5
        Graphics.update
      end   
    end
         
    def dispose
      @viewport.dispose
      @running = false
    end 
    
    def wait(frame)
      i = 0
      loop do
        i += 1
        Graphics.update
        if i >= frame
          break
        end
      end
    end
  end
end
 
class Interpreter
  alias ancienne_command126 command_126
  def command_126
    ancienne_command126
    type = nil
    if $game_switches[JINGLE]
      if POKEMON_S::Item.socket(@parameters[0]) <= 2 
        audio = "Audio/ME/#{DATA_AUDIO_ME[:acquisition_objet]}"
        type = :objet
        Advanced_Audio.new(type, audio)
        $game_system.bgm_memorize
        $game_system.bgm_play($game_system.playing_bgm, 0)
        Advanced_Audio[type].play(false)
      elsif POKEMON_S::Item.socket(@parameters[0]) == 3
        audio = "Audio/ME/#{DATA_AUDIO_ME[:acquisition_ct_cs]}"
        type = :ct
        Advanced_Audio.new(type, audio)
        $game_system.bgm_memorize
        $game_system.bgm_play($game_system.playing_bgm, 0)
        Advanced_Audio[type].play(false)
      elsif POKEMON_S::Item.socket(@parameters[0]) == 4
        audio = "Audio/ME/#{DATA_AUDIO_ME[:acquisition_baie]}"
        type = :baie
        Advanced_Audio.new(type, audio)
        $game_system.bgm_memorize
        $game_system.bgm_play($game_system.playing_bgm, 0)
        Advanced_Audio[type].play(false)
      elsif POKEMON_S::Item.socket(@parameters[0]) == 5
        audio = "Audio/ME/#{DATA_AUDIO_ME[:acquisition_objet_rare]}"
        type = :rare
        Advanced_Audio.new(type, audio)
        $game_system.bgm_memorize
        $game_system.bgm_play($game_system.playing_bgm, 0)
        Advanced_Audio[type].play(false)
        GamePlay::Anim_KeyItem.new(@parameters[0])
      end
      loop { break if Advanced_Audio[type].mode != "playing" } unless type 
      $game_system.bgm_restore
    end
  end
end