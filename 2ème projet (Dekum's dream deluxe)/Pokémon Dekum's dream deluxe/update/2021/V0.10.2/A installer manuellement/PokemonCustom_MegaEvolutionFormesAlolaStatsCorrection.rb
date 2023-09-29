dépendance : aucune

Dans Pokemon_Custom :
l.85 :
Remplacez :
def type2
      case name
      when "Motisma"
        list = [14, 2, 3, 6, 10, 5]
        type = list[@form]
      else
        type = @type2
      end
Par :
def type2
      case name
      when "Motisma"
        list = [14, 2, 3, 6, 10, 5]
        type = list[@form]
      when "Necrozma"
        list = [11, 2, 3, 11]
        type = list[@form]
      else
        type = @type2
      end
       #---------- Forme Alola -------------
      if @form == 1
        case name
        when "Noadkoko"
          type = 15
        when "Ossatueur"
          type = 14
        when "Racaillou", "Gravalanch", "Grolem"
          type = 4
        when "Raichu"
          type = 11
        end
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Nanméouïe", "Altaria"
          type = 18
        when "Leviator"
          type = 17
        when "Scarabrute"
          type = 10
        when "Galeking"
          type = 0
        end
      end

l.126 :
Remplacez :
def base_atk
      atk_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 180, 70, 95]
        atk_tmp = list[@form] if @form < list.size
      when "Giratina"
        atk_tmp 120 if @form == 1
      end
Par :
def base_atk
      atk_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 180, 70, 95]
        atk_tmp = list[@form] if @form < list.size
      when "Giratina"
        atk_tmp = 120 if @form == 1
      when "Exagide"
        atk_tmp = 150 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint"
          atk_tmp = 75
        when "Gardevoir"
          atk_tmp = 85
        when "Gallame"
          atk_tmp = 165
        when "Ectoplasma"
          atk_tmp = 65
        when "Scarhino"
          atk_tmp = 185
        when "Lucario", "Métalosse", "Drattak"
          atk_tmp = 145
        when "Tyranocif"
          atk_tmp = 164
        when "Altaria"
          atk_tmp = 110
        when "Blizzaroi"
          atk_tmp = 132
        when "Cizayox"
          atk_tmp = 150
        when "Camérupt", "Oniglali"
          atk_tmp = 120
        when "Galeking",  "Sharpedo"
          atk_tmp = 140
        when "Léviator", "Scarabrute"
          atk_tmp = 155
        when "Carchacrok"
          atk_tmp = 170
        when "Charmina"
          atk_tmp = 100
        when "Démolosse"
          atk_tmp = 90
        when "Steelix"
          atk_tmp = 125
        when "Mysdibule"
          atk_tmp = 105
        when "Nanméouie"
          atk_tmp = 60
        end
      end
	  
l.185 :
Remplacez :
def base_dfe
      dfe_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 20, 160, 90]
        dfe_tmp = list[@form] if @form < list.size
      when "Giratina"
        dfe_tmp 100 if @form == 1
      end
Par :
def base_dfe
      dfe_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 20, 160, 90]
        dfe_tmp = list[@form] if @form < list.size
      when "Giratina"
        dfe_tmp = 100 if @form == 1
      when "Exagide"
        dfe_tmp = 50 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint"
          dfe_tmp = 80
        when "Gardevoir"
          dfe_tmp = 65
        when "Gallame"
          dfe_tmp = 95
        when "Ectoplasma"
          dfe_tmp = 80
        when "Scarhino"
          dfe_tmp = 115
        when "Lucario"
          dfe_tmp = 88
        when "Tyranocif"
          dfe_tmp = 150
        when "Altaria"
          dfe_tmp = 110
        when "Blizzaroi"
          dfe_tmp = 105
        when "Cizayox"
          dfe_tmp = 140
        when "Métalosse"
          dfe_tmp = 150
        when "Camérupt"
          dfe_tmp = 100
        when "Galeking", "Steelix"
          dfe_tmp = 230
        when "Léviator"
          dfe_tmp = 109
        when "Carchacrok"
          dfe_tmp = 115
        when "Sharpedo"
          dfe_tmp = 70
        when "Oniglali"
          dfe_tmp = 80
        when "Drattak"
          dfe_tmp = 130
        when "Charmina"
          dfe_tmp = 85
        when "Scarabrute"
          dfe_tmp = 120
        when "Démolosse"
          dfe_tmp = 90
        when "Mysdibule"
          dfe_tmp = 125
        when "Nanméouie"
          dfe_tmp = 126
        end
      end
	  
