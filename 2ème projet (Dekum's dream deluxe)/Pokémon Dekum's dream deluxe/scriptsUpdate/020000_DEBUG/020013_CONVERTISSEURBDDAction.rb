#===============================================================================
# CONVERTISSEUR_BDD_Action - Damien Linux
# 27/01/2021
#===============================================================================
# Ensemble de traitements afin de mettre à jour la base de données d'un projet à partie autres
# bases de données (généralement celle de PSPEvolved mise à jour)
#===============================================================================
module CONVERTISSEUR_BDD
  class Convertisseur_BDD_Action
    NAMES_DATA = %w[Classes Enemies Skills Items Armors Weapons]
    # A mettre à false si vous voulez que les noms dans vos classes (excepté Classes qui est quand même mis à jour)
    # soient repris de PSPEvolved et non de votre fangame
    CONSERVE_NAME = true
    # Autorise la mise à jour des niveaux dans Classes
    LEVEL_UPDATE = false
    
    # Création du Convertisseur_BDD_Action
    # gen : La génération de Pokémon (3G-4G-5G-6G-7G)
    def initialize(gen, menu)
      # Récupération des données du jeu et de PSPEvolved
      @data_game = []
      @data_pspe = []
      @menu = menu
      @index = 1
      @percentage = 0
      @upcase_name = false
      i = 0
      NAMES_DATA.each do |name| 
        if File.exist?("updateBDD/BDD_Game/#{name}.rxdata")
          @data_game[i] = load_data("updateBDD/BDD_Game/#{name}.rxdata")
          @data_pspe[i] = load_data("updateBDD/BDD_PSPEvolved/#{name}.rxdata")
          i += 1
        end
      end
      # Chargement des exceptions à ne pas prendre en compte
      chargement_txt("updateBDD/exceptions.txt")
      @data_generation = CONVERTISSEUR_BDD.param_gen(gen)
    end
    
    # Chargement des fichiers data représentés sous forme de ".txt"
    # path : Chemin de localisation du fichier à charger
    def chargement_txt(path)
      if FileTest.exist?(path)
        begin
          file = File.open(path, "rb")
          file.readchar
          file.readchar
          file.readchar
          file.each {|line| eval(line) }
          file.close
        rescue Exception => exception
          EXC::error_handler(exception, file)
        end
      end
    end
    
    # Convertis la base de donnée de PSPEvolved afin de pouvoir mettre à jour celle du projet
    # retourne true si la mise à jour de la base de données a bien eu lieu sinon false
    def execution_convertissement
      begin
        # Parcours les différents fichiers de data
        0.upto(@data_game.size - 1) do |i|
          name = nil
            case @data_game[i][@data_game[i].size - 1].class.to_s
            when "RPG::Class"
              next
            when "RPG::Enemy"
              @menu.draw_text("Fusion des Pokémon...")
              key_gen = :enemies
              name = NAMES_DATA[1]
            when "RPG::Skill"
              @menu.draw_text("Fusion des attaques...")
              key_gen = :skills
              name = NAMES_DATA[2]
            when "RPG::Item"
              @menu.draw_text("Fusion des Objets...")
              key_gen = :objects
              name = NAMES_DATA[3]
            when "RPG::Armor"
              @menu.draw_text("Fusion des CT/CS...")
              key_gen = :ct
              name = NAMES_DATA[4]
            when "RPG::Weapon"
              @menu.draw_text("Fusion des talents...")
              key_gen = :talents
              name = NAMES_DATA[5]
            end
            # Plus de classes à explorer
            if name != nil
              Graphics.update
              # Fusionne les data
              if @data_game[i][@data_game[i].size - 1].class.to_s != "RPG::Enemy" 
                data_game_array = [@data_game[i]]
                data_pspe_array = [@data_pspe[i]]
                data_game_array = fusion(key_gen, data_game_array, data_pspe_array)
                @data_game[i] = data_game_array[0]
              else
                data_game_array = [@data_game[i]]
                data_pspe_array = [@data_pspe[i]]
                # Recherche RPG::Class (si existe la fusion de RPG::Enemy et RPG::Class a lieu en même temps
                indexClass = nil
                0.upto(@data_game.size - 1) do |index| 
                  if @data_game[index][@data_game[index].size - 1].class.to_s == "RPG::Class"
                    indexClass = index
                  end
                end
                if indexClass != nil
                  data_game_array.push(@data_game[indexClass])
                  data_pspe_array.push(@data_pspe[indexClass])
                end
                # Cas de RPG::Enemy : on a RPG::Enemy qui sert de recherche et RPG::Class qui est mis à jour également
                data_game_array = fusion(key_gen, data_game_array, data_pspe_array)
                @data_game[i] = data_game_array[0]
                if indexClass != nil
                  @data_game[indexClass] = data_game_array[1]
                  # Recompile les data du jeu
                  save_data(@data_game[indexClass], "updateBDD/BDD_Game/Classes.rxdata")
                end
              end
              # Recompile les data du jeu
              save_data(@data_game[i], "updateBDD/BDD_Game/#{name}.rxdata")
              name = nil
            end
          end
        rescue Exception => exception
          print exception
          return false
        end
        return true
    end

    # Fusionne un fichier de données du projet avec celui du core de PSPEvolved
    # key : la clé représentant le type de fichier modifié
    # data_game : le(s) fichier(s) de données du projet. Le 1er est utilisé pour la recherche de lignes. 
    # data_pspe : le(s) fichier(s) de données de PSPEvolved. Le 1er est utilisé pour la recherche de lignes.
    # retourne le fichier de données du projet à jour en ayant intégré les mises à jours de PSPEvolved
    def fusion(key, data_game, data_pspe)
      # Parcours des lignes de data_pspe
      @index = 1
      @data_generation[key][0].upto(@data_generation[key][1]) do |j|
        # Recherche toutes les lignes ayant le même nom dans data_game
        next if data_pspe[0][j]  == nil 
        lignes = []
        if data_game[0][j] != nil
          lignes = recherche_lignes(data_pspe[0][j].name, data_game[0], j)
        end
        if (@data_generation[key][1] - @data_generation[key][0]) != 0
          percentage = (@index*100) / (@data_generation[key][1] - @data_generation[key][0])
        else
          percentage = 100
        end
        if lignes.size > 0
          if percentage > @percentage
            @percentage = percentage
            @menu.draw_text("Génération de la nouvelle classe" , "#{key.to_s.upcase} - #{@percentage}%")
          end
          0.upto(data_game.size - 1) do |index_data|
            data_game[index_data] = update_lignes(lignes, data_pspe[index_data][j], data_game[index_data])
          end
        else
          if percentage > @percentage
            @percentage = percentage
            @menu.draw_text("Génération de la nouvelle classe" , "#{key.to_s.upcase} - #{@percentage}%")
          end
          0.upto(data_game.size - 1) do |index_data|
            if @upcase_name 
              data_pspe[index_data][j].name = data_pspe[index_data][j].name.upcase_remove_accents
            end
            data_game[index_data].push(data_pspe[index_data][j])
          end
        end
        @index += 1
        Graphics.update
      end
      return data_game
    end
    
    # Recherches l'intégralité des lignes d'un fichier de données du projet ayant la même entrée
    # qu'une ligne sélectionnée d'un fichier de données de PSPEvolved
    # nom : le nom de l'entrée venant de PSPEvolved
    # data : le fichier de données du projet
    # ligne_pspe : La ligne du fichier de donnée de PSPEvolved étudiée
    # retourne les lignes trouvées à mettre à jour dans le fichier de données du projet
    def recherche_lignes(nom, data, ligne_pspe)
      lignes = []
      1.upto(data.size - 1) do |k|
          # Enregistre le numéro de ligne dès que le même nom est trouvé
          lignes.push(k) if (data[k].name.downcase_remove_accents_special_chars == nom.downcase_remove_accents_special_chars and nom != "")
          if nom == "" and data[k].is_a?(Class) and File.exist?("updateBDD/BDD_Game/Enemies.rxdata")
            if @data_game[1][k].name.downcase_remove_accents_special_chars == @data_pspe[1][ligne_pspe].downcase_remove_accents_special_chars
              lignes.push(k) 
            end
          end
      end
      return lignes
    end
    
    # Détermine si une ligne est inclus dans un tableau avec des Fixnum et Array en contenu
    # exception : l'ensemble des exception
    # ligne : l'ID de la ligne en question
    # retourne true si la ligne est trouvé dans exception ou dans un sous-tableau de exception
    #          false sinon
    def include?(exception, ligne)
      existe = false
      exception.each do |e|
        if e.is_a?(Array)
          existe = (ligne >= e[0] and ligne <= e[1])
          break if existe
        else # e.is_a?(Fixnum)
          existe = (e == ligne)
          break if existe
        end
      end
      return existe
    end
    
    # Met à jour des lignes d'un fichier de données du projet par rapport aux mises à jours de PSPEvolved
    # lignes : les lignes du fichier de données du projet à mettre à jour
    # ligne_data_pspe : l'objet à affecter aux lignes
    # data_game : le fichier de données du projet
    # retourne le fichier de données du projet à jour
    def update_lignes(lignes, ligne_data_pspe, data_game)
      lignes.each do |ligne|
        case data_game[ligne].class.to_s
        when "RPG::Enemy", "RPG::Class"
          exception = @enemies_no
        when "RPG::Skill"
          exception = @skills_no
        when "RPG::Item"
          exception = @items_no
        when "RPG::Armor"
          exception = @armors_no
        else # when RPG::Weapon
          exception = @weapons_no
        end
        if exception == nil or exception.size <= 0 or not include?(exception, ligne) 
          name_data_game = data_game[ligne].name
          data_game[ligne] = ligne_data_pspe
          # Conserve le nom original si option activée (et qu'il ne s'agit pas de Classes)
          if CONSERVE_NAME
            if data_game[ligne].class.to_s != "RPG::Class"
              data_game[ligne].name = name_data_game
            else
              new_name_pspe = ligne_data_pspe.name.split('/')
              new_name_data_game = name_data_game.split('/')
              if LEVEL_UPDATE and new_name_pspe[1] != nil and new_name_pspe[1] != "" and 
                 new_name_data_game[1] != nil and new_name_data_game[1] != ""
                 data_game[ligne].name = new_name_data_game[0] + "/" + new_name_pspe[1]
              end
            end
            if LEVEL_UPDATE and not @upcase_name and name_data_game == name_data_game.upcase
              @upcase_name = true
            end
          end
        end
      end
      return data_game
    end
  end
end