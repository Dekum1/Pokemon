module POKEMON_S
  #=============================================================================  
  # Item
  #=============================================================================  
  # Inspection de $data_item
  #   renvoie les infos nécessaires sur un ibjet
  #   par la connaissance de son id
  #   marche en parallèle à Pokemon_Party_Menu
  #
  # (Ex: $item.methode(id))
  #=============================================================================  
  class Item
    class << self
      def name(id)
        if id == 0
          return "AUCUN"
        end
        return $data_item[id][0]
      end
    
      def icon(id)
        if id == 0
          return "return.png"
        end
        return $data_item[id][1]
      end
    
      def descr(id)
        if id == 0
          return "Aucune."
        end
        return $data_item[id][3]
      end
    
      def price(id)
        if id == 0
          return 0
        end
        return $data_item[id][4]
      end
    
      def socket(id)
        socket = $data_item[id][2]
        case socket
        when "ITEM"
          return 1
        when "BALL"
          return 2
        when "TECH"
          return 3
        when "BERRY"
          return 4
        when "KEY"
          return 5
        end
        return 1
      end
    
      # [ tenable/jetable, usage limité, usage en map, usage en combat, usage sur pokémon, apte/non apte]
      def profile(id)
        return $data_item[id][5]
      end
    
      def battle_usable?(id)
        return profile(id)[3]
      end
    
      def map_usable?(id)
        return profile(id)[2]
      end
    
      def limited_use?(id)
        return profile(id)[1]
      end
    
      def holdable?(id)
        return profile(id)[0]
      end
    
      def soldable?(id)
        return profile(id)[0]
      end
    
      def use_on_pokemon?(id)
        return profile(id)[4]
      end
    
      def item_able_mode?(id)
        return profile(id)[5]
      end
    
      def use_string(id)
        return $data_item[id][6]
      end
    
      def data(id) # Renvoie Hash
        return $data_item[id][7]
      end
    
      def log_data_A(id)
        return $data_item[id][8]
      end
    
      def log_data_B(id)
        return $data_item[id][9]
      end
      
      def log_data_C(id)
        return $data_item[id][9]
      end
    
      def id(string)
        if $data_item
          $data_item.each do |item|
            if item != nil
              if string == item[0]
                return $data_item.index(item)
              end
            end
          end #else
        end #else
        return 0
      end
    
    
      def able?(id, pokemon)
        # Analyse data
        if data(id) != nil
          if data(id)["stone"]
            if pokemon.evolve_check("stone", name(id))
              return true
            end
          end
          if data(id)["ct"] != nil
            list = pokemon.skills_allow
            if list.include?(data(id)["ct"][0]) # ID de la CT
              return true
            end
          end
          if data(id)["cs"] != nil
            list = pokemon.skills_allow
            if list != nil
              if list.include?([data(id)["cs"][0]]) # [ID de la CS]
                return true
              end
            end
          end
        end
        return false
      end
    
      def effect(id)
        has_effect = false
        return_map = false
      
        if use_on_pokemon?(id)
          return [false, "Erreur."]
        end
      
        if data(id) != nil
          if data(id)["repel"] != nil
            has_effect = ($pokemon_party.repel_count <= 0)
            if has_effect
              $pokemon_party.repel_count += data(id)["repel"]
            end
          end
          if data(id)["ball"] != nil and data(id)["ball"]
            has_effect = true
          end
          if data(id)["event"] != nil
            has_effect = true
            return_map = true
            $game_temp.common_event_id = data(id)["event"]
            $scene = Scene_Map.new
          end
          if data(id)["flee"] != nil
            has_effect = true
          end
        end
      
        if not(has_effect)
          return [false, "Ce n'est pas le moment d'utiliser ça.", false]
        end
      
        return [true, sprintf(use_string(id), POKEMON_S::Player.name), return_map]
      end
    
      
    
      def effect_on_pokemon(id, pokemon, scene) # renvoie [utilisé, texte]
        _name = pokemon.given_name
        _amount = 0
        # Vérification de cible
        if not(use_on_pokemon?(id))
          return [false, "Erreur."]
        end
      
        # ---------------------------------------------------
        # Cycle des effets
        has_effect = false
        heal_status = false
        heal_state = false
        heal = false
        # ---------------------------------------------------
        if data(id) != nil
          if data(id)["level_up"] != nil
            has_effect = true
            1.upto(data(id)["level_up"]) do |i|
              if pokemon.level >= POKEMON_S::MAX_LEVEL
                has_effect = false
                break
              end
              pokemon.level_up(scene)
              if pokemon.item_hold != 110 and pokemon.evolve_check != false
                scenebis = POKEMON_S::Pokemon_Evolve.new(pokemon, pokemon.evolve_check, scene.z_level + 300)
                scenebis.main
              end
            end
          end
          # variable qui contient la stat qui augmente.  
          type_boostage = "aucun" 
          if data(id)["boost"] != nil    
            # si un oeuf est choisi, rien ne se passe.  
            if not pokemon.egg
              list = [0,0,0,0,0,0, 0]  
              list[data(id)["boost"]] = 10  
              case data(id)["boost"]    
              when 0     
                # indique la stat qui sera inscrite dans le message à la fin.  
                type_boostage = "PV MAX" 
                last_max_hp = pokemon.max_hp
              when 1    
                type_boostage = "ATTAQUE MAX"    
              when 2        
                type_boostage = "DEFENSE MAX"  
              when 3      
                type_boostage = "VITESSE MAX"  
              when 4        
                type_boostage = "ATQ.SPE. MAX"    
              when 5       
                type_boostage = "DEF.SPE. MAX"
              when 6 # PP PLUS
                return item_pp_plus(pokemon, 0.2)
              when 7 # PP MAX
                return item_pp_plus(pokemon, 0.6)                
              end    
              has_effect = pokemon.add_bonus(list)
                # Mise à jour des PV
              if data(id)["boost"] == 0
                pokemon.add_hp(pokemon.max_hp - last_max_hp) 
              end
            end    
          end   
          if data(id)["battle_boost"] != nil
            case data(id)["battle_boost"]
            when 0 #Atk
              amount = pokemon.change_atk(1)
            when 1 # Dfe
              amount = pokemon.change_dfe(1)
            when 2
              amount = pokemon.change_spd(1)
            when 3
              amount = pokemon.change_ats(1)
            when 4
              amount = pokemon.change_dfs(1)
            when 5
              amount = pokemon.change_eva(1)
            when 6
              amount = pokemon.change_acc(1)
            end
            if amount > 0
              has_effect = true
              pokemon.raise_loyalty
            end
          end
          
          if data(id)["stone"] != nil
            has_effect = true
            evolve_id = pokemon.evolve_check("stone", name(id))
            scenebis = POKEMON_S::Pokemon_Evolve.new(pokemon, evolve_id, scene.z_level + 300, true)
            scenebis.main
          end
            
          if data(id)["ct"]
            has_effect = true
            skill_id = data(id)["ct"][1]
            if not(pokemon.skill_learnt?(skill_id))
              scenebis = POKEMON_S::Pokemon_Skill_Learn.new(pokemon, skill_id, scene)
              scenebis.main
              return [scenebis.return_data, ""]
            else
              return [false, pokemon.name + " connaît déjà " + POKEMON_S::Skill_Info.name(skill_id) + '.' ]
            end
          end
            
          if data(id)["cs"]
            has_effect = true
            skill_id = data(id)["cs"][1]
            if not(pokemon.skill_learnt?(skill_id))
              scenebis = POKEMON_S::Pokemon_Skill_Learn.new(pokemon, skill_id, scene)
              scenebis.main
              return [scenebis.return_data, ""]
            else
              return [false, "#{pokemon.name} connaît déjà #{POKEMON_S::Skill_Info.name(skill_id)}." ]
            end
          end
        
          # ---------------------------------------------------
          # Cycle de soin des PP
          # Soin chiffré de toutes les attaques
          if data(id)["recover_pp_all"] == 1
            value = 0
            0.upto(pokemon.skills_set.length - 1) do |i|
              value += pokemon.refill_skill(i, data(id)["recover_pp"])
            end
            if value > 0
              has_effect = true
            end
          # Soin d'une attaque == appel de skill
          elsif data(id)["recover_pp_all"] == 0 and data(id)["recover_pp"] > 0
            index = pokemon.skill_selection
            # N'a pas utilisé, retour au Sac
            if index == -1
              return [false, ""]
            end
            _amount = pokemon.refill_skill(index, data(id)["recover_pp"])
            # Si le skill visé n'est pas plein
            if _amount > 0
              has_effect = true
            end
          end
        
          # ---------------------------------------------------
          # Cycle de soin
          # Soin par pourcentage
          _amount += pokemon.max_hp * data(id)["recover_hp_rate"] / 100
          # Soin par points
          _amount += data(id)["recover_hp"]
          _amount = [pokemon.max_hp - pokemon.hp, _amount].min
          
          if data(id)["recover_hp_rate"] + data(id)["recover_hp"] > 0
            heal = true
          end
          
          if _amount == 0
            heal = false
          end
          # En cas de Pokémon mort: Ne fonctionne pas, excepté si passage dans 
          #   cycle de rappel
          heal = heal && (not pokemon.dead?)

          # ---------------------------------------------------
          
          # ---------------------------------------------------
          # Cycle de rappel
          if data(id)["recover_state"].include?(9)
            heal = pokemon.dead?
          end
          
          
          # ---------------------------------------------------
          # Cycle de soin de statut
          # Statuts
          heal_status = data(id)["recover_state"].include?(pokemon.status)
          
          # Confusion
          heal_state = (data(id)["recover_state"].include?(6) and 
                        pokemon.confused? != nil and pokemon.confused?)
            
          # ---------------------------------------------------
          # Effets discrets
          if data(id)["loyalty"] != nil
            loyalty_pts = data(id)["loyalty"]
            if loyalty_pts < 0
              if pokemon.loyalty >= 200
                pokemon.loyalty += loyalty_pts - 5
              else
                pokemon.loyalty += loyalty_pts
              end
            else
              if pokemon.loyalty < 100
                pokemon.loyalty += loyalty_pts
              elsif pokemon.loyalty < 200 and loyalty_pts > 1
                pokemon.loyalty += loyalty_pts - 2
              elsif loyalty_pts > 2
                pokemon.loyalty += loyalty_pts - 3
              end
            end
          end  
        end

        # ---------------------------------------------------
        # Si il n'y a aucun effet
        # ---------------------------------------------------
        # vérifie si aucune stat n'a été boostée.  
        if type_boostage == "aucun"  
          if not(heal_status or heal_state or heal or has_effect)
            return [false, "Ça n'aura aucun effet."]    
          end  
        else    
          # sinon, jouer la musique et indiquer quel pokémon augmente quel stat.  
          Audio.me_play("Audio/ME/#{DATA_AUDIO_ME[:item]}")    
          return [true, type_boostage + " de " + pokemon.name + " a augmenté !"]      
        end        
        
        # ---------------------------------------------------
        # Effets nécessitant le rafraichissement de la fenêtre
        # ---------------------------------------------------
        scene.item_refresh
        Graphics.update
        
        if heal_state
          pokemon.cure_state
        end
        
        if heal_status
          pokemon.cure
        end

        if heal_state or heal_status or heal
          # Animation de soin (pas de condition pour que Rappel fonctionne)
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:soin_objet]}")
        end
        
        if heal
          1.upto(_amount) do |i|
            pokemon.hp += 1
            scene.hp_refresh
            if pokemon.hp == 1 # Vient de sortir du K.O.
              scene.refresh
            end
            Graphics.update
          end
        end
        
        return [true, sprintf(use_string(id), _name, _amount) ]
      end
      
      # Augmente les PP d'une attaque sélectionnée en vérifiant que l'attaque
      # n'a pas plus de 60% de ces PP initiaux qui ont été ajoutés
      # pokemon : le pokemon qui va voir les PP d'une de ces attaques augmenter
      # pourcentage : le pourcentage d'augmentation des PP de l'attaque qui
      #                sera sélectionnée
      # Renvoie false si les PP d'une attaque sont au-delà de 60% des PP initiaux
      #               ajoutés après utilisation de l'objet
      #         true sinon
      def item_pp_plus(pokemon, pourcentage)
        interpret = Interpreter.new
        skill = pokemon.ss(interpret.skill_selection(pokemon))
        if skill.ppinit == nil
          skill.def_ppinit
        end
        pp_apres_utilisation = Integer(skill.ppmax + skill.ppinit * pourcentage)
        pp_maximum_autorise = Integer(skill.ppinit + skill.ppinit * 0.6)
        if pp_apres_utilisation > pp_maximum_autorise
          return [false, "Les PP de #{skill.name} sont déjà au maximum !"]
        end #else
        skill.add_ppmax(Integer(skill.ppinit * pourcentage))
        Audio.me_play("Audio/ME/#{DATA_AUDIO_ME[:item]}")    
        return [true, "Les PP de #{skill.name} ont augmenté !" ]
      end
    end
  end
end