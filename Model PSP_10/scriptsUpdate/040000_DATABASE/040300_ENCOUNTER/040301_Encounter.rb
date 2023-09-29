#==============================================================================
# ● Base de données - Pokémon sauvages
# Pokemon Script Project - Krosk 
# Encounter - Damien Linux
# 14/11/2020
#==============================================================================
module POKEMON_S
  class Encounter
    attr_accessor :id # ID de l'Encounter
    attr_accessor :id_page # ID de l'event-page
    attr_accessor :tag_terrain # Le terrain sur lequel l'apparition peut avoir lieu (0 si tout terrain)
    attr_accessor :tag_horaire # 0 : apparition par défaut si aucune précision horaire
                               # J : apparition de jour exclusivement
                               # N : apparition de nuit exclusivement
                               # un entier a : l'heure a d'apparition
                               # [h_début,h_fin] : appariton dans une fourchette horaire
    attr_accessor :info_pokemon # Info des Pokémon sauvages du groupe
    attr_accessor :condition # Condition pour que l'apparition puisse avoir lieu (n° de l'interrupteur) => 0 si indéfini
    attr_accessor :difference # défini l'écart que possède les Pokémon par défaut

    class << self
      def index_page(id)
        if $game_variables
          index = $game_variables[INDEX_WILD_BATTLE] - 1
          if index > 0 and $data_encounter[id][index] != nil
            return index
          end #else
        end #else
        return 0 # Page 1
      end
    end

    # Construction de Encounter
    # id : numéro d'ID du groupe
    # id_page : numéro de la page
    def initialize(id, id_page)
      @id = id
      @id_page = id_page
      @tag_terrain = 0
      @tag_horaire = 0
      @info_pokemon = []
      @condition = 0
      @difference = 1 # Niv max = niv min
    end

    # Ajout d'un Pokémon avec les données saisies côté BDD
    # id : L'ID du Pokémon ajouté
    # infos : Les informations du Pokémon
    def add_pokemon(id, infos)
      @info_pokemon.push(Wild_Info.new(id, infos, @difference))
    end

    # Met à jour la rarité de chaque Pokémon afin d'avoir un score sur une base (en cas de total inférieur ou supérieur)
    # base : la base sur laquelle les pourcentages sont basées (par défaut n/100)
    def adaptation_rarity(base = 100)
      total = 0
      0.upto(@info_pokemon.size - 1) do |i|
        unless @info_pokemon[i].rarity
          @info_pokemon[i].rarity = Integer(100 / @info_pokemon.size)
        end
        total += @info_pokemon[i].rarity
      end
      # Met à jour la rarité par un produit en croix :
      # Rarité des pokémon donnent total
      # X rarité inconnu des pokémon donnent base
      # X = Rarité connu * base / total
      0.upto(@info_pokemon.size - 1) do |i|
        @info_pokemon[i].rarity = Integer((@info_pokemon[i].rarity * base) / total)
      end
    end
  end
end