#==============================================================================
# ■ Generateur_Equipes_Ennemies
#   Fl0rent_
#------------------------------------------------------------------------------
#random_trainer(ID, taille_equipe , tags)
#Remplacez
#ID par l'id du dresseur a modifier dans la BDD
#taille par la taille de son equipe
#et tags par les listes a utiliser, suivant ce format : 
#  "-exemple1-exemple2-exemple3-" 
#  (vous pouvez aussi ne rien mettre, ce qui fera que les Pokémon de toutes les catégories pourront être utilisés.)
def random_trainer(n, x, l = nil)
  
  # mettez not l.include?("-categorie-") si vous voulez spécifier les
  # pokémon interdits
  
  list = []
  #list[n] = ([id,niveau,objet (marquer nil si aucun),[iv_pv,iv_atk,iv_def,iv_vit,iv_atk_spé,iv_def_spé]["ATK1", "ATK2", "ATK3", "ATK4"], nil, nil, false(true pour shiny), 1, [ev_pv,ev_atk,ev_def,ev_vit,ev_atk_spé,ev_def_spé])
  if l == nil or l.include?("-exempletag1-")
    list.push([18 ,50 ,"BAIE SITRUS",[rand(29),rand(29),rand(29),rand(29),rand(29),rand(29)], ["CYCLONE", "ATTERRISSAGE", "AILE D'ACIER", "AEROPIQUE"], nil, nil, false, 1, [6, 0, 0, 200, 200, 0]])
    list.push([277 ,50 ,"BAIE SITRUS",[rand(29),rand(29),rand(29),rand(29),rand(29),rand(29)], ["AEROPIQUE", "EFFORT", "LAME D'AIR", "HATE"], nil, nil, false, 1, [6, 0, 0, 0, 200, 200]])
  end
    
  if l == nil or l.include?("-exempletag2-")
    list.push([24 ,50 ,"BAIE SITRUS",[rand(29),rand(29),rand(29),rand(29),rand(29),rand(29)], ["STOCKAGE", "AVALE", "RELACHE", "MACHOUILLE"], nil, nil, false, 1, [6, 0, 200, 0, 0, 200]])
    list.push([94 ,50 ,"BAIE SITRUS",[rand(29),rand(29),rand(29),rand(29),rand(29),rand(29)], ["ONDE FOLIE", "POING OMBRE", "TOXIK", "REPRESAILLES"], nil, nil, false, 1, [6, 0, 0, 0, 200, 200]])
  end

  if l == nil or l.include?("-categorie-") 
    #inserez  les Pokémon ici
  end
   
     
  team = []
  x.times do |p|
    if p >= team.length
      team.push(list[rand(list.length)])
    else
      loop do
        valide = false
        pkmn = list[rand(list.length)]
        p.times do |v|
          if pkmn[0] != team[v][0]
            valide = true
          else
            valide = false
          end
        end
        break if valide
      end
      team.push pkmn
    end
  end
  $data_trainer[n][Trainer_Info.index_page(n)].info_pokemon = team  
end