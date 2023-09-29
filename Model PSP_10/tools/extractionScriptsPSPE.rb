# Crédits : Damien Linux
require "zlib"

class Extraction
  ID_PREFIXE = {
    "SCRIPTS RMXP" => "00",
	"MODULES UTILITAIRES" => "80",
	"AUTRES" => "70",
	"PAS TOUCHE" => "80",
    "ADD ONS" => "90",
    "REDEFINITION" => "91"
  }

  # Détermine le prefixe d'un fichier servant de clé d'organisation
  # id_dir : le numéro du répertoire le plus haut
  # id_file : le numéro du répertoire du fichier
  # id_sub_file : le numéro du sous-répertoire du fichier
  # index : l'élément du hash ID_PREFIXE où le résultat sera trouvé
  # retourne le prefixe avec le numéro du fichier
  def prefixe(id_dir, id_file, id_sub_file, index) 
	prefixe = id_file.to_s
    index = index.tr('_', ' ')
    if ID_PREFIXE[index] != nil
		id_prefixe = ID_PREFIXE[index]
	else
		if id_dir > 9
			id_prefixe = id_dir.to_s
		else
			id_prefixe = "0#{id_dir}"
		end
	end
    size = id_prefixe != "90" ? 2 : 4
    while prefixe.size < size
      prefixe = "0#{prefixe}"
    end
    if size != 4
      id_sub_dir = id_sub_file < 10 ? "0#{id_sub_file}" : id_sub_file.to_s
    else
      id_sub_dir = ""
    end
    return "#{id_prefixe}#{id_sub_dir}#{prefixe}"
  end

  # Créer un dossier au chemin spécifié
  # path : le chemin
  def creation_repertoire(path)
    unless FileTest.exist?(path)
      Dir.mkdir(path)
      puts "Le dossier \"#{path}\" a été CREE"
    end
  end

  # Détermine les espace nécessaires à supprimer
  # nom : Le nom de l'en-tête avec les espaces
  # retourne les espaces à supprimer
  def espaces(nom) 
    espace = ""
    i = 0
    while nom[i] == ' '
      espace = "#{espace} "
      i += 1
    end
    return espace
  end
  
  def getIdPrefixe
	return ID_PREFIXE
  end
end

begin
  extraction = Extraction.new
  puts "Début de l'extraction des scripts..."
  nb_fichier = 0
  Dir.mkdir "scripts" unless FileTest.exist?("scripts")
  scripts = nil
  current_dir_sans_prefixe = "SCRIPTS RMXP"
  current_sub_dir = current_dir = ""
  File.open("Data/Scripts.rxdata", "rb") do |f|
    scripts = Marshal.load(f)
  end
  id_file = 0
  id_sub_file = 0
  id_dir = 0
  scripts.each do |script|
    e = script[1]
    e.tr!('\\/?!.:*"<>|_','')
    if e != '' and not e.include?('-------') and e != "SCRIPTS RMXP"
      id_file += 1
      if e[0,3].include?("   ")
        id_file = 0
        id_sub_file = 0
        current_sub_dir = current_dir = ""
        dir = e.split(extraction.espaces(e))
        dir.each { |name| current_dir = "#{current_dir}#{name}" }
        current_dir_sans_prefixe = "#{current_dir.tr("-'", '_')}"
		if extraction.getIdPrefixe[current_dir_sans_prefixe] == nil
			id_dir += 1 
			puts id_dir
		end
        prefixe = extraction.prefixe(id_dir, id_file, id_sub_file, current_dir_sans_prefixe)
        current_dir = "#{prefixe}_#{current_dir.tr("-' ", '_')}/"
        extraction.creation_repertoire("scripts/#{current_dir}")
      elsif e.include?("----")
        id_sub_file += 1
        id_file = 0
        prefixe = extraction.prefixe(id_dir, id_file, id_sub_file, current_dir_sans_prefixe)
        current_sub_dir = "#{prefixe}_#{e.tr("-' ", '')}/"
        extraction.creation_repertoire("scripts/#{current_dir}#{current_sub_dir}")
      else
        if e.include?("Main")
          prefixe = "999999"
          current_dir = current_sub_dir = "" 
        else
          prefixe = extraction.prefixe(id_dir, id_file, id_sub_file, current_dir_sans_prefixe)
        end
        file_name = "#{prefixe}_#{e.tr("- ", '_')}.rb"
        file_path = "scripts/#{current_dir}#{current_sub_dir}#{file_name}"
        file = File.open("#{file_path}","wb")
        file.write(Zlib::Inflate.inflate(script[2]))
        file.close
        puts "Le fichier \"#{file_path}\" a bien été EXTRAIT"
        nb_fichier += 1
      end
    end
  end
  extraction.creation_repertoire("scripts/900000_ADD_ONS")
  puts "#{nb_fichier} scripts ont été extraits"
  puts "Le traitement est terminé, appuyez sur une touche pour quitter la fenêtre."
  gets
end