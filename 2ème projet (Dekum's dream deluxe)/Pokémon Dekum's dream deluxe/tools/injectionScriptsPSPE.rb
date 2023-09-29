# Crédits : Damien Linux
require 'zlib'

class Injection

    attr_accessor :scripts
    attr_accessor :id
    attr_accessor :nb_script_regeneree
    attr_accessor :id_file

    def initialize
        @scripts = []
        @id = 1
        @nb_script_regeneree = 0
    end

    # Récupère le contenu d'un script dont le lien d'accès est passé en paramètre
    # path : le lien d'accès au fichier
    # retourne le contenu du script compressé
    def recuperation_script(path)
        contenu = ""
        file = File.new(path, "rb")
        file.each { |line| contenu = "#{contenu}#{line}" }
        file.close
        return compression(contenu)
    end

    # Compresse au bon format pour être lu par RPG Maker XP
    # element : L'élément à compresser
    # retourne le script compressé
    def compression(element)
        return Zlib::Deflate.deflate(element)
    end

    # Supprime l'identifiant du script "XXXXX_" qui se trouve en prefixe
    # filename : le nom du fichier
    # caract : Type de caractère à la place des underscores
    # retourne le nom du fichier sans l'identifiant
    def extraire_id(filename, caract = "_")
        noms = filename.split('_')
        filename = noms[1]
        2.upto(noms.size - 1) { |i| filename = "#{filename}#{caract}#{noms[i]}" }
        nb_zeros = nb_zeros(noms[0])
        taille_id = noms[0].size - 1
        id_file_string = nb_zeros <= taille_id ? noms[0][nb_zeros..taille_id] : 0
        @id_file = Integer(id_file_string)
        return filename
    end

    # Détermine le nombre de 0 qu'il y a au début d'un nombre présente sous la forme
    # d'une chaîne de caractère
    # texte : l'entier sous forme de texte à étudier
    # Retourne le nombre de zéros qu'il y a au début de ce texte
    def nb_zeros(texte)
        nb_zeros = 0
        while texte[nb_zeros] == '0'
            nb_zeros += 1
        end
        return nb_zeros
    end

    # Méthode récursive qui vérifie les fichiers du répertoires courant
    #   => Si répertoire, alors s'appelle en vérifiant les fichiers de ce répertoire
    #   => Si fichier, la méthode prend fin en ajoutant le script dans @scripts
    # path : le chemin d'accès au repertoire / fichier
    # niveau : le niveau depuis la racine sur lequelle le programme regarde
    def verifier_repertoire(path, niveau)
        Dir.foreach(path) do |filename|
            next unless filename != "." and filename != ".."
            chemin = "#{path}/#{filename}"
            if File.directory?(chemin)
                if niveau > 1
                    script_name = extraire_id(filename)
                    @scripts.push([@id_file, @id, "---- #{script_name} ----", compression("")])
                    puts "  L'en-tête #{script_name} a été REGENEREE!"
                    @id += 1
                else
                    script_name = extraire_id(filename, " ")
                    @scripts.push([(@id_file - 1), @id, "---------------------------------------", compression("")])
                    @id += 1
                    @scripts.push([@id_file, @id, "    #{script_name}    ", compression("")])
                    puts "La partie #{script_name} a été REGENEREE!"
                    @id += 1
                    @scripts.push([(@id_file + 1), @id, "---------------------------------------", compression("")])
                    @id += 1
                end
                verifier_repertoire("#{path}/#{filename}", (niveau + 1))
            else
                script_name = extraire_id(filename)
                @scripts.push([@id_file, @id, script_name.sub!(".rb", ''), recuperation_script(chemin)])
                espace = niveau > 1 ? "    " : (script_name != "Main" ? "  " : "")
                puts "#{espace}Le script #{script_name} a été REGENEREE!"
                @nb_script_regeneree += 1
                @id += 1
            end
        end
    end
end

begin
    puts "Début de l'injection des scripts dans le Scripts.rxdata..."
    injection = Injection.new
    injection.verifier_repertoire("scripts", 1)
    puts "#{injection.nb_script_regeneree} scripts ont été regénérés !"
    injection.scripts = injection.scripts.sort
    list_scripts = []
    injection.scripts.each { |script| list_scripts.push([script[1], script[2], script[3]]) }
    File.open("Data/Scripts.rxdata", "wb") { |f| Marshal.dump(list_scripts, f) }
    puts "Le fichier Scripts.rxdata est regénéré, cliquez sur une touche pour quitter la fenêtre"
    gets
    system("Game.exe")
end