#==============================================================================
# ■ Pokemon_Party
# Pokemon Script Project - Krosk 
# 20/07/07
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Gestion générale d'équipe et des boites de stockage
# A créer au début de la partie!
#-----------------------------------------------------------------------------
# $data_storage[0] : informations générales et noms
#    id = 1..xx
# $data_storage[0][id] = [ nom, attribut ]
# $data_storage[id] = boite
#-----------------------------------------------------------------------------

module POKEMON_S
  #------------------------------------------------------------  
  # class Pokemon_Party : génère l'information sur le groupe.
  # associé à la variable $pokemon_party
  # associé à la variable $data_storage
  #------------------------------------------------------------
  class Pokemon_Party
    #include POKEMON_S
    
    attr_reader :actors
    attr_accessor :money
    attr_reader :steps
    attr_accessor :bag
    attr_accessor :repel_count
    attr_accessor :bag_index
    attr_accessor :ordi  
    attr_accessor :ordi_index 
    attr_accessor :cities # La liste des villes visitées (utile pour Vol)
    
    def initialize
      @actors = []
      @money = 0
      @steps = 0
      @bag = [ 0, [], [], [], [], [] ]
      @bag_index = [1, 0] #socket, index
      @repel_count = 0
      @ordi = [ 0, [], [], [], [], [] ]  
      @ordi_index = [1, 0]  
      @cities = [] # Liste des villes visitées (utile pour Vol)
    end
    
    #------------------------------------------------------------  
    # Gestion d'équipe: pokemon désigne le pokémon entier (class)
    #                   id désigne la place du pokémon dans l'équipe (0 à 5)
    #                   id_store désigne la place dans $data_storage
    #------------------------------------------------------------
    def size
      return @actors.length
    end
    
    def full?
      return @actors.length == 6
    end
    
    def empty?
      return @actors.length == 0
    end
    
    #------------------------------------------------------------  
    # add(pokemon)
    #   pokemon: class Pokemon
    #------------------------------------------------------------  
    def add(pokemon)      
      if pokemon != nil and @actors.size < 6
        # Pokedex
        $pokedex.add(pokemon)
        # Pokedex
        @actors.push(pokemon)
      end
    end
    
    
    #------------------------------------------------------------  
    # add_or_store(pokemon)
    #   pokemon: class Pokemon
    #------------------------------------------------------------  
    def add_or_store(pokemon)
      if pokemon != nil and @actors.size < 6
        @actors.push(pokemon)
        # Pokedex
      elsif pokemon != nil
        store_captured(pokemon)
      end
    end  
    
    #------------------------------------------------------------  
    # remove(pokemon)
    #   pokemon: class Pokemon
    #------------------------------------------------------------  
    def remove(pokemon)
      if @actors.include?(pokemon)
        @actors.delete(pokemon)
        @actors.compact!
      end
    end
    
    #------------------------------------------------------------  
    # remove_id(id)
    #   id: place dans l'équipe
    #------------------------------------------------------------  
    def remove_id(id)
      if id == -1
        return
      end
      if @actors[id] != nil
        @actors.delete_at(id)
      end
    end
    
    #------------------------------------------------------------  
    # switch_party(id1, id2)
    #   id1, id2, places dans l'équipe
    #------------------------------------------------------------  
    def switch_party(id1, id2)
      if id1 <= id2
        @actors.insert(id1, @actors[id2])
        @actors.delete_at(id2+1)
        @actors.insert(id2 + 1, @actors[id1+1])
        @actors.delete_at(id1+1)
      else
        switch_party(id2, id1)
      end
    end
    
    #------------------------------------------------------------  
    # Gestion de boîtes : id désigne le numéro de la boîte.                  
    #------------------------------------------------------------    
    def box_full?(id)
      if $data_storage[id] == nil
        $data_storage[id] = []
        return false
      end
      for i in 0..23
        if $data_storage[id][i] == nil
          return false
        end
      end
      return true
    end
    
    def create_box
      length = $data_storage.length
      $data_storage.push([]) #création boite supplémentaire
      for i in 0..23
        $data_storage[-1][i] = nil
      end
      $data_storage[0].push(["BOITE " + length.to_s, 0]) #création infos
    end
    
    def delete_box(id)
      if $data_storage[id] != []
        $data_storage.delete_at(id)
        $data_storage[0].delete_at(id)
      end
    end
    
    def rename_box(id, name)
      $data_storage[0][id] = [name, $data_storage[0][id][1] ]
    end

    def change_background_box(id, number)
      $data_storage[0][id] = [$data_storage[0][id][1], number]
    end
    
    #------------------------------------------------------------  
    # Gestion de stockage
    #------------------------------------------------------------        
    def store(id, box = 0) #id désigne le numéro du pokémon dans l'équipe
      if box == 0 or box_full?(box)
        i = 1
        until box_full?(i) do
          i += 1
        end
        box = i
      end
      
      if @actors[id] != nil
        for i in 0..23
          if $data_storage[box][i] == nil
            $data_storage[box][i] = @actors[id]
            @actors[id].refill
            id_store = i
            break
          end
        end
        remove_id(id)
      end
      
      @actors.flatten
      return id_store
    end
    
    
    def store_captured(pokemon)
      pokemon.refill
      # Pokedex
      $pokedex.add(pokemon)
      # Pokedex
      
      
      #Cherche une boite non vide
      r = 1
      until not(box_full?(r)) do
        r += 1
      end
      box = r
      
      #Cree la boite si elle n'existe pas
      if $data_storage[box] == nil
        create_box
      end
      
      #Ajoute le Pokémon
      for i in 0..23
        if $data_storage[box][i] == nil
          $data_storage[box][i] = pokemon
          break
        end
      end
    end

    
    def retrieve(id_store, box) #id_store : 0..29
      if $data_storage[box][id_store] != nil
        add($data_storage[box][id_store])
        $data_storage[box][id_store] = nil
      end
    end
    
    def switch_storage(id1, id2, box1, box2 = box1)
      if $data_storage[box1] == nil or $data_storage[box2] == nil
        return
      end
      if id1 <= id2
        $data_storage[box1].insert(id1, $data_storage[box2][id2])
        if box1 == box2
          $data_storage[box2].delete_at(id2+1)
          $data_storage[box2].insert(id2+1, $data_storage[box1][id1+1])
        else
          $data_storage[box2].delete_at(id2)
          $data_storage[box2].insert(id2, $data_storage[box1][id1+1])
        end
        $data_storage[box1].delete_at(id1+1)
      else
        switch_storage(id2, id1, box2, box1)
      end
    end
    
    def switch_storage_party(id1, id2, box)
      # id1 index dans l'équipe
      # id2 index dans la boite, box id de la boite
      if $data_storage[box] == nil
        return
      end
      @actors.insert(id1, $data_storage[box][id2])
      $data_storage[box].delete_at(id2)
      $data_storage[box].insert(id2, @actors[id1+1])
      @actors.delete_at(id1+1)
      if @actors[id1] == nil
        @actors.delete_at(id1)
      end
    end
    
    #------------------------------------------------------------  
    # Gestion héros
    #------------------------------------------------------------
    def add_money(amount)
      @money = [[@money + amount, 0].max, 9999999].min
    end
    
    def lose_money(amount)
      add_money(-amount)
    end
    
    def increase_steps
      @steps = [@steps + 1, 9999999].min
      # Repel
      if @repel_count > 0
        @repel_count -= 1
      end
      # Reduit le nombre de pas pour chaque oeuf
      for pokemon in @actors
        if pokemon.egg
          pokemon.decrease_step
        end
      end
      # Inspecte la pension
      Daycare.sequence
    end
    
    def check_map_slip_damage
      if $game_map.map_id == POKEMON_S::_WMAPID
        return
      end
      for actor in @actors
        if actor.hp > 1 and (actor.poisoned? or actor.toxic?)
          actor.hp -= 1
          $game_screen.start_flash(Color.new(255,0,0,128), 4)
          if actor.hp <= 1
            draw_text("#{actor.name} a survécu au", "poison.")
            actor.cure if actor.poisoned?
          end
          if $pokemon_party.dead?
            $game_temp.common_event_id = 3
          end
        end
      end
    end
    
    # Ecriture sur la fenêtre de texte d'une taille de 2 lignes
    # line1 : La première ligne du block de texte
    # line2 : La deuxième ligne du block de texte
    def draw_text(line1 = "", line2 = "")
      text_window = Window_Base.new(0, 375, 632, $fontsize * 2 + 34)
      text_window.contents = Bitmap.new(600, 104)
      text_window.contents.font.name = $fontface
      text_window.contents.font.size = $fontsize
      text_window.visible = true
      text_window.contents.clear
      text_window.draw_text(0, -8, 460, 50, line1, 0, Color.new(0, 0, 0))
      text_window.draw_text(0, 22, 460, 50, line2, 0, Color.new(0, 0, 0))
      wait(40)
      text_window.dispose
    end
    
    # Attente en frame (40 frames = 1s)
    # frame : le nombre de frame d'attente
    def wait(frame)
    i = 0
    loop do
      i += 1
      Graphics.update
      if i >= frame
        break
      end
    end
  end
    
    # Ajout d'une ville visitée
    def add_city(string)
      @cities ||= []
      if string.type != String
        return
      end
      unless @cities.include?(string)
        @cities.push(string)
      end
    end
    
    # Réinitialisation de la liste des villes visitées
    def reset_cities
      @cities = []
    end

    #------------------------------------------------------------  
    # Gestion équipe supplémentaire
    #------------------------------------------------------------
    def refill_party
      for pokemon in @actors
        pokemon.refill
      end
    end
    
    def cure_party
      for pokemon in @actors
        pokemon.cure
        pokemon.cure_state
      end
    end
    
    
    def dead?
      for pokemon in @actors
        if not(pokemon.dead?)
          return false
        end
      end
      return true
    end
    
     def number_alive
      result = 0
      for pokemon in @actors
        if not(pokemon.dead?)
          result += 1
        end
      end
      return result
    end
    
    #------------------------------------------------------------  
    # Gestion Sac
    #  @bag = [ paramètre, [], [], [], [], [] ]
    #  id: id objet, nombre
    #  paramètre : optionnel
    #  @bag[1] : Items, objets simples, sous la forme [id, nombre]
    #  @bag[2] : Balles sous la forme [id, nombre]
    #  @bag[3] : CT/CS sous la forme [id, nombre]
    #  @bag[4] : Baies [id, nombre]
    #  @bag[5] : Objets clés
    #------------------------------------------------------------
    
    #------------------------------------------------------------
    # add_item(id, nombre)
    #   Ajoute un objet
    #------------------------------------------------------------
    def add_item(id, amount = 1)
      if $data_item[id] == nil or POKEMON_S::Item.name(id) == ""
        return
      end
      socket = POKEMON_S::Item.socket(id)
      index = bag_list(socket).index(id)
      if index == nil and amount > 0 # ne possède pas cet item
        if POKEMON_S::Item.holdable?(id)
          @bag[socket].push([id, amount])
        else
          @bag[socket].push([id, 1])
        end
      else
        @bag[socket][index][1] += amount
        if not POKEMON_S::Item.holdable?(id) and @bag[socket][index][1] > 1
          @bag[socket][index][1] = 1
        end
        if @bag[socket][index][1] <= 0
          @bag[socket].delete_at(index)
        end
      end
    end
        def ajouter_item(id, amount = 1)  
      if $data_item[id] == nil or POKEMON_S::Item.name(id) == ""  
        return  
      end  
      socket = POKEMON_S::Item.socket(id)  
      index = ordi_list(socket).index(id)  
      if index == nil # ne possède pas cet item  
        if POKEMON_S::Item.holdable?(id)  
          @ordi[socket].push([id, amount])  
        else  
          @ordi[socket].push([id, 1])  
        end  
      else  
        @ordi[socket][index][1] += amount  
        if not POKEMON_S::Item.holdable?(id) and @ordi[socket][index][1] > 1  
          @ordi[socket][index][1] = 1  
        end  
        if @ordi[socket][index][1] <= 0    
          @ordi[socket].delete_at(index)  
        end   
      end  
    end 
    
    def use_item(id)
      if $data_item[id] == nil or POKEMON_S::Item.name(id) == ""
        return
      end
      socket = POKEMON_S::Item.socket(id)
      index = bag_list(socket).index(id)
      if index == nil
        return false
      elsif POKEMON_S::Item.limited_use?(id)
        @bag[socket][index][1] -= 1
        if @bag[socket][index][1] == 0
          @bag[socket].delete_at(index)
        end
        return true
      else
        return true
      end
    end
    
    def drop_item(id, amount = 1)
      if $data_item[id] == nil or POKEMON_S::Item.name(id) == ""
        return
      end
      socket = POKEMON_S::Item.socket(id)
      index = bag_list(socket).index(id)
      if index != nil # ne possède pas cet item
        @bag[socket][index][1] -= amount
        if @bag[socket][index][1] <= 0
          @bag[socket].delete_at(index)
        end
      end
    end
    
    def jeter_item(id, amount = 1)  
      if $data_item[id] == nil or POKEMON_S::Item.name(id) == ""  
        return  
      end  
      socket = POKEMON_S::Item.socket(id)  
      index = ordi_list(socket).index(id)  
      if index != nil # ne possède pas cet item  
        @ordi[socket][index][1] -= amount  
        if @ordi[socket][index][1] <= 0  
          @ordi[socket].delete_at(index)  
        end  
      end  
    end  
    
    def item_switch(socket, id1, id2)
      @bag[socket].switch( {id1 => id2, id2 => id1})
    end
    
    def sell_item(id, amount)
      add_money(amount * POKEMON_S::Item.price(id)/2)
      drop_item(id, amount)
    end
    
    def buy_item(id, amount)
      lose_money(amount * POKEMON_S::Item.price(id))
      add_item(id, amount)
    end
    
    #------------------------------------------------------------
    # item_got
    #    Fonction indiquant si un item est possédé
    #------------------------------------------------------------
    def item_got(id)
      socket = POKEMON_S::Item.socket(id)
      if bag_list(socket).include?(id)
        return true
      else
        return false
      end
    end
    
    def item_number(id)
      socket = POKEMON_S::Item.socket(id)
      item_index = bag_list(socket).index(id)
      if item_index != nil
        return @bag[socket][item_index][1]
      else
        return 0
      end
    end
    
    #------------------------------------------------------------
    # bag_list(socket)
    #   Fonction qui liste les objets déjà possédés
    #------------------------------------------------------------
    def bag_list(socket)
      list = []
      for item in @bag[socket]
        list.push(item[0])
      end
      return list
    end
        def ordi_list(socket)  
      list = []  
      for item in @ordi[socket]  
        list.push(item[0])  
      end  
      return list  
    end 
    
    #------------------------------------------------------------
    # max_level
    #   Fonction qui renvoie le niveau max de l'équipe
    #------------------------------------------------------------
    def max_level
      list = [1]
      for actor in @actors
        list.push(actor.level)
      end
      return list.max
    end
    
    #------------------------------------------------------------
    # got_skill
    #   Fonction qui renvoie si l'équipe possède le skill
    #------------------------------------------------------------
    def got_skill(id_data)
      for actor in @actors
        for skill in actor.skills_set
          if id_data.type == String and Skill_Info.name(skill.id) == id_data
            $string[0] = actor.name
            return true
          end
          if id_data.type == Fixnum and skill.id == id_data
            $string[0] = actor.name
            return true
          end
        end
      end
      return false
    end
    
    def got_pokemon(id_data)
      if id_data.type == Fixnum
        for actor in @actors
          if actor.id == id_data
            return true
          end
        end
        return false
      end
      if id_data.type == String
        for actor in @actors
          if actor.name == id_data
            return true
          end
        end
        return false
      end
    end
    
    def get_pokemon(id_data)
      if id_data.type == Fixnum
        i = 0
        for actor in @actors
          if actor.id == id_data
            return i
          end
          i += 1
        end
        return -1
      end
      if id_data.type == String
        i = 0
        for actor in @actors
          if actor.name == id_data
            return i
          end
          i += 1
        end
        return -1
      end
    end
  end
end