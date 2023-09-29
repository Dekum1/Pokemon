#==============================================================================
# ■ Gestion_Balls
# Pokemon Script Project - Krosk 
# Gestion_Balls - Damien Linux
# 27/01/2021
#-----------------------------------------------------------------------------
# Modulable
#-----------------------------------------------------------------------------
HASH_BALL = {
  1 => {:ball => :master_ball, :sprite => "ball4.png", :color => Color.new(255,0,242,255)}, # Master Ball
  2 => {:ball => :hyper_ball, :sprite => "ball3.png", :color => Color.new(255,242,0,255)}, # Hyper Ball
  3 => {:ball => :super_ball, :sprite => "ball2.png", :color => Color.new(0,157,255,255)}, # Super Ball 
  4 => {:ball => :poke_ball, :sprite => "ball1.png", :color => Color.new(255,210,233,255)}, # Poké Ball
  5 => {:ball => :filet_ball, :sprite => "ball5.png", :color => Color.new(45,171,149,255)}, # Filet Ball
  6 => {:ball => :faiblo_ball, :sprite => "ball6.png", :color => Color.new(152,248,56,255)}, # Faiblo Ball
  7 => {:ball => :scuba_ball, :sprite => "ball8.png", :color => Color.new(144,211,216,255)}, # Scuba Ball
  8 => {:ball => :bis_ball, :sprite => "ball7.png", :color => Color.new(223,129,78,255)}, # Bis Ball
  9 => {:ball => :chrono_ball, :sprite => "ball9.png", :color => Color.new(216,96,80,255)}, # Chrono Ball
  10 => {:ball => :honor_ball, :sprite => "ball11.png", :color => Color.new(208,40,40,255)}, # Honor Ball
  11 => {:ball => :luxe_ball, :sprite => "ball10.png", :color => Color.new(248,216,104,255)}, # Luxe Ball
  12 => {:ball => :safari_ball, :sprite => "ball12.png", :color => Color.new(49,103,77,255)}, # Safari Ball
  196 => {:ball => :sombre_ball, :sprite => "ball14.png", :color => Color.new(255,255,255,255)}, # Sombre Ball
  420 => {:ball => :soin_ball, :sprite => "ball13.png", :color => Color.new(237,196,240,255)}, # Soin Ball
  421 => {:ball => :rapide_ball, :sprite => "ball15.png", :color => Color.new(0,157,255,255)}, # Rapide Ball
  422 => {:ball => :parc_ball, :sprite => "ball26.png", :color =>Color.new(234,206,40,255)}, # Parc Ball
  423 => {:ball => :memoire_ball, :sprite => "ball16.png", :color => Color.new(204,34,4,255)}, # Mémoire Ball
  424 => {:ball => :speed_ball, :sprite => "ball17.png", :color => Color.new(223,204,89,255)}, # Speed Ball
  425 => {:ball => :appat_ball, :sprite => "ball18.png", :color => Color.new(195,94,94,255)}, # Appât Ball
  426 => {:ball => :niveau_ball, :sprite => "ball22.png", :color => Color.new(163,101,24,255)}, # Niveau Ball
  427 => {:ball => :masse_ball, :sprite => "ball19.png", :color => Color.new(103,140,159,255)}, # Masse Ball
  428 => {:ball => :love_ball, :sprite => "ball27.png", :color => Color.new(234,136,225,255)}, # Love Ball
  429 => {:ball => :copain_ball, :sprite => "ball23.png", :color => Color.new(107,180,37,255)}, # Copain Ball
  430 => {:ball => :lune_ball, :sprite => "ball21.png", :color => Color.new(67,125,161,255)}, # Lune Ball
  431 => {:ball => :compet_ball, :sprite => "ball25.png", :color => Color.new(249,114,41,255)}, # Compet_ball
  432 => {:ball => :reve_ball, :sprite => "ball20.png", :color => Color.new(182,154,180,255)}, # Rêve Ball
  433 => {:ball => :ultra_ball, :sprite => "ball24.png", :color => Color.new(95,66,189,255)}, # Ultra Ball
}