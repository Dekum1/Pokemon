#==============================================================================
# ● Base de données - Compétences
# Pokemon Script Project - Krosk 
# Mis à jour par Damien Linux
# 14/11/2020
#==============================================================================
module POKEMON_S
  class Skill_Info
    class << self
      def id(skill_name)
        1.upto($data_skills_pokemon.length - 1) do |i|
          return i if skill_name.downcase_remove_accents == name(i).downcase_remove_accents
        end
        return 1
      end
        
      # Renvoie le nom de l'attaque sélectionné
      # id : id de l'attaque
      def name(id)
        return $data_skills_pokemon[id][0]
      end
        
      # Renvoie les dommages de l'attaque sélectionné
      # id : id de l'attaque
      def base_damage(id)
        return $data_skills_pokemon[id][1]
      end
        
      # Renvoie le type de l'attaque sélectionné
      # id : id de l'attaque
      def type(id)
        return $data_skills_pokemon[id][2]
      end
        
      # Renvoie la précision de l'attaque sélectionné
      # id : id de l'attaque
      def accuracy(id)
        return $data_skills_pokemon[id][3]
      end
      
      # Renvoie les chances de réussite de l'attaque sélectionné
      # id : id de l'attaque
      def effect_chance(id)
        return $data_skills_pokemon[id][5]
      end
        
      # Renvoie un nombre en hexadécimal associé à un effet
      # dans Battle Core de l'attaque sélectionné
      # id : id de l'attaque
      def effect(id)
        return $data_skills_pokemon[id][6]
      end
        
      # Renvoie la cible de l'attaque sélectionné
      # id : id de l'attaque
      def target(id)
        return $data_skills_pokemon[id][7]
      end
        
      def tag(id)
        return $data_skills_pokemon[id][8]
      end
        
      # Retourne pour l'attaque en question, l'attribut agilité de la BDD
      def agi_f(id)
        return $data_skills_pokemon[id][16]
      end
        
      # Retourne pour l'attaque en question, l'attribut dextérité de la BDD
      def dex_f(id)
        return $data_skills_pokemon[id][15]
      end
      
      # Renvoie la priorité de l'attaque sélectionné
      # id : id de l'attaque
      def priority(id)
        return $data_skills_pokemon[id][9]
      end
        
      def map_use(id)
        return $data_skills_pokemon[id][10]
      end
        
      # Renvoie la description de l'attaque sélectionné
      # id : id de l'attaque
      def description(id)
        return $data_skills_pokemon[id][11]
      end
        
      # Renvoie l'id de l'animation de l'utilisateur de l'attaque sélectionné
      # id : id de l'attaque
      def user_anim_id(id)
        return $data_skills_pokemon[id][12]
      end
        
      # Renvoie l'id de l'animation sur la cible de l'attaque sélectionné
      # id : id de l'attaque
      def target_anim_id(id)
        return $data_skills_pokemon[id][13]
      end
        
      def kind(id)
        return $data_skills_pokemon[id][14]
      end
          
      def effet(id)
        return $game_data_skills[id][X]
      end
        
      def effect_name(id)
        $effets[effet(id)]
      end
    end
  end
end