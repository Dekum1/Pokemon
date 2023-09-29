#==============================================================================
# ■ Pokemon
# Pokemon Script Project - Krosk 
# 20/07/07
# 26/08/08 - révision, support des oeufs
#-----------------------------------------------------------------------------
# Gestion individuelle
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # class Pokemon : génère l'information sur un Pokémon :
  # - Création d'un Pokémon
  # - Création du code d'identification du Pokémon (32 bits)
  # - Gestion du nom
  # - Désignation du sexe
  # - Gestion du shiny
  # - Pokéball associée
  # - Item associé
  # - Gestion des rounds
  #------------------------------------------------------------
  class Pokemon
    #Archetype
    attr_reader :id             # ID du Pokémon
    attr_reader :id_bis         # ID secondaire du Pokémon
    attr_reader :name           # Nom générique de l'espèce
    attr_reader :battler_face   # Généré automatiquement
    attr_reader :battler_back   # Généré automatiquement
    attr_reader :cry            # Généré automatiquement
    attr_reader :icon           # Généré automatiquement
    attr_reader :base_hp        # Stats de base
    attr_reader :base_atk
    attr_reader :base_dfe
    attr_reader :base_spd
    attr_reader :base_ats
    attr_reader :base_dfs
    attr_reader :skills_table   # Table de skills naturels
    attr_reader :skills_allow   # Table de skills permissibles (CT, CS)
    attr_reader :description    # Liste
    attr_reader :exp_type       # Expérience: Courbe d'évolution, définie la table
    attr_accessor :type1
    attr_accessor :type2
    #attr_reader :exp_list       # Expérience: Table d'expérience
    attr_reader :evolve_list
    attr_reader :battle_list    # Table des EV
    attr_accessor :ability          # Capacité propre du Pokémon
    attr_reader :rareness       # Rareté
    # Caractéristiques
    attr_reader :code           # Code indentification propre au Pokémon
    attr_reader :dv_hp
    attr_reader :dv_atk
    attr_reader :dv_dfe
    attr_reader :dv_spd
    attr_reader :dv_ats
    attr_reader :dv_dfs
    attr_accessor :nature         # Code "caractère" du Pokémon
    attr_accessor :shiny          # Caractère Shiny
    attr_reader :gender         # 0 sans genre 1 male 2 femelle
    attr_reader :egg           # état oeuf
    attr_accessor :trainer_id
    attr_accessor :trainer_name
    attr_accessor :given_name   # Nom donné au Pokémon
    attr_accessor :level
    attr_accessor :level_save
    attr_accessor :exp
    attr_accessor :skills_set   # Class Skill
    attr_accessor :atk_plus     # Effort Value
    attr_accessor :dfe_plus
    attr_accessor :spd_plus
    attr_accessor :ats_plus
    attr_accessor :dfs_plus
    attr_accessor :hp_plus
    # Statut_Variable
    attr_accessor :hp   # Stats en combat
    attr_accessor :atk
    attr_accessor :dfe
    attr_accessor :spd
    attr_accessor :ats
    attr_accessor :dfs
    attr_accessor :stats_manuel # [atk, dfe, spd, ats, dfs] remplacent les
                                # stats basiques lors d'une saisie manuel
                                # dans un script
    attr_accessor :status
    attr_accessor :status_count
    attr_accessor :confused
    attr_accessor :state_count  # pour confusion
    attr_accessor :flinch
    attr_accessor :effect       # Liste des effets au combat
    attr_accessor :ability_active # true/false
    attr_accessor :ability_token
    attr_accessor :item_hold      # ID objet tenu
    attr_accessor :save_item
    attr_accessor :save_ability
    attr_accessor :save_transform
    attr_accessor :loyalty
    attr_accessor :battle_stage   # [atk, dfe, spd, ats, dfs, eva, acc]
    attr_accessor :bonus # Bonus d'atk / dfe / spd / ats / dfs en combat
    attr_accessor :ball_data           # Données des balls avant PSPEvolved - A conserver pour rendre compatible les sauvegardes (<= PSP 0.9.4)
    attr_accessor :id_ball          # Identifiant de la ball dans lequel le Pokémon est enfermé
    attr_accessor :rate_loyalty   # Augmentation du bonheur à chaque pas
    attr_accessor :step_remaining      # pas restants avant éclosion
    attr_accessor :form                # Le numéro de la forme alt
    attr_accessor :mega
    attr_accessor :round # Le nombre de round passé en combat sans switch
    attr_accessor :critical_base # Taux de coup critique de base
    # CAS DE LA CAPACITE SPECIALE : Illusion
    attr_accessor :name_before_illusion
    attr_accessor :gender_before_illusion
    attr_accessor :name_enemy
    attr_accessor :illusion
    attr_accessor :is_anime # Permet de savoir si le pokémon est en cours d'animation (système de combat)
    #------------------------------------------------------------  
    # Créer un Pokémon: 
    #         @pokemon = Pokemon.new(id, level, shiny)
    # Appel d'une commande attr_accessor:
    #         @pokemon.accessor
    # Assignation:
    #         @pokemon.accessor = value
    # Commandes_d'appel du type poke = Pokemon.new(id), poke.commande
    # poke.maxhp_basis, poke.sta_basis
    #------------------------------------------------------------
    
    #------------------------------------------------------------
    # Création d'un Pokémon
    #------------------------------------------------------------
    #------------------------------------------------------------
    # Modèle invariant / Archetype
    #------------------------------------------------------------
    def archetype(id)
      @base_hp = Pokemon_Info.base_hp(id)
      @base_atk = Pokemon_Info.base_atk(id)
      @base_dfe = Pokemon_Info.base_dfe(id)
      @base_spd = Pokemon_Info.base_spd(id)
      @base_ats = Pokemon_Info.base_ats(id)
      @base_dfs = Pokemon_Info.base_dfs(id)
      @skills_table = skill_table_building
      @skills_allow = Pokemon_Info.skills_tech(id)
      @exp_type = Pokemon_Info.exp_type(id)
      @type1 = Pokemon_Info.type1(id)
      @type2 = Pokemon_Info.type2(id)
      @rareness = Pokemon_Info.rareness(id)
      @male_rate = 100 - Pokemon_Info.female_rate(id)
      @female_rate = Pokemon_Info.female_rate(id)
      @battle_list = Pokemon_Info.battle_list(id)
      @battler_id = id
      @ability = ability_conversion
    end
    
    # Renvoie le nom du Pokémon ennemie par défaut
    # Ou la valeur @name_enemy si non nul (nom spécial pour le pokémon ennemie)
    def name
      if @egg
        return "OEUF"
      end
      if @name_enemy != nil
        return @name_enemy
      end #else
      return Pokemon_Info.name(id)
    end
    
    # Définit un nom spécial pour le pokémon ennemie
    # value : la valeur du nom spécial
    def name_enemy=(value)
      @name_enemy = value
    end
    
    def description
      return Pokemon_Info.descr(id, @form, @mega)
    end
         
    def cry
      if @egg
        return ""
      end
      ida = sprintf("%03d", id)
      cry = "Audio/SE/Cries/#{ida}Cry.wav"
      return cry
    end
    
    def hatch_step
      return Pokemon_Info.hatch_step(id)
    end
    
    def breed_move
      return Pokemon_Info.breed_move(id)
    end
    
    def breed_group
      return Pokemon_Info.breed_group(id)
    end

    def is_anime
      @is_anime ||= false
    end

    def form=(value)
      @form = value
      alt_movepool(true)
    end

    def mega
      mega ||= 0
    end
  
    def initialize(id_data = 1, level = 1, shiny = false, no_shiny = false, trainer = Player)
      if id_data.is_a?(Fixnum)
        id = id_data
      elsif id_data.is_a?(String)
        id = id_conversion(id_data)
      end
      @rate_loyalty = 1
      @id = id
      @id_bis = Pokemon_Info.id_bis(id)
      @trainer_id = (trainer == Player) ? trainer.id : trainer
      @trainer_name = (trainer == Player) ? trainer.name : Trainer_Info.name(trainer)
      @code = code_generation
      @male_rate = 100 - Pokemon_Info.female_rate(id)
      @female_rate = Pokemon_Info.female_rate(id)
      @gender = gender_generation
      @round = 0
      if shiny or no_shiny # Shiny forcé (ou bloqué)
        @shiny = (not no_shiny)
      else
        a = @code 
        a ^= Player.code if trainer == Player
        b = a & 0xFFFF
        c = (a >> 16) & 0xFFFF
        d = b ^ c
        @shiny = d < 8
        #charme chroma
        if not @shiny #$pokemon_party.item_number(222) > 0 and not @shiny
          @code = code_generation
          a = @code 
          a ^= Player.code if trainer == Player
          b = a & 0xFFFF
          c = (a >> 16) & 0xFFFF
          d = b ^ c
          @shiny = d < 8
        end
      end
      archetype(id)
      @dv_hp = rand(32)
      @dv_atk = rand(32)
      @dv_dfe = rand(32)
      @dv_spd = rand(32)
      @dv_ats = rand(32)
      @dv_dfs = rand(32)
      if @shiny
        @dv_hp = @dv_hp>16 ? 31 : @dv_hp += 15
        @dv_atk = @dv_atk>16 ? 31 : @dv_atk += 15
        @dv_dfe = @dv_dfe>16 ? 31 : @dv_dfe += 15
        @dv_spd = @dv_spd>16 ? 31 : @dv_spd += 15
        @dv_ats = @dv_ats>16 ? 31 : @dv_ats += 15
        @dv_dfs = @dv_dfs>16 ? 31 : @dv_dfs += 15
      end
      @hp_plus = 0
      @atk_plus = 0
      @dfe_plus = 0
      @ats_plus = 0
      @dfs_plus = 0
      @spd_plus = 0
      @given_name = name.clone
      @level = level == 0 ? 1 : level
      @exp = exp_list[@level]
      @skills_set = []
      @status = 0
      @status_count = 0
      @item_hold = 0 #id item
      @loyalty = Pokemon_Info.base_loyalty(id)
      @loyalty += 100
      @nature = nature_generation
      @ability = ability_conversion
      initialize_skill
      reset_stat_stage
      @hp = maxhp_basis
      @id_ball = Pokemon_Object_Ball.get_id(:poke_ball)
      @effect = []
      @effect_count = []
      @ability_active = false
      @ability_token = nil
      @egg = false
      @step_remaining = 0
      @form = 0
    end
    
    #------------------------------------------------------------
    # Création du code d'identification du Pokémon (32 bits)
    #------------------------------------------------------------
    def code_generation
      return rand(2**32)
    end
    
    #------------------------------------------------------------
    # Gestion du nom
    #------------------------------------------------------------
    # Conversion "nom" - > id
    # name : Le nom du Pokémon
    # Retourne l'ID du Pokémon
    def id_conversion(name)
      id = (1...$data_pokemon.size).find do |id|
        name.downcase_remove_accents == Pokemon_Info.name(id).downcase_remove_accents
      end
      if id != nil and name.downcase_remove_accents == Pokemon_Info.name(id).downcase_remove_accents
        return id
      end #else
      return 1
    end
    
    def change_name(name)
      @given_name = name
    end
    
    # Renvoie le vrai nom du Pokémon (utilisation du talent Illusion)
    def get_name
      return @name_before_illusion
    end
    
    # Saisit l'ancien nom du Pokémon lors de l'utilisation du talent Illusion
    # value : le vrai nom du Pokémon utilisant Illusion
    def last_name=(value)
      @name_before_illusion = value
    end

    #------------------------------------------------------------
    # Désignation du sexe
    #------------------------------------------------------------
    def gender_generation
      if @male_rate == 101
        return 0 #0 = genderless
      else
        low = @code % 256
        if low < (256 * @female_rate / 100)
          return 2
        else
          return 1
        end
      end
    end
    
    def gender=(gender)
      if gender == "F" or gender == 2
        return @gender = 2
      end
      if gender == "M" or gender == 1
        return @gender = 1
      end
      if gender == "I" or gender == 0
        return @gender = 0
      end
    end
    
    def male?
      return @gender == 1
    end
    
    def female?
      return @gender == 2
    end
    alias femelle? female?
    
    def genderless?
      return @gender == 0
    end
    alias sans_genre? genderless?
    
    # Renvoie le vrai sexe du Pokémon (utilisation du talent Illusion)
    def get_gender
      return @gender_before_illusion
    end
    
    # Saisit l'ancien nom du Pokémon lors de l'utilisation du talent Illusion
    # value : le vrai nom du Pokémon utilisant Illusion
    def last_gender=(value)
      @gender_before_illusion = value
    end
    
    #------------------------------------------------------------
    # Gestion du shiny
    #------------------------------------------------------------
    def get_shiny
      return @shiny
    end
    
    def nature_force(nature)
      hash_nature = {
                      "hardi" => 0,
                      "solo" => 1,
                      "brave" => 2,
                      "rigide" => 3,
                      "mauvais" => 4,
                      "assuré" => 5,
                      "docile" => 6,
                      "relax" => 7,
                      "malin" => 8,
                      "lâche" => 9,
                      "timide" => 10,
                      "pressé" => 11,
                      "sérieux" => 12,
                      "jovial" => 13,
                      "naïf" => 14,
                      "modeste" => 15,
                      "doux" => 16,
                      "discret" => 17,
                      "bizarre" => 18,
                      "foufou" => 19,
                      "calme" => 20,
                      "gentil" => 21,
                      "malpoli" => 22,
                      "prudent" => 23,
                      "pudique" => 24
                    }
      @nature = nature_generation(hash_nature[nature.downcase])
    end

    #------------------------------------------------------------
    # Désignation du caractère
    #------------------------------------------------------------
    def nature_generation(nature_code = -1) 
      nature_code = @code % 25 if nature_code < 0
      case nature_code #atk, dfe, vit, ats, dfs
      when 0
        return ["Hardi", 100,100,100,100,100]
      when 1
        return ["Solo", 110,90,100,100,100]
      when 2
        return ["Brave", 110,100,90,100,100]        
      when 3
        return ["Rigide", 110,100,100,90,100]
      when 4
        return ["Mauvais", 110,100,100,100,90]
      when 5
        return ["Assuré", 90,110,100,100,100]
      when 6
        return ["Docile", 100,100,100,100,100]
      when 7
        return ["Relax", 100,110,90,100,100]
      when 8
        return ["Malin", 100,110,100,90,100]
      when 9
        return ["Lâche", 100,110,100,100,90]
      when 10
        return ["Timide", 90,100,110,100,100]
      when 11
        return ["Pressé", 100,90,110,100,100]
      when 12
        return ["Sérieux", 100,100,100,100,100]
      when 13
        return ["Jovial", 100,100,110,90,100]
      when 14
        return ["Naïf", 100,100,110,100,90]
      when 15
        return ["Modeste", 90,100,100,110,100]
      when 16
        return ["Doux", 100,90,100,110,100]
      when 17
        return ["Discret", 100,100,90,110,100]
      when 18
        return ["Bizarre", 100,100,100,100,100]
      when 19
        return ["Foufou", 100,100,100,110,90]
      when 20
        return ["Calme", 90,100,100,100,110]
      when 21
        return ["Gentil", 100,90,100,100,110]
      when 22
        return ["Malpoli", 100,100,90,100,110]
      when 23
        return ["Prudent", 100,100,100,90,110]
      when 24
        return ["Pudique", 100,100,100,100,100]
      end
    end
    
    # Renvoie la nature du pokemon
    def get_nature
      return @nature[0]
    end
    
    #------------------------------------------------------------
    # Pokéball associée
    #------------------------------------------------------------
    def id_ball_conversion(name)
      id = (1...$data_item.size).find do |id|
        name.downcase_remove_accents == POKEMON_S::Item.name(id).downcase_remove_accents
      end
      if id != nil and name.downcase_remove_accents == POKEMON_S::Item.name(id).downcase_remove_accents
        return id
      end #else
      return 4 # ID POKé BALL
    end

    def rate_loyalty
      @rate_loyalty ||= 1
    end

    def id_ball
      @id_ball ||= id_ball_conversion(@ball_data[0])
    end

    def ball_sprite      
      return Pokemon_Object_Ball.sprite_name(id_ball)
    end
    
    def ball_open_sprite
      return Pokemon_Object_Ball.open_sprite_name(id_ball)
    end
    
    def ball_color
      return Pokemon_Object_Ball.color(id_ball)
    end
    
    #------------------------------------------------------------
    # Item associé
    #------------------------------------------------------------
    def item_name
      return POKEMON_S::Item.name(@item_hold)
    end
  end
end