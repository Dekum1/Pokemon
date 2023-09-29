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
  # Méthodes sur les oeufs et les formes du Pokemon :
  # - Gestion des Oeufs
  # - Réduit les pas avant éclosion
  # - Retourne la forme basique d'un Pokémon
  # - Gestion de la copie : ILLUSION
  #------------------------------------------------------------
  class Pokemon
    #--------------------------------------------------------------------------
    # Gestion des Oeufs
    #--------------------------------------------------------------------------
    
    # Initialisation
    def new_egg(mother = 1, father = nil)
      if mother.type == Fixnum or mother.type == String
        initialize(mother, 1)
      elsif mother.is_a?(Pokemon) and father.is_a?(Pokemon)
        # Règles spéciales pour l'ID du bébé
        # ( Voir script DAYCARE )
        
        # ID = Base mère
        baby_id = base_id(mother.id)
        
        # Cf Pokemon_Custom
        baby_id = breeding_custom_rules(baby_id, father, mother)
        initialize(baby_id, 1)
        @id_ball = [father, mother][rand(2)].id_ball
        
        # Réglage capa spé
        common_ability = (Pokemon_Info.ability_list(mother.id) & Pokemon_Info.ability_list(father.id))
        if common_ability.include?(mother.ability_name)
          @ability = mother.ability
        end
        
        # Réglages skills : skill connus en commun
        common_skills = mother.skills & father.skills
        common_skills.each do |skill|
          if @skills_table.assoc(skill) != nil
            @skills_set.push(Skill.new(skill))
          end
        end
        
        # Réglages skills : skill en ct/cs connus par le père
        father.skills.each do |skill|
          if @skills_allow.include?(skill)
            @skills_set.push(Skill.new(skill))
          end
        end
        
        # Réglages skills : skill par accouplement connus par le père 
        common_breed_skills = breed_move & father.skills
        common_breed_skills.each do |skill|
          @skills_set.push(Skill.new(skill))
        end
        
        # On garde les 4 derniers
        if @skills_set.length > 4
          @skills_set = @skills_set[-4..-1]
        end
        
        # Heritage des DV
        dv_list = []
        while dv_list.length < 3
          dv_list.push(rand(6))
          dv_list.uniq!
        end
        dv_list.each do |dv|
          parent = rand(2) == 0 ? mother : father
          case dv
          when 0
            @dv_hp = parent.dv_hp
          when 1
            @dv_atk = parent.dv_atk
          when 2
            @dv_dfe = parent.dv_dfe
          when 3
            @dv_spd = parent.dv_spd
          when 4
            @dv_ats = parent.dv_ats
          when 5
            @dv_dfs = parent.dv_dfs
          end
        end
      else
        return self
      end
      @egg = true
      @given_name = name
      @step_remaining = hatch_step
      return self
    end
    
    #--------------------------------------------------------------------------
    # Réduit les pas avant éclosion
    #--------------------------------------------------------------------------
    def decrease_step
      if not @egg
        return
      end
      @step_remaining -= 1
      if @step_remaining <= 0
        scenebis = Pokemon_Evolve.new(self, @id)
        scenebis.main
        Graphics.transition
      end
    end
    
    #--------------------------------------------------------------------------
    # Retourne la forme basique d'un Pokémon
    #--------------------------------------------------------------------------
    def base_id(mother_id)
      finish = false
      current_id = mother_id
      while not finish
        back = false
        1.upto($data_pokemon.size - 1) do |i|
          list = Pokemon_Info.evolve_table(i).flatten
          if list.include?(Pokemon_Info.name(current_id))
            current_id = i
            back = true
            break
          end
        end
        if not back
          finish = true
        end
      end
      return current_id
    end
    
    #------------------------------------------------------------
    # Gestion de la copie : ILLUSION
    #------------------------------------------------------------ 
    # Renvoie les détails du pokémon copié pour un pokémon utilisant
    # le talent illusion
    def get_illusion
      return @illusion
    end
    
    # Donne les détails du pokémon copié pour un pokémon utilisant le talent
    # illusion
    # value : les détails du pokémon copié
    def illusion=(value)
      @illusion = value
    end
  end
end