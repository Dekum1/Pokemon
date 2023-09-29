#==============================================================================
# ■ Pokemon
# Pokemon Script Project - Krosk 
# 20/07/07
# 26/08/08 - révision, support des oeufs
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré et complété par Damien Linux
# 04/11/19
#-----------------------------------------------------------------------------
# Gestion individuelle
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # class Pokemon : génère l'information sur un Pokémon.
  # Méthodes sur les compétences du Pokémon :
  # - Liste des compétences - autorisation et compétence sélectionnée
  # - Création de la table d'expérience / table des skills
  # - Désignation de la Capacité spéciale
  # - Gestion des compétences
  # - Oublier une compétence par son numéro de place
  # - Apprentissage d'une compétence
  # - Remplacer une compétence
  # - Initialisation - Actualisation - Utilisation forcée d'une compétence
  # - Liste des compétences
  # - Effets spéciaux des attaques
  #------------------------------------------------------------
  class Pokemon
    #------------------------------------------------------------
    # Liste des compétences - autorisation et compétence sélectionnée
    #------------------------------------------------------------
    def skills_allow
      return Pokemon_Info.skills_tech(id)
    end
    
    def skills # équivalent de skills_set, mais avec les id seulement
      list = []
      if @egg
        return list
      end
      @skills_set.each do |skill|
        list.push(skill.id)
      end
      return list
    end
    
    def ss(index)
      return @skills_set[index]
    end

    # Donne les attaques que doit posséder le Pokémon
    # moves : Les attaques mises sous forme de Tableau [attaque1, attaque2, ...]
    def set_skills(moves)
      i = 0
      moves.each do |skill|
        if skill != nil and skill != "AUCUN"
          @skills_set[i] = Skill.new(Skill_Info.id(skill))
        elsif skill == "AUCUN"
          @skills_set[i] = nil
        end
        i += 1
      end
      @skills_set.compact!
    end
    
    #------------------------------------------------------------
    # Création de la table d'expérience / table des skills
    #------------------------------------------------------------    
    def exp_list
      return EXP_TABLE[@exp_type]
    end
        
    def skill_table_building
      list = []
      if Pokemon_Info.skills_list(id).length != 0
        taille = Pokemon_Info.skills_list(id).length/2 - 1
        0.upto(taille) do |i|
          # [id skill, level skill], ...
          list.push([Pokemon_Info.skills_list(id)[2*i+1], Pokemon_Info.skills_list(id)[2*i]])
        end
      end
      return list
    end
    
    #------------------------------------------------------------
    # Désignation de la Capacité spéciale
    #------------------------------------------------------------
    def ability_conversion
      # Une seule capa. spéciale  ou code paire
      if Pokemon_Info.ability_list(id)[1] == nil or @code.even? 
        ability_string = Pokemon_Info.ability_list(id)[0]
      elsif @code.odd? and Pokemon_Info.ability_list(id)[1] != nil
        ability_string = Pokemon_Info.ability_list(id)[1]
      end
      list = []
      1.upto($data_ability.length - 1) do |i|
        list.push($data_ability[i][0]) # Noms
      end
      id = list.index(ability_string)
      return id + 1
    end
    
    def ability_name
      return $data_ability[@ability][0]
    end
    
    def ability_descr
      return $data_ability[@ability][1]
    end
    
    # Renvoie l'ID de la capacité spéciale
    def ability_id
      return $data_ability[@ability][2]
    end
    
    # Détermine l'ID de l'effet du talent
    def ability_symbol
      return ID_ABILITY[ability_id]
    end
    
    #------------------------------------------------------------
    # Gestion des compétences
    #------------------------------------------------------------
    #------------------------------------------------
    # $data_skills_pokemon[id] = [
    #   "Nom",
    #   dommages de base,
    #   type,
    #   précision %,   
    #   pp,max
    #   special %,
    # ]
    #------------------------------------------------
    # Apprendre une compétence-
    def learn_skill(id_data)
      if id_data.type == Fixnum
        id = id_data
      elsif id_data.type == String
        id = Skill_Info.id(id_data)
      end
      if not(skills.include?(id)) and @skills_set.length < 4
        @skills_set.push(Skill.new(id))
        return true
      end
      return false
    end
    
    #------------------------------------------------------------
    # Oublier une compétence par son numéro de place
    #------------------------------------------------------------
    def forget_skill_index(index) # De 0 à 3
      if skills[index] != nil
        @skills_set.delete_at(index)
      end
    end
    
    def forget_skill(id_data)
      if id_data.type == Fixnum
        id = id_data
      elsif id_data.type == String
        id = Skill_Info.id(id_data)
      end
      index = skills.index(id)
      if index != nil
        forget_skill_index(index)
      end
    end   
    
    #------------------------------------------------------------
    # Apprentissage d'une compétence
    #------------------------------------------------------------
    def convert_skill(learnt, learning)
      if learnt.type == String
        learnt_id = Skill_Info.id(learnt)
      elsif learnt.type == Fixnum
        learnt_id = learnt
      end
      if learning.type == String
        learning_id = Skill_Info.id(learning)
      elsif learning.type == Fixnum
        learning_id = learning
      end
      index = skills.index(learnt_id)
      @skills_set[index] = Script.new(learning_id)
    end
    
    #------------------------------------------------------------
    # Commandes supplémentaires:
    # @pokemon.skill_learn?(id)
    #       renvoie true/false
    # @pokemon.initialize_skill
    #       Crèe les compétences naturelles
    #       Ecrase les compétences de bas niveau!
    #------------------------------------------------------------      
    def skill_learnt?(id_data)
      if id_data.type == Fixnum
        id = id_data
      elsif id_data.type == String
        id = Skill_Info.id(id_data)
      end
      return skills.include?(id)
    end
    
    #------------------------------------------------------------
    # Remplacer une compétence
    #------------------------------------------------------------
    #------------------------------------------------------------
    # replace_skill_index(index, id_data)
    #   index = index du skill dans les attaques
    #   id_data = nom/ID du skill à mettre
    #------------------------------------------------------------
    def replace_skill_index(index, id_data)
      if id_data.type == String
        id = Skill_Info.id(id_data)
      elsif id_data.type == Fixnum
        id = id_data
      end
      @skills_set[index] = Skill.new(id)
    end
    
    #------------------------------------------------------------
    # Initialisation - Actualisation - Utilisation forcée d'une compétence
    #------------------------------------------------------------
    def initialize_skill
      @skills_table.each do |skill|
        if skill[1] <= @level and @skills_set.length < 4
          learn_skill(skill[0])
        elsif skill[1] <= @level and @skills_set.length == 4
          forget_skill_index(0)
          learn_skill(skill[0])
        end
      end
    end
    
    def refresh_skill(backscene = nil)
      @skills_table.each do |skill|
        if skill[1] == @level and not(skill_learnt?(skill[0]))
          scene = Pokemon_Skill_Learn.new(self, skill[0], backscene)
          scene.main
        end
      end
    end
    
    def force_skill(list)
      @skills_set = []
      list.each do |id|
        if id.type == Fixnum
          skill = Skill.new(id)
          @skills_set.push(skill)
        end
        if id.type == String
          skill = Skill.new(Skill_Info.id(id))
          @skills_set.push(skill)
        end
      end
    end
    
    #------------------------------------------------------------
    # Liste des compétences
    #------------------------------------------------------------
    # ------------------------------------------------------
    # skill_selection
    #   Permet d'ouvrir une fenêtre de sélection d'un skill.
    #   Renvoie -1, ou l'index du de l'attaque (0 pour le premier,
    #   1 pour le suivant, 2 pour le suisuivant...
    # ------------------------------------------------------
    def skill_selection
      scene = Pokemon_Skill_Selection.new(self)
      scene.main
      data = scene.return_data
      scene = nil
      $game_variables[5] = data
      return data
    end
    
    #------------------------------------------------------------    
    # Effets spéciaux des attaques
    #------------------------------------------------------------ 
    # @effect: liste des effets
    def skill_effect(id, duration = -1, data = nil)
      # [ effet, compteur de tours] -1 si temps indéfini
      @effect.push([id, duration, data])
    end
    
    def effect_list
      list = []
      @effect.each do |effect|
        list.push(effect[0])
      end
      return list
    end
    
    # Réduction des compteurs à effets
    def skill_effect_end_turn
      0.upto(@effect.length - 1) do |i|
        @effect[i][1] -= 1
      end
    end
    
    def skill_effect_clean
      0.upto(@effect.length - 1) do |i|
        if @effect[i] != nil          
          if @effect[i][1] == 0
            @effect.delete_at(i)
          end
        else
          @effect.delete_at(i)
        end
      end
    end
    
    def skill_effect_reset
      @effect = []
      @skills_set.each do |skill|
        skill.enable
      end
    end
  end
end