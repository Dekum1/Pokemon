#==============================================================================
# ● Base de données - Chargement des données
# Pokemon Script Project - Krosk 
# Load_Data - Damien Linux
# 14/11/2020
#==============================================================================
module POKEMON_S
  class Load_Data
    class << self
      def load_in_thread
        threads = []
        # Chargement des Pokémon existant
        threads.push(Thread.new { Load_Pokemon.load })
        # Chargement des compétences des Pokémon existantes
        threads.push(Thread.new { Load_Skill.load })
        # Chargement des groupes
        threads.push(Thread.new { Load_Group.load })
        threads.each { |thread| thread.join }
      end

      def load_component_with_dependencies_data
        threads = []
        # On charge les éléments nécessitant les éléments précédent
        # Chargement des objets
        threads.push(Thread.new { Load_Items.load })
        # Chargement des liens groupes - zones
        threads.push(Thread.new { Load_Group.load_infos_zone })
        threads.each { |thread| thread.join }
      end
    end
  end
end