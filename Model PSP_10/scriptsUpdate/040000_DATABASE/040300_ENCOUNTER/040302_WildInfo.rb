#==============================================================================
# ● Base de données -  Infos d'un Pokémon sauvage
# Pokemon Script Project - Krosk 
# Wild_Info - Damien Linux
# 14/11/2020
#==============================================================================
module POKEMON_S
  class Wild_Info
    attr_accessor :id # L'ID du Pokémon
    attr_accessor :min_level # Niveau minimum
    attr_accessor :max_level # Niveau maximum
    attr_accessor :iv # Les IV (avant DV) du Pokémon
    attr_accessor :ev # Les EV du Pokémon
    attr_accessor :moves # Les attaques du Pokémon
    attr_accessor :genre # Sexe du Pokémon
    attr_accessor :form # Valeur fixe ou tableau (dans ce cas la forme est choisie aléatoirement)
    attr_accessor :shiny # True si le Pokémon est shiny sinon false
    attr_accessor :shiny_lock # True si le Pokémon n'a aucun droit d'être shiny sinon false
    attr_accessor :stats # Les stats du Pokémon
    attr_accessor :nature # La nature du Pokémon
    attr_accessor :ability # Le talent du Pokémon
    attr_accessor :rarity # Rareté 
    attr_accessor :loyalty # Bonheur du Pokémon

    # Construction de Wild_Info en recevant les informations de la BDD
    # id : L'ID du Pokémon
    # infos : Les informations fournies dans différents formats :
    #           - Tableau = [niveau, rareté locale, niveau max (facultatif)]
    #           - Hash =  ["NV" => niveau_fixe, "NV_MIN" => niveau_min (si non précisé => "NV"), "RL" => rarete, "DV" => [iv_atk, iv_dfe, iv_spd, iv_ats, iv_dfs],
    #                      "MOVE" => [attaque1, attaque2, ...], "GR" => genre, "FORM" => form or [form1, form2, ...], 
    #                      "SHINY" => true or false, "TSTATS" => [hp, atk, dfe, spd, ats, dfs], "NATURE" => nature,
    #                      "SHINYLOCK" => true or false, "EV" => [ev_atk, ev_dfe, ev_spd, ev_ats, ev_dfs], "ABILITY" => talent]
    #               "NV" est obligatoire ! 
    # ecart_level : L'écart entre min_level et max_level si max_level n'est pas défini dans infos
    def initialize(id, infos, ecart_level)
      @id = id
      @shiny = false
      @shiny_lock = false
      if infos.is_a?(Array) 
        set_pokemon_array(infos, ecart_level) 
      else
        set_pokemon_hash(infos, ecart_level)
      end
    end

    # Précise les informations du Pokémon et de Wild_Info
    # hash : Les informations sous forme de tableau
    # ecart_level : L'écart entre min_level et max_level si max_level n'est pas défini dans array
    def set_pokemon_array(array, ecart_level)
      @max_level = (array[0] > MAX_LEVEL) ? MAX_LEVEL : array[0]
      if array.size > 1
        @rarity = array[1]
        if array.size > 2
          @min_level = array[2] 
        else
          @min_level = @max_level - ecart_level + 1
        end
      else 
        @min_level = @max_level - ecart_level + 1
      end
      @min_level = 1 if @min_level <= 0
    end

    # Précise les informations du Pokémon et de Wild_Info
    # hash : Les informations sous forme de hash
    # ecart_level : L'écart entre min_level et max_level si max_level n'est pas défini dans hash
    def set_pokemon_hash(hash, ecart_level)
      @id = hash["ID"] if hash["ID"]
      @max_level = (hash["NV"] > MAX_LEVEL) ? MAX_LEVEL : hash["NV"]
      @rarity = hash["RL"] if hash["RL"]
      if hash["NV_MIN"]
        @min_level = hash["NV_MIN"]
      else
        @min_level = @max_level - ecart_level + 1
      end
      @min_level = 1 if @min_level <= 0
      @max_level = MAX_LEVEL if @max_level > MAX_LEVEL
      @iv = hash["DV"] if hash["DV"]
      @ev = hash["EV"] if hash["EV"]
      @moves = hash["MOVE"] if hash["MOVE"]
      @genre = hash["GR"] if hash["GR"]
      @form = hash["FORM"] if hash["FORM"]
      @shiny = hash["SHINY"] if hash["SHINY"]
      @shiny_lock = hash["SHINYLOCK"] if hash["SHINYLOCK"]
      @stats = hash["TSTATS"] if hash["TSTATS"]
      @nature = hash["NATURE"] if hash["NATURE"]
      @ability = hash["ABILITY"] if hash["ABILITY"]
      @loyalty = hash["BONHEUR"] if hash["BONHEUR"]
    end

    # Créé un Pokémon aléatoire avec les informations fournies par @infos, @min_level, @max_level
    # Retour le Pokémon créé
    def create_pokemon
      pokemon = Pokemon.new(@id, Integer((rand(@max_level - @min_level) + @min_level)), @shiny, @shiny_lock)
      pokemon.dv_modifier(@iv) if @iv
      pokemon.ev_modifier(@ev) if @ev
      pokemon.set_skills(@moves) if @moves
      pokemon.gender = @genre if @genre
      if @form != nil and @form.is_a?(Array)
        pokemon.form = @form[rand(@form.size)]
      elsif @form
        pokemon.form = @form
      end
      pokemon.stats_modifier(@stats) if @stats
      pokemon.nature = @nature if @nature
      pokemon.ability = @ability if @ability
      pokemon.loyalty = @loyalty if @loyalty
      return pokemon
    end
  end
end