l.252 :
Remplacez :
def base_spd
      spd_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 150, 90, 180]
        spd_tmp = list[@form] if @form < list.size
      end
Par :
def base_spd
      spd_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 150, 90, 180]
        spd_tmp = list[@form] if @form < list.size
      when "Exagide"
        spd_tmp = 60 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint"
          spd_tmp = 135
        when "Gardevoir", "Oniglali", "Charmina"
          spd_tmp = 100
        when "Gallame", "Métalosse"
          spd_tmp = 110
        when "Ectoplasma"
          spd_tmp = 130
        when "Scarhino", "Cizayox"
          spd_tmp = 75
        when "Lucario"
          spd_tmp = 112
        when "Tyranocif"
          spd_tmp = 71
        when "Altaria"
          spd_tmp = 80
        when "Blizzaroi", "Steelix"
          spd_tmp = 30
        when "Camérupt"
          spd_tmp = 20
        when "Galeking", "Mysdibule", "Nanméouie"
          spd_tmp = 50
        when "Léviator"
          spd_tmp = 81
        when "Carchacrok"
          spd_tmp = 92
        when "Sharpedo"
          spd_tmp = 105
        when "Drattak"
          spd_tmp = 120
        when "Scarabrute" 
          spd_tmp = 105
        when "Démolosse"
          spd_tmp = 115
        end
      end
	  
l.433 :
Remplacez :
def base_ats
      ats_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 180, 70, 95]
        ats_tmp = list[@form] if @form < list.size
      when "Giratina"
        ats_tmp 120 if @form == 1
      end
Par :
def base_ats
      ats_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 180, 70, 95]
        ats_tmp = list[@form] if @form < list.size
      when "Giratina"
        ats_tmp = 120 if @form == 1
      when "Exagide"
        ats_tmp = 150 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint"
          ats_tmp = 135
        when "Gardevoir"
          ats_tmp = 165
        when "Gallame", "Cizayox"
          ats_tmp = 65
        when "Ectoplasma"
          ats_tmp = 170
        when "Scarhino"
          ats_tmp = 40
        when "Lucario", "Démolosse"
          ats_tmp = 140
        when "Tura,pcof"
          ats_tmp = 95
        when "Altaria", "Sharpedo"
          ats_tmp = 110
        when "Blizzaroi"
          ats_tmp = 132
        when "Métalosse"
          ats_tmp = 105
        when "Camérupt"
          ats_tmp = 145
        when "Galeking"
          ats_tmp = 60
        when "Léviator"
          ats_tmp = 70
        when "Carchacrok", "Oniglali", "Drattak"
          ats_tmp = 120
        when "Charmina"
          ats_tmp = 80
        when "Scarabrute"
          ats_tmp = 65
        when "Steelix"
          ats_tmp = 55
        when "Nanméouie"
          ats_tmp = 80
        end
      end
	  
l.362 :
Remplacez :
def base_dfs
      dfs_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 20, 160, 90]
        dfs_tmp = list[@form] if @form < list.size
      when "Giratina"
        dfs_tmp 100 if @form == 1
      end
Par :
def base_dfs
      dfs_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 20, 160, 90]
        dfs_tmp = list[@form] if @form < list.size
      when "Giratina"
        dfs_tmp = 100 if @form == 1
      when "Exagide"
        dfs_tmp = 50 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint", "Galeking", "Oniglali", "Charmina"
          dfs_tmp = 80
        when "Gardevoir"
          dfs_tmp = 135
        when "Gallame"
          dfs_tmp = 115
        when "Ectoplasma", "Carchacrok"
          dfs_tmp = 95
        when "Scarhino", "Camérupt"
          dfs_tmp = 105
        when "Lucario"
          dfs_tmp = 70
        when "Tyranocif"
          dfs_tmp = 120
        when "Altaria", "Blizzaroi"
          dfs_tmp = 105
        when "Cizayox"
          dfs_tmp = 100
        when "Métalosse"
          dfs_tmp = 110
        when "Léviator"
          dfs_tmp = 130
        when "Sharpedo", "Scarabrute"
          dfs_tmp = 65
        when "Drattak"
          dfs_tmp = 90
        when "Démolosse"
          dfs_tmp = 140
        when "Steelix", "Mysdibule"
          dfs_tmp = 55
        when "Nanméouie"
          dfs_tmp = 126
        end
      end
