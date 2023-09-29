#==============================================================================
# ● Base de données - Dresseurs
# Pokemon Script Project - Krosk 
# Trainer_Party_Actor - Damien Linux
# 27/11/2020
#==============================================================================
module POKEMON_S
  class Trainer_Party_Actor
    attr_accessor :id # L'ID du Pokémon
    attr_accessor :level # Le niveau du Pokémon
    attr_accessor :shiny # True si le Pokémon est shiny sinon false
    attr_accessor :no_shiny # True si le mode shiny n'est pas autorisé sinon false
    attr_accessor :item # ID de l'objet tenu par le Pokémon
    attr_accessor :ball # Ball du Pokémon
    attr_accessor :moves # Attaques du Pokémon
    attr_accessor :iv # IV (DV avant) du Pokémon
    attr_accessor :stats # Stats brut du Pokémon
    attr_accessor :ev # EV du Pokémon
    attr_accessor :ability # Talent du Pokémon
    attr_accessor :genre # Sexe du Pokémon
    attr_accessor :form # Numéro de forme du Pokémon
    attr_accessor :nature # Numéro de nature du Pokémon
    attr_accessor :loyalty # Taux de bonheur du Pokémon sur 255

    # Construction de Trainer_Party_Actor en recevant les informations de la BDD
    # id : L'ID du Pokémon
    # infos : Les informations fournies sous forme de hash :
    #         {
    #          "ID" => ID_POKEMON, "SHINY" => true/false, "SHINYLOCK" => true/false,
    #          "NV" => NIVEAU_POKEMON, "OBJ" => NOM_OU_ID_OBJET, "BALL" => ID_BALL,
    #          "MOVE" => [ATK1, ATK2, ATK3, ATK4], "STAT" => [iv_atk, iv_dfe, iv_spd, iv_ats, iv_dfs],
    #          "EV"  => [ev_atk, ev_dfe, ev_spd, ev_ats, ev_dfs], "TSTAS" => [atk, dfe, spd, ats, dfs],
    #          "ABILITY" => NOM_TALENT, "BONHEUR" => TAUX_BONHEUR, "GR" => NUM_SEXE,
    #          "FORM" => NUM_FORM, "NATURE => NOM_OU_NUM_NATURE
    #         }
    # Dans le cas où infos est un Integer, infos défini le niveau du Pokémon
    def initialize(id, infos = 1)
      @id = id
      @shiny = false
      @no_shiny = false
      if infos.is_a?(Hash)
        @level = 1
        set_pokemon_hash(infos) 
      else
        @level = infos
      end
    end

    # Précise les informations du Pokémon Trainer_Party_Actor
    # hash : Les informations sous forme de hash
    def set_pokemon_hash(hash)
      @id = hash['ID'] if hash['ID']
      @shiny = hash['SHINY'] if hash['SHINY']
      @no_shiny = hash['SHINYLOCK'] if hash['SHINYLOCK']
      @level = hash['NV'] if hash['NV']
      @item = hash['OBJ'] if hash['OBJ']
      @ball = hash['BALL'] if hash['BALL']
      @moves = hash['MOVE'] if hash['MOVE']
      @stats = hash["TSTATS"] if hash["TSTATS"]
      @iv = hash['STAT'] if hash['STAT']
      @ev = hash['EV'] if hash['EV']
      @ability = hash['ABILITY'] if hash['ABILITY']
      @loyalty = hash['BONHEUR'] if hash['BONHEUR']
      @genre = hash['GR'] if hash['GR']
      @form = hash['FORM'] if hash['FORM']
      @nature = hash['NATURE'] if hash['NATURE']
    end

    # Créé le pokémon défini
    # Retourne le Pokémon créé
    def create_pokemon
      pokemon = Pokemon.new(@id, @level, @shiny, @no_shiny)
      if @item
        if @item.is_a?(Fixnum)
          pokemon.item_hold = @item 
        else
          pokemon.item_hold = POKEMON_S::Item.id(@item)
        end
      end
      pokemon.id_ball = @ball if @ball
      pokemon.set_skills(@moves) if @moves
      pokemon.stats_modifier(@stats) if @stats 
      pokemon.dv_modifier(@iv) if @iv
      pokemon.ev_modifier(@ev) if @ev
      pokemon.ability = @ability if @ability
      pokemon.gender=(@genre) if @genre
      pokemon.form = @form if @form
      if @nature
        if @nature.is_a?(String)
          pokemon.nature_force(@nature)
        else
          pokemon.nature = pokemon.nature_generation(@nature)
        end
      end
      pokemon.loyalty = @loyalty if @loyalty
      return pokemon
    end
  end
end