#==============================================================================
# ■ Pokemon_Gestion
# Pokemon Script Project - Krosk
#------------------------------------------------------------------------------
# Classe Pokedex - G!n0
# Contient les méthodes de gestion du pokedex
# 15/08/2020
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Fonctionnement : pour l'id d'un pokemon 
# @data[id] = [niveau, liste]
# niveau = niveau d'avancement de la page (0: pas vu, 1: vu, 2: attrapé)
# liste = liste des formes observées (0 : mâle, 1 : mâle shiny, 2 : femelle etc...)

# @level : niveau du Pokédex. Détermine la disponibilité des modes.
# 0 : seulement regional, 1 : seulement national, 2 : les deux disponibles

# @regional : utilisé pour l'affichage de la liste des Pokémon dans la scène
# du pokédex. true : liste en mode régional. False : liste en mode national.
# Ne pas toucher @regional
#------------------------------------------------------------------------------
module POKEMON_S

  class Pokedex

    attr_accessor :data
    
    #----------------------------------------------------
    # Initilisation
    #----------------------------------------------------
    def initialize(len)
      # Données Pokédex
      @data = Array.new(len)
      @data[0] = false # activé ou non
      1.upto(len) do |i|
        @data[i] = [0,[]]
      end
      # niveau du pokédex : exclusivement national par défaut
      @level = 0
      # mode d'affichage de la liste des Pokémon
      @regional = false
    end
    
    #----------------------------------------------------
    #Taille du Pokedex
    #----------------------------------------------------
    def size
      return @data.size
    end

    #----------------------------------------------------
    #activation/Désactivation du pokedex
    #----------------------------------------------------
    def enable
      @data[0] = true
    end
    
    def enabled?
      return @data[0]
    end
    
    def disable
      @data[0] = false
    end
    
    #----------------------------------------------------
    # Ajout d'un pokemon vu/attrapé dans le pokedex
    # Captured = true/false
    #----------------------------------------------------
    def add(pokemon, captured = true)
      if @data[pokemon.id][0] != 2 and not pokemon.egg
        @data[pokemon.id][0] = captured ? 2 : 1 #vu ou capturé
      end
      #ajout de la forme
      form = pokemon.code_appearence
      pokemon.mega ||= 0
      seen_page(pokemon.id, pokemon.gender, pokemon.shiny, pokemon.form, pokemon.mega)
    end
    
    #----------------------------------------------------
    # Complétion d'une page particulière du pokedex
    #----------------------------------------------------
    def complete_page(id, female = false, shiny = false, form = 0, mega = 0)
      ida = sprintf("%03d", id)
      string = ""
      @data[id][0] = 2 #capturé
      id_form = 0
      
      #vérif forme
      if form > 0
        battler_form = sprintf("_%02d", form)
        string = "Front_Male/#{ida}#{battler_form}.png"
        if FileTest.exist?("Graphics/Battlers/#{string}")
          id_form += form * 20
        end
      end
      #Vérif shiny
      if shiny
        id_form += 1
      end
      #Vérif femelle
      if female and form == 0
        string = "Front_Female/#{ida}.png"
        if FileTest.exist?("Graphics/Battlers/#{string}")
          id_form += 2
        end
      end
      if mega > 0 and form == 0
        battler_mega = sprintf("_M%d", mega)
        string = "Front_Male/#{ida}#{battler_mega}.png"
        if FileTest.exist?("Graphics/Battlers/#{string}")
          id_form += 7
        end
      end
      
      @data[id][1].push(id_form)
      @data[id][1].uniq!
      @data[id][1].sort!
      
    end
    
    #----------------------------------------------------
    # Indiquer qu'une page d'un pokedex correspond à un pkmn vu
    #----------------------------------------------------
    def seen_page(id, female = false, shiny = false, form = 0, mega = 0)
      ida = sprintf("%03d", id)
      string = ""
      if @data[id][0] != 2 then @data[id][0] = 1 end # pkmn vu
      id_form = 0
      
      #vérif forme
      if form > 0
        battler_form = sprintf("_%02d", form)
        string = "Front_Male/#{ida}#{battler_form}.png"
        if FileTest.exist?("Graphics/Battlers/#{string}")
          id_form += form * 20
        end
      end
      #Vérif shiny
      if shiny
        id_form += 1
      end
      #Vérif femelle
      if female and form == 0
        string = "Front_Female/#{ida}.png"
        if FileTest.exist?("Graphics/Battlers/#{string}")
          id_form += 2
        end
      end
      if mega > 0 and form == 0
        battler_mega = sprintf("_M%d", mega)
        string = "Front_Male/#{ida}#{battler_mega}.png"
        if FileTest.exist?("Graphics/Battlers/#{string}")
          id_form += 7
        end
      end
      
      @data[id][1].push(id_form)
      @data[id][1].uniq!
      @data[id][1].sort!
      
    end
    
    #----------------------------------------------------
    # Compléter le pokedex avec possibilité de rajouter les shiny
    # Attention ne prend pas en compte les formes et les femelles
    #----------------------------------------------------
    def complete(shiny = false)
      1.upto(@data.length-1) do |i|
        @data[i][0] = 2
        @data[i][1].push(0)
        @data[i][1].push(1) if shiny
        @data[i][1].uniq!
        @data[i][1].sort!
      end
    end
    
    #----------------------------------------------------
    #Vérifier que le pokedex est rempli
    #----------------------------------------------------
    def completed?
      1.upto(@data.length-1) do |i|
        if @data[i][0] == nil
          return false
        end
        if @data[i][0] < 2
          return false
        end
      end
      return true
    end
    
    #----------------------------------------------------
    # Retourner le nb de Pokémon vus/capturés
    #----------------------------------------------------
    def state
      seen = 0
      captured = 0
      1.upto(@data.length-1) do |i|
        if @data[i][0] == 2 #si capturé (forcément vu)
          seen += 1
          captured += 1
        elsif @data[i][0] == 1 #si seulement vu
          seen += 1
        end
      end
      return [seen, captured]
    end
    
    #----------------------------------------------------
    # Savoir si un Pokémon est capturé
    #----------------------------------------------------
    def captured?(id)
      return (@data[id][0] == 2)
    end
    
    #----------------------------------------------------
    # Savoir si un Pokémon est vu
    #----------------------------------------------------
    def seen?(id)
      return (@data[id][0] >= 1)
    end
    
    #----------------------------------------------------
    # Effacer des données du Pokédex
    #----------------------------------------------------
    def delete_page(id)
      @data[id] = [0, []]
    end
    
    def delete
      1.upto(@data.length-1) do |i|
        @data[i] = [0, []]
      end
    end
    
    #----------------------------------------------------
    # Réglage du niveau du pokédex : disponibilité des modes
    # au démarrage du Pokédex
    #----------------------------------------------------
    # Seulement régional
    def set_lv_regional
      @level = 0
      @regional = true
    end
    
    # set_Seulement national
    def set_lv_national
      @level = 1
      @regional = false
    end
    
    # Les deux modes sont disponibles
    def set_lv_all
      @level = 2
      @regional = false
    end
    
    # Retourner le niveau du Pokédex
    # 0 : seulement régional, 1 : seulement national, 2 : les deux
    def level
      return @level
    end
    
    #----------------------------------------------------
    # mode d'affichage de la liste dans le scène du pokédex
    #----------------------------------------------------
    def set_regional
      @regional = true
    end
    
    def set_national
      @regional = false
    end
    
    def regional
      return @regional
    end
    
    #----------------------------------------------------
    # Retourner la liste du Pokédex Régional
    # mode = :debug permet de savoir s'il y a des trous dans les id_bis
    #----------------------------------------------------
    def list_reg(mode = nil)
      table = []
      1.upto($pokedex.data.size - 1) do |id|
        table[Pokemon_Info.id_bis(id)] = id
      end
      if mode == :debug and $DEBUG
        id_missing = ""
        table.size.times do |i|
          if i > 0
            id_missing << "#{i} " if table[i] == nil
          end
        end
        unless id_missing.empty?
          print "Erreur Pokédex Régional :", "\n\n",
                "Il manque les id_bis suivants", "\n", id_missing
        end
      end
      table.shift # débarasser l'élément 0
      table.compact!
      if table.empty?
        print "Erreur Pokédex Régional : \n Aucun Pokémon possède d'id_bis !"
        table = [1]
      end
      return table
    end
    
    #----------------------------------------------------
    # Nombre de Pkmn capturés/vus régional
    #----------------------------------------------------
    def state_reg
      seen = 0
      captured = 0
      1.upto(@data.length-1) do |id|
        if Pokemon_Info.id_bis(id) != 0
          if @data[id][0] == 2
            seen += 1
            captured += 1
          elsif @data[id][0] == 1
            seen += 1
          end
        end
      end
      return [seen, captured]
    end
    
    #----------------------------------------------------
    # MAJ de la longueur du pokedex
    #----------------------------------------------------
    def update
      1.upto($data_pokemon.length-1) do |i|
        if @data[i] == nil
          @data[i] = [0, []] #vu, capturé, list formes
        end
      end
    end
  
  end
  
end 