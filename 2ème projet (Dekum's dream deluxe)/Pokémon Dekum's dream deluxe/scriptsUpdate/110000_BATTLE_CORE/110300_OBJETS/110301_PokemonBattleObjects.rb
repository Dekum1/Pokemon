#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Battle_Objects - Damien Linux
# 15/12/19
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé, 8: Toxic
# @confuse (6), @flinch (7)
#-----------------------------------------------------------------------------
# 1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
# 10 Vol 11 Psy 12 Insecte 13 Roche 14 Spectre 15 Dragon 16 Acier 17 Tenebres
#----------------------------------------------------------------------------- 
module POKEMON_S
  #------------------------------------------------------------  
  # Pokemon_Battle_Core
  # - Suppression d'un item côté acteur
  # - Utilisation d'un item côté ennemi
  # - IA ennemi
  # - Méthodes d'accompagnement de l'IA
  # - Symbole d'un objet
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Suppression d'un item côté acteur
    #------------------------------------------------------------     
    def actor_item_use # items à utiliser
      # Item déjà utilisé ie remplacé par 0
      if @item_id == 0
        return
      end
    end
    
    #------------------------------------------------------------  
    # Utilisation d'un item côté ennemi
    #------------------------------------------------------------ 
    # Utilise un objet après avoir vérifié l'utilisation 
    # (item_use? de Trainer_IA)
    def enemy_item_use
      draw_text("#{Trainer_Info.name(@trainer_id)} utilise #{search_object(@object_use[:objet])} !")
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:soin_objet]}")
      wait(40)
      
      # Utilisation de l'objet
      execution(object_symbol_util(@object_use[:objet]), "util") 
      
      # Méthode de suppression d'objet en fonction de la méthode employée
      # pour préciser l'objet
      if @object_use[:type] == :hash
        0.upto(@objects.size - 1) do |i|
          if @objects[i] != nil and @objects[i].is_a?(Hash) and
             @objects[i].type == Hash and 
             @objects[i]["OBJ"] == @object_use[:objet]
            if @objects[i]["NB"] != nil
              @objects[i]["NB"] -= 1
            end
            if @objects[i]["NB"] == nil || @objects[i]["NB"] == 0
              @objects[i] = nil
            end
            break
          end
        end
      elsif @object_use[:type] == :tab
        0.upto(@objects.size - 1) do |i|
          if @objects[i][0] == @object_use[:objet]
            draw_text("Valeur : #{@objects[i][1]}")
            wait(40)
            if @objects[i].size > 1
              @objects[i][1] -= 1
            end
            if @objects[i].size <= 1 or @objects[i][1] == 0
              @objects[i] = nil
            end
            break
          end
        end
      else #@object_use[:type] == :solo
        index = @objects.index(@object_use[:objet])
        @objects[index] = nil # Suppression de l'objet
      end
    end  
    
    #------------------------------------------------------------  
    # IA ennemi
    #------------------------------------------------------------  
    # Vérifie si le dresseur a des items et s'il souhaite utiliser l'un
    # d'entre eux
    def item_use?
      # valide => l'objet utilisé ou nil si invalide
      # Si précisé :
      # nom => Le ou les nom des pokémon sur lequel l'objet peut être utilisé
      # id => Le ou les ID dans la party des pokémon sur lequel l'objet peut
      #       être utilisé [0, 1, 2, 3, 4 ou 5]
      # num_rappel => le numéro du pokémon K.O. à réanimer pour le cas des
      #                objets Rappel. Si Dracaufeu et Bulbizarre sont K.O. dans
      #                cet odre, pour Bulbizarre, son numéro est 1
      valide = nom = id = num_rappel = nil
      return valide if @objects == nil
      for i in 0...@objects.size
        # Cas de l'objet supprimé
        if @objects[i] == nil
          next
        end
        # Vérifie de quel type de combinaison il s'agit, exemples :
        # - Argument Seul, ex : ["GUERISON", "RAPPEL"]
        # - Tableau simple : [["GUERISON"], ["RAPPEL", 1], ["GUERISON", 2]
        # - Tableau Hash : [{"OBJ" => "GUERISON", "NB" => 2, "PV" => 25},
        #                   { "OBJ" => "RAPPEL", "NBKO" => 3}]
        if @objects[i].is_a?(Hash)
          type = :hash
          object = @objects[i]["OBJ"]
          next if object == nil
        elsif @objects[i].is_a?(Array)
          object = @objects[i][0]
          type = :tab
        else 
          object = @objects[i]
          type = :solo
        end
        
        # Exécution de la méthode de vérification pour l'objet en question
        valide = execution_return(object_symbol_verif(object), "verif", 
                                  nil, type, i)
          
        # Vérifie si un objet doit être utilisé ou non, si oui définie
        # les paramètres utiles pour son utilisation
        if valide != nil
          if type == :hash
            if @objects[i]["NOM"] != nil
              nom = @objects[i]["NOM"] 
            end
            if @objects[i]["ID"] != nil
              id = @objects[i]["ID"]
            end
            if @objects[i]["NUMKO"] != nil
              num_rappel = @objects[i]["NUMKO"]
            end
          end
          break
        end
      end
      return {:objet => valide, :type => type, :pokemon => nom, 
              :id_party => id, :num_rappel => num_rappel}
    end
    
    #------------------------------------------------------------  
    # Méthodes d'accompagnement de l'IA
    #------------------------------------------------------------ 
    # Renvoie la stat recherchée en fonction de l'objet à utiliser
    # actor : l'acteur subissant l'objet
    # object : l'objet à utiliser
    # Renvoie la modification de stat actuelle en fonction de l'objet ou nil
    # si le paramètre STAT ne peut pas être pris en compte
    def stat_object(actor, object)
      stat = nil
      case object
      when "ATTAQUE +"
        stat = actor.atk_stage
      when "DEFENSE +"
        stat = actor.dfe_stage
      when "VITESSE +"
        stat = actor.spd_stage
      when "SPECIAL +"
        stat = actor.ats_stage
      when "DEF.SPE"
        stat = actor.dfs_stage
      when "PRECISION +"
        stat = actor.acc_stage
      end
      return stat
    end
    
    # Renvoie le status dans un formalise compréhensible pour pouvoir
    # effectuer une comparaison avec une saisie utilisateur
    # actor : le pokémon sur lequel la vérification est effectuée
    def check_status(actor)
      string = ""
      if actor.confuse_check 
        return "CONFUSION"
      end
      
      case actor.get_status   
      when 1, 8
        string = "POISON"
      when 2
        string = "PARALYSIE"
      when 3
        string = "BRULURE"
      when 4
        string = "SOMMEIL"
      when 5
        string = "GEL"
      end
      return string
    end
    
    # Utilise l'objet si la condition précisée est valide et si les conditions 
    # générales le sont aussi.
    # Cette fonction permet de centrer les conditions touchant tous les objets
    # à utiliser :
    # ROUND => Nombre de rounds minimum à passer avant utilisation
    # NOM => Le ou les noms des pokémon sur lequel l'objet doit être utilisé
    # ID => L'ID du ou des pokémon dans l'équipe ennemi [0, 1, 2, 3, 4 ou 5]
    #       sur lequel l'objet doit être utilisé
    # actor : Le type d'acteur sur lequel l'objet doit être utilisé
    # type : Le type de renseignement utilisé (Seul, Tableau ou Hash)
    # index : L'indice dans le tableau objet du hash visualisé
    # condition : la condition supplémentaire de validité d'utilisation
    # Renvoie l'objet ou nil si celui-ci ne doit pas être utilisé
    def utilisation_general(actor, type, index, condition)
      utilisation = nil
      if type == :hash and condition
        # Nombre de rounds minimum à passer avant utilisation
        if @objects[index]["ROUND"] != nil and @objects[index]["ROUND"] > 0
          @objects[index]["ROUND"] -= 1
        end
        round_valide = (@objects[index]["ROUND"] == nil or 
                        @objects[index]["ROUND"] == 0) 
        nom_valide = (@objects[index]["NOM"] == nil or 
                      @objects[index]["NOM"] == actor.name.upcase or
                      (@objects[index]["NOM"].is_a?(Array) and
                       @objects[index]["NOM"].include?(actor.name.upcase)))
        id_valide = (@objects[index]["ID"] == nil or 
                     @objects[index]["ID"] == actor.party_index_enemy or
                     (@objects[index]["ID"].is_a?(Array) and
                      @objects[index]['ID'].include?(actor.party_index_enemy)))
        min_valide = (@objects[index]["MINPV"] == nil or
                      actor.hp > @objects[index]["MINPV"])
        coef_min_valide = (@objects[index]["COEFMINPV"] == nil or
                           actor.hp > Integer(actor.max_hp * @objects[index]["COEFMINPV"]))
        if round_valide and nom_valide and id_valide and min_valide and
           coef_min_valide
          utilisation = @objects[index]["OBJ"]
        end
      elsif condition
        utilisation = type == :tab ? @objects[index][0] : @objects[index]
      end
      return utilisation
    end
    
    #------------------------------------------------------------  
    # Symbole d'un objet
    #------------------------------------------------------------ 
    # Donne la clé correspondant à un objet dans le cadre d'une vérification
    # name : le nom de l'objet
    def object_symbol_verif(name)
      return ID_OBJECTS_VERIF[name.downcase_remove_accents.upcase]
    end
    
    # Donne la clé correspondant à un objet dans le cadre d'une utilisation
    # name : le nom de l'objet
    def object_symbol_util(name)
      return ID_OBJECTS_UTIL[name.downcase_remove_accents.upcase]
    end
    
    def search_object(name)
      id = (1...$data_item.size).find do |id|
        name.downcase_remove_accents == Item.name(id).downcase_remove_accents
      end
      return Item.name(id)
    end
  end
end