#===============================================================================
# Pokemon Script Project - Krosk 
# Random_Encounter - G!n0
# 12/11/20
#-------------------------------------------------------------------------------
# Liste des rencontres rangées par terrain_tag
#    @terrains[tag] = [group1, group2...]
#    avec group1, group2... les groupes de rencontres, de classe Encounter
#===============================================================================

module POKEMON_S
  
  class Random_Encounter
    
    attr_accessor :terrains
    attr_accessor :rate
    attr_accessor :hour
    
    #----------------------------------------------------
    # Initialisation
    #----------------------------------------------------
    def initialize
      # Liste des rencontres par terrain_tag
      @terrains = Array.new(TAG_SYS::T_SIZE)
      # Fréquence
      @rate = 0
      # Repère horaire
      @hour = -1
    end
    
    #----------------------------------------------------
    # Réinitialisation de la liste des rencontres
    #----------------------------------------------------
    def reset
      @terrains = Array.new(TAG_SYS::T_SIZE)
      @rate = 0
    end
    
    #----------------------------------------------------
    # Mise à jour de la liste des rencontres
    #----------------------------------------------------
    def update
      # Réinitialisation de la liste des rencontre
      reset
      
      # Maj du repère horaire
      @hour = Time.now.hour
      
      # S'il n'y a pas de rencontre définie dans la map
      return if $game_map.encounter_list.empty?
      
      # Fréquence des réncontres
      @rate = (2880 / (16.0 * $game_map.encounter_step)).to_i
      
      # enc_controller[tag] : contrôler l'état de la liste
      # nil : vide, true : liste avec condition vérifiée, false : liste sans condition 
      enc_controller = Array.new(TAG_SYS::T_SIZE)
      
      # Ajout des listes de rencontre définie dans la map en cours
      $game_map.encounter_list.each do |list_id|
        # Groupe étudié
        group = $data_encounter[list_id][Encounter.index_page(list_id)]
        
        # Vérification de l'existence du groupe et de la validité de son tag
        next unless group and group.tag_terrain > 0
        # Vérification de switch
        next unless group.condition == 0 or $game_switches[group.condition]
        
        # Contrôler la condition horaire
        schedule = schedule_checking(group.tag_horaire[0], group.tag_horaire[1])
        next if schedule == 0
        
        tag = group.tag_terrain
        # Cas où on remplace le contenu de la liste des rencontres
        if !@terrains[tag] or (!enc_controller[tag] and schedule)
          @terrains[tag] = [group]
          enc_controller[tag] = schedule
        # Cas où on ajoute du contenu dans la liste des rencontres
        elsif !enc_controller[tag] or schedule
          @terrains[tag].push(group)
          enc_controller[tag] = schedule
        end
      end
    end
    
    #----------------------------------------------------
    # Vérifier une condition horaire
    # 0 : condition non vérifiée
    # true : condition vérifiée, false : sans condition
    #----------------------------------------------------
    def schedule_checking(h_begin, h_end)
      if h_begin < h_end
        return true if @hour >= h_begin and @hour < h_end
        return 0
      end
      if h_begin > h_end
        return true if @hour >= h_begin or @hour < h_end
        return 0
      end
      return false
    end
    
    #----------------------------------------------------
    # MAJ du repère horaire et de la liste des rencontres 
    # à chaque changement d'heure
    #----------------------------------------------------
    def hour_checking
      update if @hour != Time.now.hour
    end
    
    #----------------------------------------------------
    # Savoir si la liste des rencontres est vide
    #----------------------------------------------------
    def empty?
      return @terrains.empty?
    end
    
    #----------------------------------------------------
    # Accéder aux rencontres pour un terrain_tag
    #----------------------------------------------------
    def [](tag)
      return @terrains[tag]
    end
    
    #----------------------------------------------------
    # Modifier rencontres pour un terrain_tag
    #----------------------------------------------------
    def []=(tag, value)
      @terrains[tag] = value
    end
    
  end
  
end