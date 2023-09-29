#==============================================================================
# ● Base de données - Compétences
# Pokemon Script Project - Krosk 
# Load_Skill - Damien Linux
# 14/11/2020
#==============================================================================

module POKEMON_S
  class Load_Data
    class Load_Skill
      class << self
        def load
          # -------------------------------------------------------------
          # Conversion BDD -> Script
          # -------------------------------------------------------------
          $data_skills = load_data("Data/Skills.rxdata")
          $data_skills_pokemon = Array.new($data_skills.length)
          1.upto($data_skills.length - 1) do |id|
            skill = $data_skills[id]
            $data_skills_pokemon[id] = []
            # Nom
            $data_skills_pokemon[id].push(skill.name) 
            # Power(Base_damage) : Attaque + Evasion
            $data_skills_pokemon[id].push(skill.atk_f + skill.eva_f) 
            # Type (sans type: 0)
            if skill.element_set[0] != nil
              $data_skills_pokemon[id].push(skill.element_set[0]) # Type
            else
              $data_skills_pokemon[id].push(0)
            end
            # Accuracy
            $data_skills_pokemon[id].push(skill.hit) 
            # PPMax: Cout en SP
            $data_skills_pokemon[id].push(skill.sp_cost) 
            # Effect_chance: Défense physique
            $data_skills_pokemon[id].push(skill.pdef_f) 
            # ID de l'Effet: Taux d'effet
            $data_skills_pokemon[id].push(skill.power) # Effect id
            # Target
            case skill.scope 
            when 0
              $data_skills_pokemon[id].push(1) # Aucun
            when 1
              $data_skills_pokemon[id].push(0) # Un ennemi
            when 2
              $data_skills_pokemon[id].push(8) # Tous les ennemis
            when 3
              $data_skills_pokemon[id].push(4) # Un allié
            when 4
              $data_skills_pokemon[id].push(20) # Tous les alliés
            when 5
              $data_skills_pokemon[id].push(40) # Spécial (Allié mort)
            when 6
              $data_skills_pokemon[id].push(40) # Spécial (Alliés morts)
            when 7
              $data_skills_pokemon[id].push(10) # Utilisateur
            end
            # Capacité directe Variance != 0
            $data_skills_pokemon[id].push(skill.variance != 0)
            # Tag priorité
            $data_skills_pokemon[id].push(skill.mdef_f)
            # Tag event commun
            $data_skills_pokemon[id].push(skill.common_event_id)
            # Description
            $data_skills_pokemon[id].push(skill.description) 
            # Animation utilisateur
            $data_skills_pokemon[id].push(skill.animation1_id) 
            # Animation cible
            $data_skills_pokemon[id].push(skill.animation2_id) 
            # Physique / Special / Status
            $data_skills_pokemon[id].push(skill.str_f)
            # Capacité aura dex_f != 0
            $data_skills_pokemon[id].push(skill.dex_f != 0)
            # Capacité sonore agi_f != 0
            $data_skills_pokemon[id].push(skill.agi_f != 0)     
          end
        end
      end
    end
  end
end