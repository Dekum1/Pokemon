#==============================================================================
# ● Base de données - Compétences
# Pokemon Script Project - Krosk 
# Mis à jour par Damien Linux
# 14/11/2020
#==============================================================================
module POKEMON_S
    #------------------------------------------------
  # Class Skill - Skill individuel
  #------------------------------------------------
  class Skill
    attr_reader :id
    attr_reader :ppmax
    attr_reader :ppinit
    attr_reader :physical #Type physique
    attr_reader :special  #Type special
    attr_accessor :pp
    attr_accessor :usable

    #------------------------------------------------
    # Initalize - Génération d'un Skill - Skill.new(id)
    #------------------------------------------------
    # $data_skills_pokemon[id] = [
    #   Nom,
    #   Base_damage,
    #   Type,
    #   Précision (en %),
    #   PPmax
    #   Special (en %),
    #   Special_id (id de fonction)
    #   Cible
    #   Tag
    #   Descr   
    #   Animation utilisateur
    #   Animation cible
    # ]
    #------------------------------------------------
    # target: 
    #   00: Opposant simple choisi
    #   01: Pas de cible
    #   04: Opposant simple choisi au hasard
    #   10: User
    #   20: Tous les non-users
    #   40: Special
    #------------------------------------------------
    def initialize(id)
      @id = id
      @ppmax = $data_skills_pokemon[id][4]
      @ppinit = $data_skills_pokemon[id][4]
      @pp = @ppmax.to_i
      @usable = true
      define_type # Physique ou Special
    end
    
    #------------------------------------------------
    #   Renvoie le nom de l'attaque courante
    #------------------------------------------------
    def name
      return Skill_Info.name(id).capitalize
    end
    
    #------------------------------------------------
    #   Renvoie les domages de l'attaque courante
    #------------------------------------------------
    def power
      return Skill_Info.base_damage(id)
    end
    
    #------------------------------------------------
    #   Renvoie le type de l'attaque courante
    #------------------------------------------------
    def type
      return Skill_Info.type(id)
    end
    
    #------------------------------------------------
    #   Renvoie la précision de l'attaque courante
    #------------------------------------------------
    def accuracy
      return Skill_Info.accuracy(id)
    end
    
    #--------------------------------------------------------
    #   Renvoie la chance de réussite de l'attaque courante
    #--------------------------------------------------------
    def effect_chance
      return Skill_Info.effect_chance(id)
    end
    
    #-------------------------------------------------------------------------------------
    #   Renvoie le nombre associé à la valeur d'un effet dans Battle Core
    #-------------------------------------------------------------------------------------
    def effect
      return Skill_Info.effect(id)
    end
    
    #-------------------------------------------------------------------------------------
    #   Renvoie le symbole associé à la valeur d'un effet dans Battle Core
    #-------------------------------------------------------------------------------------
    def effect_symbol
      return ID_EFFECTS[Skill_Info.effect(id)]
    end
    
    #--------------------------------------------------------
    #   Renvoie la cible de l'attaque courantes
    #--------------------------------------------------------
    def target
      return Skill_Info.target(id)
    end
    
    #--------------------------------------------------------
    #   Donne la description de l'attaque courante
    #--------------------------------------------------------
    def description
      return Skill_Info.description(id)
    end
    
    #--------------------------------------------------------------------
    #   Donne l'ID de l'animation de l'utilisateur de l'attaque courante
    #--------------------------------------------------------------------
    def user_anim_id
      return Skill_Info.user_anim_id(id)
    end
    
    #--------------------------------------------------------------------
    #   Donne l'ID de l'animation sur la cible de l'attaque courante
    #--------------------------------------------------------------------
    def target_anim_id
      return Skill_Info.target_anim_id(id)
    end
    
    # Renvoie true s'il s'agit d'une capacité directe sinon false
    def direct?
      return Skill_Info.tag(id)
    end
    
    # Renvoie true s'il s'agit d'une capacité sonore sinon false
    def sonore?
      return Skill_Info.agi_f(id)
    end
    
    # Renvoie true s'il s'agit d'une capacité aura sinon false
    def aura?
      return Skill_Info.dex_f(id)
    end
    
    
    def priority
      return Skill_Info.priority(id)
    end
    
    def map_use
      return Skill_Info.map_use(id)
    end
    
    #--------------------------------------------------------
    #   Détermine s'il s'agit d'une attaque physique
    #--------------------------------------------------------
    def physical
      return Skill_Info.kind(id) == 0 if ATTACKKIND
      return @physical
    end
    
    #--------------------------------------------------------
    #   Détermine s'il s'agit d'une attaque spéciale
    #--------------------------------------------------------

    def special
      return Skill_Info.kind(id) == 1 if ATTACKKIND
      return @special
    end
    
    #--------------------------------------------------------------
    #   Détermine s'il s'agit d'une attaque influençant le status
    #--------------------------------------------------------------
    def status
      return Skill_Info.kind(id) == 2 if ATTACKKIND
      return false
    end
    
    #------------------------------------------------
    # Fonctions de définition
    #------------------------------------------------    
    #  1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
    #  10 vol 11 psy 12insecte 13 roche 14 spectre 15 dragon 16 acier 17 tenebre    
    
    #--------------------------------------------------------
    #   Définie les types physiques et spéciaux
    #--------------------------------------------------------
    def define_type
      p = [1, 7, 8, 9, 10, 12, 13, 14, 16]
      s = [0, 2, 3, 4, 5, 6, 11, 15, 17]
      if p.include?(type)
        @physical = true
        @special = false
      elsif s.include?(type)
        @physical = false
        @special = true
      end
    end
    
    #--------------------------------------------------------
    #   Détermine la priorité de l'attaque courante
    #--------------------------------------------------------
    def define_priority_useless
      @priority = 0
      if [270].include?(@id) #coupd'main/helping hand
        @priority = 5
      end
      if [277, 289].include?(@id) #reflet magique / magic coat #saisie / snatch
        @priority = 4
      end
      if [182, 197, 203, 266].include?(@id)
        @priority = 3
      end
      if [98, 183, 245, 252].include?(@id)
        @priority = 1
      end
      if [233].include?(@id) #corps perdu/vital throw
        @priority = -1
      end
      if [264].include?(@id) #Mitra poing/focus punch
        @priority = -3
      end
      if [279].include?(@id) #vendetta/revenge
        @priority = -4
      end
      if [68, 243].include?(@id) #riposte/counter #voile miroir/mirror coat
        @priority = -5
      end
      if [18, 46].include?(@id) #cyclone /whirlwind - hurlement/roar
        @priority = -6
      end      
    end
    
    #------------------------------------------------
    # Fonctions pp
    #------------------------------------------------
    # Redonne tous les PP à une attaque
    def refill
      @pp = @ppmax
    end
    
    # Donne un certain nombre de PP à une attaque
    # value : la valeur des PP à ajouter
    def set_points(value)
      @pp = value
    end
    
    # Ajouter des PP Max à l'attaque courante
    # number : le nombre de PP max à ajouter
    def add_ppmax(number)
      @ppmax += number
    end
    
    # Définie les PP Max de l'attaque courante
    # number : le nombre de PP max de l'attaque
    def define_ppmax(number)
      @ppmax = number
    end
    
    # Supprime des PP Max à l'attaque courante
    def raise_ppmax
      if @ppmax < $data_skills_pokemon[id][4]*8/5
        @ppmax += $data_skills_pokemon[id][4]/5
      end
    end
    
    # Remet les PP de l'attaque courante à la même valeur que les PP Max
    def def_ppinit
      @ppinit = @ppmax
    end
    
    #------------------------------------------------
    # Fonctions d'activation
    #------------------------------------------------    
    
    # Enlève un PP à l'attaque courante quand elle est utilisée
    def use
      if @usable
        @pp -= 1
      end
    end
    
    # Renvoie true si l'attaque courante est utilisée sinon false
    def enabled?
      return @usable
    end
    
    # Dit que l'attaque courante n'est pas utilisé
    def disable
      @usable = false
    end
    
    # Dit que l'attaque courante est utilisée
    def enable
      @usable = true
    end
    
    # Détermine en fonction des PP si l'attaque courante est utilisable ou non
    def usable?
      if @pp <= 0
        return false
      end
      return @usable
    end
    
    #------------------------------------------------
    # Fonctions de simplification
    #------------------------------------------------    
    #  1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
    #  10 vol 11 psy 12insecte 13 roche 14 spectre 15 dragon 16 acier 17 tenebre    
    
    # Détermine si l'attaque est de type normal
    def type_normal?
      return type == 1
    end
    
    # Détermine si l'attaque est de type feu
    def type_fire?
      return type == 2
    end
    
    # Détermine si l'attaque est de type eau
    def type_water?
      return type == 3
    end
    
    # Détermine si l'attaque est de type électrique
    def type_electric?
      return type == 4
    end
    
    # Détermine si l'attaque est de type plante
    def type_grass?
      return type == 5
    end
    
    # Détermine si l'attaque est de type glace
    def type_ice?
      return type == 6
    end
    
    # Détermine si l'attaque est de type combat
    def type_fighting?
      return type == 7
    end
    
    # Détermine si l'attaque est de type poison
    def type_poison?
      return type == 8
    end
    
    # Détermine si l'attaque est de type sol
    def type_ground?
      return type == 9
    end
    
    # Détermine si l'attaque est de type vol
    def type_fly?
      return type == 10
    end
    
    # Détermine si l'attaque est de type psy
    def type_psy?
      return type == 11
    end
    
    # Détermine si l'attaque est de type insecte
    def type_insect?
      return type == 12
    end
    
    # Détermine si l'attaque est de type roche
    def type_rock?
      return type == 13
    end
    
    # Détermine si l'attaque est de type specte
    def type_ghost?
      return type == 14
    end
    
    # Détermine si l'attaque est de type dragon
    def type_dragon?
      return type == 15
    end
    
    # Détermine si l'attaque est de type acier
    def type_steel?
      return type == 16
    end
    
    # Détermine si l'attaque est de type ténèbre
    def type_dark?
      return type == 17
    end
    
    # Détermine si l'attaque est de type fée
    def type_fee?
      return type == 18
    end
  end
end