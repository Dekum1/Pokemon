#===============================================================================
# CONVERTISSEUR_BDD_Menu - Damien Linux
# 27/01/2021
#===============================================================================
# Menu afin de mettre à jour la base de données du projet à partir d'une nouvelle bases de données.
# Le menu permet notament de désigner les générations de Pokémon qui doivent être prises en compte.
#===============================================================================
module CONVERTISSEUR_BDD
  HASH_DATA_NUMERO = {
    "7G" => {:enemies => [1, 802], :skills => [1, 676], :objects => [1, 738], :ct => [34, 233], :talents => [34, 267]},
    "6G" => {:enemies => [1, 721], :skills => [1, 615], :objects => [1, 738], :ct => [34, 233], :talents => [34, 225]},
    "5G" => {:enemies => [1, 649], :skills => [1, 561], :objects => [1, 738], :ct => [34, 233], :talents => [34, 198]},
    "4G" => {:enemies => [1, 493], :skills => [1, 467], :objects => [1, 738], :ct => [34, 233], :talents => [34, 157]},
    "3G" => {:enemies => [1, 386], :skills => [1, 354], :objects => [1, 738], :ct => [34, 233], :talents => [34, 110]}
  }
  
  class << self
    # Appelle le Convertisseur de BDD
    def call_menu
      menu = Convertisseur_BDD_Menu.new
    end
    
    # Retourne les données concernant une génération de Pokémon
    def param_gen(gen)
      return HASH_DATA_NUMERO[gen]
    end
  end
  
  class Convertisseur_BDD_Menu
    attr_accessor :z_level
    
    # Créé Convertisseur_BDD_Menu
    # z_level : l'index d'affichage (plus est élevé, plus le Convertisseur_BDD_Menu sera devant)
    def initialize(z_level = 0)
      @z_level = z_level
      @text_window = create_text
      @command_window = create_command
      @actif = true
      main
    end
    
    # Exécution des actions
    def main
      draw_text("Vous venez d'enclencher l'action", "CONVERTISSEUR_BDD, soyez la bienvenue.")
      wait_hit
      draw_text("Ce système vous permet de mettre à jour", "la Base de données de votre jeu.")
      wait_hit
      draw_text("Avant tout, prenez bien le temps de lire", "le fichier LisezMoi.txt dans le dossier updateBDD.")
      wait_hit
      draw_text("Sélectionnez maintenant jusqu'à qu'elle", "génération de Pokémon la mise à jour doit se faire.")
      @command_window.visible = true
      @command_window.active = true
      Graphics.transition  
      loop do  
        Graphics.update  
        Input.update  
        update  
        break if not @actif
      end  
      dispose
    end
    
    # Mise à jour des composants : Choix utilisateur
    def update
      @command_window.update  
      # Si la fenêtre de commande est active : appelez update_command
      if @command_window.active  
        resultat = update_command  
        if resultat
          @command_window.active = false
          @command_window.visible = false
          draw_text("La mise à jour de la BDD s'est effectuée", "sans problème.")
          wait_hit
        elsif resultat != nil
          @command_window.active = false
          @command_window.visible = false
          draw_text("Un problème a été rencontré lors de la mise à jour", "de la BDD. Contactez le staff de PSPEvolved.")
          wait_hit
        end
        return  
      end  
    end
    
    # Attend un choix de l'utilisateur
    # retourne l'action effectuée
    def update_command
      # Lorsque le bouton C est enfoncé
      if Input.trigger?(Input::C)  
        $game_system.se_play($data_system.decision_se)  
        # Branche à la position du curseur dans la fenêtre de commande
        case @command_window.index 
        when 0 # 7G
          convertisseur = Convertisseur_BDD_Action.new("7G", self)
        when 1 # 6G
          convertisseur = Convertisseur_BDD_Action.new("6G", self)
        when 2 # 5G
          convertisseur = Convertisseur_BDD_Action.new("5G", self)
        when 3 # 4G
          convertisseur = Convertisseur_BDD_Action.new("4G", self)
        when 4 # 3G  
          convertisseur = Convertisseur_BDD_Action.new("3G", self)
        end
        resultat = convertisseur.execution_convertissement if convertisseur != nil
        @actif = false
        return resultat
      end
    end
    
    # Supprime les composants
    def dispose
      @text_window.dispose
      @command_window.dispose
    end
    
    # Création de la fenêtre commande de choix
    # retourne l'objet Window_Command
    def create_command
      s1 = "Tout : Jusqu'à la 7G"  
      s2 = "Jusqu'à la 6G"
      s3 = "Jusqu'à la 5G"  
      s4 = "Jusqu'à la 4G"
      s5 = "Jusqu'à la 3G"  
      s6 =  "Annuler"
      command_window = Window_Command.new(250, [s1, s2, s3, s4, s5, s6])  
      command_window.index = 0
      command_window.x = 385
      command_window.y = 150
      command_window.z = @z_level + 2  
      command_window.visible = false
      command_window.active = false
      
      return command_window
    end
    
    # Création de la fenêtre d'affichage du texte
    # retourne l'objet Window_Base
    def create_text
      text_window = Window_Base.new(0, 375, 632, $fontsize * 2 + 34)
      text_window.contents = Bitmap.new(600, 104)
      text_window.contents.font.name = $fontface
      text_window.contents.font.size = $fontsize
      text_window.z = @z_level + 1

      return text_window
    end
    
    # Affichage de lignes de texte
    # line1 : la 1ere ligne
    # line2 : la 2eme ligne
    def draw_text(line1 = "", line2 = "")
      @text_window.visible = true
      @text_window.contents.clear
      @text_window.draw_text(0, -8, 460, 50, line1, 0, @text_window.normal_color)
      @text_window.draw_text(0, 22, 460, 50, line2, 0, @text_window.normal_color)
    end
    
    # Attention de l'appuie d'une touche par l'utilisateur
    def wait_hit
      loop do
        Graphics.update
        Input.update
        if Input.trigger?(Input::C)
          $game_system.se_play($data_system.decision_se)
          break
        end
      end
    end
  end
end