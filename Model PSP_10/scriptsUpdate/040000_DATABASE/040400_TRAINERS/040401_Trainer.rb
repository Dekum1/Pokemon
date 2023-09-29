#==============================================================================
# ● Base de données - Dresseurs
# Pokemon Script Project - Krosk 
# Trainer - Damien Linux
# 29/04/2020
#==============================================================================
module POKEMON_S
  # -----------------------------------------------------------------
  #   Classe décrivant un dresseur :
  #   - Ces informations (sprite / nom...)
  #   - Ces répliques (victoire / défaite / en combat) 
  #   - Les objets qu'il peut utiliser
  #   - L'argent qu'il possède
  #   - Son équipe Pokémon
  # -----------------------------------------------------------------
  class Trainer
    attr_accessor :id
    attr_accessor :battler
    attr_accessor :type_trainer
    attr_accessor :name
    attr_accessor :info_pokemon
    attr_accessor :objects
    attr_accessor :money
    attr_accessor :victory_texts
    attr_accessor :defeat_texts
    
    # Initialisation du dresseur
    # name : Le nom du dresseur
    # type_trainer : Le type de dresseur (exemple : RANGER)
    def initialize(id, name, type_trainer = "")
      @name = name.gsub(/\\[Nn]\[([0-9]+)\]/) do
        $data_actors[$1.to_i] != nil ? $data_actors[$1.to_i].name : ""
      end
      @id = id
      @type_trainer = type_trainer
      @info_pokemon = []
      @victory_texts = []
      @defeat_texts = []
      @objects = []
    end
    
    # Créer les informations d'un nouveau Pokémon et l'ajoute dans la liste de l'équipe
    # id : L'ID du Pokémon à créer
    # hash : Les informations du Pokémon à créer sous forme de hash
    def add_pokemon(id, hash)
      @info_pokemon.push(Trainer_Party_Actor.new(id, hash))
    end
    
    # Détermine si un pokémon existe à un certain emplacement de l'équipe
    # index : l'emplacement à vérifier
    # Renvoie true si le pokémon existe à l'emplacement spécifié
    #         false sinon
    def pokemon_exist?(index)
      return @info_pokemon[index] != nil
    end
  end
end