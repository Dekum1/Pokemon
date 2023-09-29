#==============================================================================
# ■ Game_SelfVariables
#------------------------------------------------------------------------------
# Hash gérant les variables locales. Des variables propres à l'évènement, 
# Permet de ne pas devoir utiliser de variable de jeu pour gérer ce qui est propre
# à un évènement
# Dans les scrpit, la variable globale $game_self_variables contient les variables
# locales
#==============================================================================
class Game_SelfVariables
  #--------------------------------------------------------------------------
  # ● Création
  #--------------------------------------------------------------------------
  def initialize
    @data = {}
  end
  #--------------------------------------------------------------------------
  # ● Get
  #     key : Object, index de la variable à récupérer
  #--------------------------------------------------------------------------
  def [](key)
    return @data[key]
  end
  #--------------------------------------------------------------------------
  # ● Set
  #     key   : Object, index de la variable à modifier
  #     value : Object, information à stocker
  #--------------------------------------------------------------------------
  def []=(key, value)
    @data[key] = value
  end
  #--------------------------------------------------------------------------
  # ● Do
  #     key         : Object, index de la variable à modifier
  #     operation   : Symbol, nom de l'opération à réaliser. Can be empty.
  #     value       : Object, paramètre de l'opération
  #--------------------------------------------------------------------------
  def do(key, operation=nil, value=nil)
    @data[key]=0 unless @data.has_key?(key)
    case operation
    when :set
        @data[key]=value
    when :del
        @data.delete(key)
         
    # Numeric
    when :add
        @data[key]+=value
    when :sub
        @data[key]-=value
    when :div
        @data[key]/=value
    when :mul
        @data[key]*=value
    when :mod
        @data[key]=@data[key]%value
    when :count
        @data[key]+=1
    when :uncount
        @data[key]-=1
         
    # Boolean
    when :toggle
        @data[key]=!@data[key]
    when :and
        @data[key]=(@data[key] and value)
    when :or
        @data[key]=(@data[key] or value)
    when :xor
        @data[key]=(@data[key]^value)
    end
    # Return the data
    return @data[key]
  end
end
 
class Interpreter
  def VL(*args)
    # Ancienne version de VL
    if args[0].is_a?(Object) and (args[1]==nil or args[1].is_a?(Integer))
      return $game_self_variables.do([(args[2] ? args[2] : @map_id),(args[1] ? args[1] : @event_id), args[0]])
    end
    # Nouvelle version
    if args[0].is_a?(Symbol) # [var_loc, operation, value]
      return $game_self_variables.do([@map_id, @event_id, args[0]], args[1], args[2])
    elsif args[1].is_a?(Integer)# [map_id, event_id, var_loc, operation, value]
      return $game_self_variables.do([args[0], args[1], args[2]], args[3], args[4])
    else # [event_id, var_loc, operation, value]
      return $game_self_variables.do([@map_id, args[0], args[1]], args[2], args[3])
    end
    return nil
  end
  alias get_local_variable VL
  alias LV VL
       
  def set_local_variable(id_var, value, id_event = @event_id, id_map = @map_id)
    key = [id_map, id_event, id_var]
    $game_self_variables[key] = value
  end
  alias set_VL set_local_variable
  alias set_LV set_local_variable
end