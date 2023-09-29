#----------------------------
#  Personnalisation_Text_Box
#  Par FL0RENT_
#----------------------------
# Pour l'utiliser : set_textbox("Nom_De_L_Image")
# Pour remettre l'image initiale : set_textbox
class Scene_Map
  attr_accessor :message_window
end
class Window_Message
  def set_textbox(img = MSG)
    @dummy.bitmap = RPG::Cache.picture(img)
  end
end
class Interpreter
  def set_textbox(img = MSG)
    unless $message_dummy and img == MSG
      $scene.message_window.set_textbox(img)
    else
      $scene.message_window.set_textbox($message_dummy)
    end
  end
end