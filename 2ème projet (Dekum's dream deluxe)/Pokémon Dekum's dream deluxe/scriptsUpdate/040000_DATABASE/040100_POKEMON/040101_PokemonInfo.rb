#==============================================================================
# ● Base de données - Pokémon
# Pokemon Script Project - Krosk 
# Mis à jour par Damien Linux
# 14/11/2020
#==============================================================================
module POKEMON_S
  #=============================================================================  
  # Pokemon_Info
  #=============================================================================  
  # Inspection de $data_pokemon
  #   Pour l'utiliser, faites Pokemon_Info.methode(id)
  #   Exemple: récupérer le nom du pokémon id 150:
  #     Pokemon_Info.name(150)
  #
  # (Ex: $pokemon_info.methode(id))
  #=============================================================================  
  class Pokemon_Info
    class << self
      def id(namepoke)
        result = nil
        1.upto($data_pokemon.size-1) do |idpoke|
          if namepoke == name(idpoke)
            result = idpoke
            break
          end
        end
        return result if result != nil
      end
    
      def name(id)
        return $data_pokemon[id][0]
      end
    
      def id_bis(id)
        return $data_pokemon[id][1]
      end
    
      def base_stat(id)
        return $data_pokemon[id][2]
      end
    
      def base_hp(id)
        return base_stat(id)[0]
      end
    
      def base_atk(id)
        return base_stat(id)[1]
      end
      
      def base_dfe(id)
        return base_stat(id)[2]
      end
    
      def base_spd(id)
        return base_stat(id)[3]
      end
    
      def base_ats(id)
        return base_stat(id)[4]
      end
    
      def base_dfs(id)
        return base_stat(id)[5]
      end
    
      def skills_list(id)
        return $data_pokemon[id][3]
      end
    
      def skills_tech(id)
        return $data_pokemon[id][4]
      end
    
      def evolve_table(id)
        return $data_pokemon[id][5]
      end
    
      def exp_type(id)
        return evolve_table(id)[0]
      end
    
      #Prise en compte de la forme du Pokémon
      def type_list(id, form = 0, mega = 0)
        if form != 0 or mega != 0
          if form != 0
            symbol = "f#{id}_#{form}".to_sym
          end
          if mega != 0
            if form == 0
              symbol = "f#{id}_0".to_sym
            end
            symbol = "#{symbol}_M#{mega}".to_sym
          end
          if $data_form[symbol] != nil
            return [$data_form[symbol][3], $data_form[symbol][4]]
          end
        end
        return $data_pokemon[id][6]
      end
    
      #Prise en compte de la forme du Pokémon
      def type1(id, form = 0, mega = 0)
        return type_list(id, form, mega)[0]
      end

      #Prise en compte de la forme du Pokémon    
      def type2(id, form = 0, mega = 0)
        if type_list(id, form, mega)[1] != nil
          return type_list(id, form, mega)[1]
        else
          return 0
        end
      end
    
      def rareness(id)
        return $data_pokemon[id][7][0]
      end
    
      def female_rate(id)
        return $data_pokemon[id][7][1]
      end
    
      def base_loyalty(id)
        return $data_pokemon[id][7][2]
      end
    
      def ability_list(id)
        return $data_pokemon[id][7][3]
      end
    
      def breed_group(id)
        return $data_pokemon[id][7][4]
      end
    
      def breed_move(id)
        return $data_pokemon[id][7][5]
      end
    
      def hatch_step(id)
        return $data_pokemon[id][7][6]
      end
    
      def battle_list(id)
        return $data_pokemon[id][8]
      end
    
      def ev_hp(id)
        return battle_list(id)[0]
      end
    
      def ev_atk(id)
        return battle_list(id)[1]
      end
      
      def ev_dfe(id)
        return battle_list(id)[2]
      end
    
      def ev_spd(id)
        return battle_list(id)[3]
      end
    
      def ev_ats(id)
        return battle_list(id)[4]
      end
    
      def ev_dfs(id)
        return battle_list(id)[5]
      end
    
      def base_exp(id)
        return battle_list(id)[6]
      end
    
      # Prise en compte de la forme du Pokémon
      def descr(id, form = 0, mega = 0)
        if form != 0 or mega != 0
          if form != 0
            symbol = "f#{id}_#{form}".to_sym
          end
          if mega != 0
            if form == 0
              symbol = "f#{id}_0".to_sym
            end
            symbol = "#{symbol}_M#{mega}".to_sym
          end
          return $data_form[symbol][0] if $data_form[symbol] != nil
        end
        return $data_pokemon[id][9][0]
      end
    
      # Description supplémentaire sur la forme du Pkmn
      def descr_form(id, form = 0, shiny = false, mega = 0)
        string = ""
        symbol = "f#{id}_#{form}".to_sym
        if mega != 0
          symbol = "#{symbol}_M#{mega}".to_sym
        end
        string = $data_form[symbol][5] if $data_form[symbol] != nil
        string = string + " Shiny" if shiny
        return string.rstrip
      end
    
      def spec(id)
        return $data_pokemon[id][9][1]
      end
    
      # Prise en compte des formes du Pokémon
      def height(id, form = 0, mega = 0)
        if form != 0 or mega != 0
          if form != 0
            symbol = "f#{id}_#{form}".to_sym
            return $data_form[symbol][1] if $data_form[symbol] != nil
          end
          if mega != 0
            if form == 0
              symbol = "f#{id}_0".to_sym
            end
            symbol = "#{symbol}_M#{mega}".to_sym
          end
          return $data_form[symbol][1] if $data_form[symbol] != nil
        end
        return $data_pokemon[id][9][2]
      end
    
      # Prise en compte des formes du Pokémon
      def weight(id, form = 0, mega = 0)
        if form != 0 or mega != 0
          if form != 0
            symbol = "f#{id}_#{form}".to_sym
          end
          if mega != 0
            symbol = "#{symbol}_M#{mega}".to_sym
          end
          return $data_form[symbol][2] if $data_form[symbol] != nil
        end
        return $data_pokemon[id][9][3]
      end
    
      def where(id)
        return $data_pokemon[id][9][4]
      end
    
      def skills_table(id)
        list = []
        if skills_list(id).length != 0
          taille = skills_list(id).size/2-1
          0.upto(taille) do |i|
            list.push([skills_list(id)[2*i+1], skills_list(id)[2*i]])
          end
        end
        return list
      end
    end
  end
end