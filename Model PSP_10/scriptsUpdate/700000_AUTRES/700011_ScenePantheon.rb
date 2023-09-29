#===============================================================================
# * Panthéon - Version Pokemon Script Project (PSP 0.X)
#    Par Youspin

# Simple script permettant d'afficher les Pokémon du nouveau maître après sa
# victoire sur la ligue, tel que dans les jeux originaux.
class Scene_Pantheon
  HearCries  = true                  # Entendre les cris des Pokémon
  ShowEggs   = false                 # Afficher les oeufs
  Alignment  = false                 # true = 1 rangée; false = 2 rangées
  
  Unselect   = 64                    # Opacité d'un Pokémon non-sélectioné
  
  # Temps en Frames. 40 Frames par seconde (par défaut).
  MoveSpeed     = 60    # Temps que prend un déplacement de Pokémon
  PokeTime      = 160   # Temps d'affichage des informations Pokémon
  
  # Temps d'apparition des informations du dresseur. 
  # Mettre 0 pour seulement attendre l'appui d'une touche.
  TrainerTime   = 280
  
  WelcomeTime   = 120   # Temps d'apparition du message WelcomeMsg
  
  Transition    = 120    # Temps que prend la transition de fin
  EndTime       = 80     # Temps à attendre après la dernière Transition
  
  Width         = 640   # Largeur de l'écran
  Height        = 480   # Hauteur de l'écran
  
  TextColor     = Color.new(248, 248, 248) # Couleur des strings d'information
  TextBackColor = Color.new(0, 0, 0)       # Couleur des ombres de ces strings
  ScreenEndColor= Color.new(0, 0, 0)       # Couleur de l'écran à la fin
  
  WelcomeMsg    = "Bienvenue au PANTHÉON!" # Affiché après tous les Pokémon
  EndMsg        = ["MAITRE DE LA LIGUE!", "FÉLICITATION!"] # Texte de fin
  
  def main
    # Création d'un Viewport
    @viewport = Viewport.new(0, 0, Width, Height)
    # Background
    @background = Plane.new(@viewport)
    @background.bitmap = RPG::Cache.picture(DATA_PANTHEON[:interface_pantheon])
    # Musique
    Audio.bgm_play("Audio/BGM/#{DATA_AUDIO_BGM[:pantheon]}")
    Graphics.transition(60, "Graphics/Transitions/computertr.png")
    
    # Création d'une liste des ID des Pokémon de l'équipe à utiliser
    @idList = []
    for i in 0..$pokemon_party.size-1
      if $pokemon_party.actors[i].egg && !ShowEggs
        @idList[i] = nil
      else
        @idList[i] = i
      end
      @idList.compact!
    end
    
    # Éviter de recréer le Sprite des informations du Pokémon à chaque fois
    txt = Sprite.new(@viewport)
    txt.y = Height / 3 * 2
    txt.bitmap = Bitmap.new(Width, Height / 3)
    txt.bitmap.font.name = $fontface
    txt.bitmap.font.size = 44
    @pS = []
    # Déplacement des Pokémon
    for i in 0..@idList.size-1
      Graphics.update
      # Obtenir un objet de classe Pokémon
      pokemon = $pokemon_party.actors[@idList[i]]
      # Création des sprites Pokémon, contenus dans la liste @pS
      @pS[i] = Sprite.new(@viewport)
      @pS[i].bitmap = RPG::Cache.battler(pokemon.battler_face(false), 0)
      @pS[i].ox = @pS[i].bitmap.width  / 2
      @pS[i].oy = @pS[i].bitmap.height / 2
      @pS[i].z = @idList.size - i
      @pS[i].mirror = (pF(i) == 1 ? true : false) if Alignment
      # Calcul des coordonnées
      case Alignment
      when true  # Les sprites sont répartis sur une rangée
        sx = -pF(i) * (Width / 2 + @pS[i].ox) + Width / 2
        ex =  iF(i) * 80 * pF(i) + Width / 2
        sy =  iF(i) * -20 + Height / 2
        ey =  sy
      when false # Les sprites sont répartis sur deux rangées
        sx = (19 - pF(cF(i)) * i)%3 * Width / 3 + Width / 6
        ex = (19 + pF(cF(i)) * i)%3 * Width / 3 + Width / 6
        sy = -pF(cF(i)) * (Width / 2 + @pS[i].oy) + Width / 2 
        ey =  Height / 3 * cF(i) + Height / 6
      end
      @pS[i].x = sx
      @pS[i].y = sy
      # Déplacement du Pokémon
      moveTo(@pS[i], ex, ey, MoveSpeed)
      # Entendre le cri du Pokémon
      if HearCries and !pokemon.egg
        Audio.se_play(pokemon.cry)
        20.times do
          @pS[i].x -= 3 * (-1) ** (@pS[i].x) # Effet de vibration
          Graphics.update
        end
      end
      Graphics.freeze
      # Affichage des information du Pokémon
      if !pokemon.egg
        name = "#{pokemon.given_name} / #{pokemon.name}"
        lvl  = "N. #{pokemon.level}"
        id   = "N° #{sprintf("%03d", pokemon.id.to_i).to_s}"
        dO   = "N°ID. #{sprintf("%05d", pokemon.trainer_id.to_i).to_s}"
      else
        name = "OEUF / " + 
        ('?' * POKEMON_S::Pokemon_Info.name(pokemon.id).size).to_s
        lvl  = "N. ?"
        id   = "N° ???"
        dO   = "N°ID. ?????"
      end
      # Affichage du nom et prénom
      txt.bitmap.font.color = TextBackColor
      txt.bitmap.draw_text(2, 64, Width, $fhb, name, 1)
      txt.bitmap.font.color = TextColor
      txt.bitmap.draw_text(0, 62, Width, $fhb, name, 1)
      # Affichage du niveau
      size = txt.bitmap.text_size(name).width
      txt.bitmap.font.color = TextBackColor
      txt.bitmap.draw_text(42 + size/2 + Width/2, 64, Width, $fhb, lvl)
      txt.bitmap.font.color = TextColor
      txt.bitmap.draw_text(40 + size/2 + Width/2, 62, Width, $fhb, lvl)
      if !pokemon.egg
        # Affichage du type
        type1 = RPG::Cache.picture("T#{pokemon.type1}.png")
        type2 = RPG::Cache.picture("T#{pokemon.type2}.png")
        typeRect = Rect.new(0, 0, type1.width, type1.height)
        bmp = Bitmap.new(typeRect.width * 2 + 3, typeRect.height)
        bmp.blt(3 + typeRect.width, 0, type2, typeRect)
        bmp.blt(pokemon.type2 == 0 ? 3 + typeRect.width : 0, 0, type1, typeRect)
        txt.bitmap.blt(Width / 5 - bmp.rect.width / 2, 12, bmp, bmp.rect)
        # Affichage du genre
        if pokemon.gender != 0 
          g = pokemon.gender == 1 ? RPG::Cache.picture(MALE) :
          RPG::Cache.picture(FEMELLE)
          genderRect = Rect.new(0, 0, g.width, g.height)
          txt.bitmap.blt(Width/2 - (size/2 + g.width + 24), 65, g, genderRect)
        end
      end
      
      # Affichage de l'ID
      txt.bitmap.font.color = TextBackColor
      txt.bitmap.draw_text(2, 14, Width, $fhb, id, 1)
      txt.bitmap.font.color = TextColor
      txt.bitmap.draw_text(0, 12, Width, $fhb, id, 1)
      size = txt.bitmap.text_size(dO).width
      # Affichage de l'ID dresseur
      txt.bitmap.font.color = TextBackColor
      txt.bitmap.draw_text(2 + size, 14, Width, $fhb, dO, 1)
      txt.bitmap.font.color = TextColor
      txt.bitmap.draw_text(0 + size, 12, Width, $fhb, dO, 1)
      
      Graphics.transition
      # Voir les informations pendant le temps PokeTime
      PokeTime.times { Graphics.update }
      
      Graphics.freeze
      @pS[i].opacity = Unselect
      txt.bitmap.clear
      Graphics.transition
    end # For loop
    
    Graphics.freeze
    # Remettre l'opacité des Pokémon à 255
    for sprite in @pS; sprite.opacity = 255; end
    Graphics.transition
    
    # Afficher le message : Bienvenue au PANTHÉON!
    welcome = Sprite.new(@viewport)
    welcome.bitmap = Bitmap.new(Width, Height)
    welcome.bitmap.font.color = TextBackColor
    welcome.bitmap.font.name = $fontface
    welcome.bitmap.font.size = $fontsizebig
    welcome.bitmap.draw_text(2, Width/2 + 12, Width, $fhb, WelcomeMsg, 1)
    welcome.bitmap.font.color = TextColor
    welcome.bitmap.draw_text(0, Width/2 + 10, Width, $fhb, WelcomeMsg, 1)
    WelcomeTime.times { Graphics.update }
    
    Graphics.freeze
    if !Alignment
      for sprite in @pS; sprite.opacity = Unselect; end end
    
    welcome.dispose
    # Création du sprite dresseur
    playerSprite = Sprite.new(@viewport)
    playerSprite.bitmap = RPG::Cache.picture($game_switches[FILLE] ?
      DATA_PANTHEON[:sprite_fille] : DATA_PANTHEON[:sprite_gars])
    playerSprite.z = @idList.size + 1
    playerSprite.ox = playerSprite.bitmap.width / 2
    playerSprite.oy = playerSprite.bitmap.height / 2
    playerSprite.x = Width / 2
    playerSprite.y = Height / 2
    if !Alignment
      Graphics.transition
      # Déplacement du sprite
      moveTo(playerSprite, Width / 4 * 3 - 32, Height / 2, 40) 
      30.times { Graphics.update }
      Graphics.freeze
    end
    # Afficher les informations du dresseur
    w = Window.new(@viewport)
    w.z = 8
    w.windowskin = RPG::Cache.windowskin($data_system.windowskin_name)
    w.x, w.y, w.width, w.height = 16, 16, Width / 2, 144
    w.contents = Bitmap.new(w.width - 32, w.height - 32)
    w.contents.font.name = $fontface
    w.contents.font.size = $fontsize
    w.contents.font.color = Color.new(60, 60, 60) #Def de Window_Base
    time_sec = Graphics.frame_count / Graphics.frame_rate
    hour = (time_sec / 3600).to_s
    minute = "00"
    minute += (time_sec % 3600 / 60).to_s
    minute = minute[minute.size - 2, 2]
    time = hour + ":" + minute
    w.contents.draw_text(8, 8, w.width, 32, "NOM:")
    w.contents.draw_text(0, 8, w.width/8*7, 32, POKEMON_S::Player.name, 2)
    w.contents.draw_text(8, 40, w.width, 32, "N°ID:")
    w.contents.draw_text(0, 40, w.width/8*7, 32, 
      sprintf("%05d", POKEMON_S::Player.id.to_i), 2)
    w.contents.draw_text(8, 72, w.width, 32, "DURÉE JEU:")
    w.contents.draw_text(0, 72, w.width/8*7, 32, time, 2)
    msgbox = POKEMON_S::Pokemon_Window_Help.new
    msgbox.draw_text(EndMsg[0], EndMsg[1])
    Graphics.transition
    i = 0
    while i != TrainerTime
      Graphics.update
      Input.update
      break if Input.trigger?(Input::C)
      i += 1
    end
    Graphics.freeze
    @endBackground = Sprite.new
    @endBackground.bitmap = Bitmap.new(Width, Height)
    @endBackground.bitmap.fill_rect(0, 0, Width, Height, ScreenEndColor)
    @endBackground.z = 10000
    Graphics.transition(Transition)
    EndTime.times { Graphics.update }
    # Retourner sur la carte de jeu
    $scene = Scene_Map.new
    Graphics.freeze
    # Restaurer la musique de fond de la carte en cours
    $game_system.bgm_restore
    $game_system.bgs_restore
    
    msgbox.dispose
    @viewport.dispose
    @endBackground.dispose
  end
  
  # Retourne -1 si pair, 1 si impair
  def pF(n); n%2*2-1; end
  # Retourne [1,1,2,2,3,3][i] sans créer d'array
  def iF(n); n%3 + (n-pF(n))%3; end
  # Retourne [0,0,0,1,1,1][i] sans créer d'array
  def cF(n); (n-n%3)%2; end
  # Déplacement d'un sprite
  def moveTo(sprite, x, y, sp)
    vt = sp
    while vt > 0
      sprite.x = (sprite.x * (vt - 1) + x) / vt
      sprite.y = (sprite.y * (vt - 1) + y) / vt
      vt -= 1
      Graphics.update
    end
  end
end # Class

class Interpreter
  def pantheon
    # Mémoriser la musique de fond de la carte en cours
    $game_system.bgm_memorize
    $game_system.bgs_memorize
    $scene = Scene_Pantheon.new
  end
end