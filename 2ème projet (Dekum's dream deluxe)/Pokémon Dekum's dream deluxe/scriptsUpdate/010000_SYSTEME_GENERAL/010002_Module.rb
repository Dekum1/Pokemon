module POKEMON_S
  
  def self._WMAPID=(value)
    $game_variables[CARTE] = value
  end
  
  def self._SAVESLOT
    return $game_variables[SAVESLOT]
  end
  
  def self.set_SAVESLOT=(value)
    $game_variables[SAVESLOT] = value
  end
  
  def self.nuit?
    return (Time.now.hour >= 19 or Time.now.hour < 6)
  end
  
  def self.jour?
    return (Time.now.hour < 18 and Time.now.hour >= 6)
  end
end


  # --------------------------------------------------------
  # error_handler
  # --------------------------------------------------------

module EXC
  def self.error_handler(exception, file_arg = nil)
    if exception.type == SystemExit
      return
    end
    
    if exception.message == "" # Reset
      raise
    end
    
    # Sauvegarde de secours
    if $game_player != nil
      characters = []
      0.upto($game_party.actors.size - 1) do |i|
        actor = $game_party.actors[i]
        characters.push([actor.character_name, actor.character_hue])
      end
      $pokemon_save.save("SaveAuto", characters)
    end
    
    script = load_data("Data/Scripts.rxdata")
    
    source = script[exception.backtrace[0].split(":")[0].sub("Section", "").to_i][1]
    source_line = exception.backtrace[0].split(":")[1]
    
    if file_arg != nil
      file = file_arg
      source = file.path
    end
    if source == "Interpreter Bis" and source_line == "444"
      source = "évènement"
    end
      
    print("Erreur dans le script #{source}, inspectez le rapport Log.txt.")
    
    logfile = File.open("Log.txt", "w")
    
    # Entete
    logfile.write("---------- Erreur de script : #{source} ----------\n")
    
    # Type
    logfile.write("----- Type\n")
    logfile.write(exception.type.to_s + "\n\n")
    
    # Message
    logfile.write("----- Message\n")
    if exception.type == NoMethodError
      logfile.write("- ARGS - #{exception.args.inspect}\n")
    end
    logfile.write(exception.message + "\n\n")
    
    # Position en fichier
    if file_arg != nil
      logfile.write("----- Position dans #{file.path}\n")
      logfile.write("Ligne #{file.lineno}\n")
      logfile.write(IO.readlines(file.path)[file.lineno-1] + "\n")
    elsif source == "évènement"
      logfile.write("----- Position de l'évènement\n")
      logfile.write($running_script + "\n\n")
    else
      logfile.write("----- Position dans #{source}\n")
      logfile.write("Ligne #{source_line}\n\n")
    end
    
    # Backtrace
    logfile.write("----- Backtrace\n")    
    for trace in exception.backtrace
      location = trace.split(":")
      script_name = script[location[0].sub("Section", "").to_i][1]
      logfile.write("Script : #{script_name} | Ligne : #{location[1]}")
      if location[2] != nil
        logfile.write(" | Méthode : #{location[2]}")
      end
      logfile.write("\n")
    end
    logfile.close
    
    raise
  end
end