module POKEMON_S
  # --------------------------------------------------------
  # EXIT_TPS
  #   Nbre de secondes max que doit durer le générique de fin.
  #   Pour le confort de vos joueurs, il est recommandé de ne pas
  #     faire de génériques de plus de quelques secondes.
  #   Si le temps total n'est pas divisible par le nombre d'images
  #     alors le temps par image sera arrondi selon les règles
  #     arithmétiques en vigueur.
  # --------------------------------------------------------
  EXIT_TPS = 0
  
  # --------------------------------------------------------
  # EXIT_IMGS
  #   Liste des images qui apparaitront lorsque le joueur quittera le jeu
  #   Mettre [] pour désactiver le générique de fin
  # --------------------------------------------------------
  EXIT_IMGS = []
  
  # --------------------------------------------------------
  # EXIT_MSG
  #   Message qui sera affiché lorsque le joueur tentera de fermer le jeu
  #     pendant le générique de fin
  #   Mettre false pour autoriser le joueur à ne pas regarder le générique
  #     jusqu'au bout
  # --------------------------------------------------------
  EXIT_MSG = false
  
  # --------------------------------------------------------
  # MAX_SAUVEGARDES
  #   Détermine le nombre maximum de sauvegardes autorisées
  #   ATTENTION ! Veuillez régler cette valeur en début de
  #   projet. Si cette valeur est réglé à 10 et qu'ensuite
  #   vous la mettez à 3, ceux qu'ont fait 10 sauvegardes
  #   verront 7 de leur sauvegardes innaccessibles !
  # --------------------------------------------------------
  MAX_SAUVEGARDES = 3
  
  # --------------------------------------------------------
  # SPEED_MSG
  #   - Vitesse de défilement du texte, en caractère par images.
  #     Minimum 1 (lent), Maximum 30 (instantanné)
  #     Réglez à 0 pour avoir un affichage instantanné
  # --------------------------------------------------------
  SPEED_MSG = 2
  
  # --------------------------------------------------------
  # BATTLE_TRANS
  #   - Nombre de transitions vers les combats
  #       Les transitions doivent être contenues dans Graphics/Transition/
  #       et doivent avoir pour nom "battlex.png" où 
  #       x vaut de 1 à BATTLE_TRANS
  #     Important: BATTLE_TRANS est égal au nombre de transitions dans le dossier
  # --------------------------------------------------------
  BATTLE_TRANS = 4 
  
  # --------------------------------------------------------
  # MAX_LEVEL
  #   - Niveau maximal des Pokémons
  # --------------------------------------------------------
  MAX_LEVEL = 100
  
  # --------------------------------------------------------
  # MAPLINK
  #   - Permet d'activer la jonction des maps (plus de lag, mais meilleur
  #     effet visuel)
  #     Inclure sur chaque map la fonction jonction_map décrite dans Interpreter
  # --------------------------------------------------------
  MAPLINK = false
  
  # --------------------------------------------------------
  # _MAPLINK
  #   - $game_switches[MAPLINK_SWITCHES]
  # --------------------------------------------------------
  # Ne pas modifier
  def self._MAPLINK
    if $game_switches[MAPLINK_SWITCHES] == nil
      return false
    end
    return $game_switches[MAPLINK_SWITCHES]
  end
  
  def self._MAPLINK=(value)
    $game_switches[MAPLINK_SWITCHES] = value
  end
  
  # --------------------------------------------------------
  # MAPPANEL
  #   - Permet d'activer les messages de localisation qui donnent le nom
  #     de la map dans laquelle on entre
  # --------------------------------------------------------
  MAPPANEL = true
  
  # --------------------------------------------------------
  # _WMAPID
  #   - Vous pouvez y régler une valeur par défaut ici
  # --------------------------------------------------------
  def self._WMAPID
    if $game_variables[CARTE] == 0
      return 19 #Valeur par défaut
    end
    return $game_variables[CARTE]
  end

  
  # --------------------------------------------------------
  # TRADEGROUP
  #   - Nombre entre 1 et 1023 compris, qui détermine un groupe de jeux compatibles
  #     Si TRADEGROUP est réglé à 0, tout Pokémon peut être reçu de n'importe
  #     quel jeu (et donc attentions aux bugs)
  # --------------------------------------------------------
  TRADEGROUP = 667
  
  
  # --------------------------------------------------------
  # SAVEBOUNDSLOT
  #   - Mettez true si vous voulez qu'une sauvegarde soit liée
  #     à un slot
  # --------------------------------------------------------
  SAVEBOUNDSLOT = false
  
  # --------------------------------------------------------
  # ATTACKKIND
  #   - Mettez true pour que les attaques utilisent leur caractère
  #     Physique / Spécial au sens D/P du terme.
  #     false si vous retournez au système de R/S/E
  # --------------------------------------------------------
  ATTACKKIND = true
  
  
  # --------------------------------------------------------
  # MAPINTRO
  #   - Ecrivez [numéro de map, position x, position y] 
  #     si vous voulez spécifiez une intro faite sur une map de votre choix.
  #     Ecrivez false sinon : l'intro en script sera utilisée
  #     Exemple : [5, 12, 13] => commence une intro sur la map 5, x=12, y=13
  #   - Quand votre intro est terminée, inscrivez
  # --------------------------------------------------------
  MAPINTRO = false
  
  # --------------------------------------------------------
  # LISTOLDSAVE
  #   Pour les sauvegardes <= PSP 0.9.2 remastered afin de les convertir
  #   au nouveau système PSP 1.0
  #   saisissez ici les variables globales sans le "$" qui dans votre
  #   projet PSP 0.9.2 remastered ou version antérieur pouvaient être visible
  #   dans la méthode read_save_data(file) de Scene_Title de Système Général
  #   Ex : 
  #   Dans read_save_data(file) de votre projet PSP 0.9.2 remastered :
  #   $nom_var = Marshal.load(file)
  #   Voilà comment cela doit être retranscrit dans le tableau ci-dessous :
  #   LISTOLDSAVE = %w[nom_var]
  # --------------------------------------------------------
  LISTOLDSAVE = %w[characters frame_count game_system game_switches 
                   game_variables game_self_switches game_screen game_actors 
                   game_party game_troop game_map game_player read_data 
                   pokemon_party random_encounter data_pokedex data_storage 
                   battle_var existing_pokemon string]
  
  # --------------------------------------------------------
  # NAMESFILESAVES
  #   Pour les sauvegardes pour ceux ayant installés le nouveau système
  #   apparu dans PSP 1.0 - Alpha 0.9a (version réservée aux contributeurs
  #   internes) afin de les convertir au système final de PSP 1.0
  #   Dans Scene_Title_SG, copiez le tableau $name_files_saves et écrasez
  #   celui qui se trouve ci-dessous
  #   Puis renommez $name_files_saves en NAMESFILESAVES
  # --------------------------------------------------------
  NAMESFILESAVES =  %w[Characters Frame_Count System Switches Variables
                       SelfSwitches SelfVariables Screen Actors Party
                       Troop Map Player ReadData PokemonParty 
                       RandomEncounter DataPokedex DataStorage BattleVar
                       ExistingPokemon String]
  
  # --------------------------------------------------------
  # EXP_TABLE
  #   - Table précalculée de l'expérience
  #     A modifier si vous savez ce que vous faites
  # --------------------------------------------------------
  EXP_TABLE = []
  for j in 0..5
    EXP_TABLE[j] = []
    EXP_TABLE[j][0] = nil
    EXP_TABLE[j][1] = 0
    case j
    when 0 # Rapide
      for i in 2..MAX_LEVEL
        EXP_TABLE[j][i] = Integer(0.8*(i**3))
      end
    when 1 # Normal
      for i in 2..MAX_LEVEL
        EXP_TABLE[j][i] = Integer(i**3)
      end
    when 2 # Lent
      for i in 2..MAX_LEVEL
        EXP_TABLE[j][i] = Integer(1.25*(i**3))
      end
    when 3 # Parabolique
      for i in 2..MAX_LEVEL
        EXP_TABLE[j][i] = Integer((1.2*(i**3) - 15*(i**2) + 100*i - 140))
      end
    when 4 # Erratic
      for i in 2..50
        EXP_TABLE[j][i] = Integer( i**3*(100-i)/50.0 )
      end
      for i in 51..68
        EXP_TABLE[j][i] = Integer( i**3*(150-i)/100.0 )
      end
     for i in 69..98
        EXP_TABLE[j][i] =  Integer(i**3*Integer((1911 - 10*i)/3)/500)
      end
      for i in 99..MAX_LEVEL
        EXP_TABLE[j][i] = Integer( i**3*(160-i)/100.0 )
      end
    when 5 # Fluctuant
      for i in 2..15
        EXP_TABLE[j][i] = Integer( i**3* (24 + (i+1)/3) / 50  )
      end
      for i in 16..35
        EXP_TABLE[j][i] = Integer( i**3* ( 14 + i) / 50 )
      end
      for i in 36..MAX_LEVEL
        EXP_TABLE[j][i] = Integer( i**3 * ( 32 + (i/2) ) / 50 )
      end
    end
  end
end

