#==============================================================================
# ¦ Pokemon_Types
# Pokemon Script Project - Krosk 
# 21/08/08
#-----------------------------------------------------------------------------
# Support de création de nouveaux types
#-----------------------------------------------------------------------------

module POKEMON_S
  
# *****************
#      ETAPE 1
# *****************
# Avant de créer un nouveau type, assignez lui un numéro de type :
#  1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
#  10 vol 11 psy 12insecte 13 roche 14 spectre 15 dragon 16 acier 17 tenebre
#
# Visiblement, si vous creez votre premier type, le prochain numéro est 18.
#
#
# *****************
#      ETAPE 2
# *****************
#
# Ajoutez donc dans le dossier Graphics/Pictures, une image T18.png qui
# sera l'image de votre type. Pour un numéro XX, l'image à ajouter est TXX.png
#
#
# *****************
#      ETAPE 3
# *****************
#
# La table ci-dessous représente le rapport de forces entre types de Pokémons
# Les lignes sont les types de l'attaque, les colonnes sont les types de la cible
# Pour créer un nouveau type, ajoutez une ligne et une colonne au tableau et
# remplissez les champs
#
# Je n'ai pas mis d'exemple, ca complique pas mal la structure
#
# 1 = dégat normal , 2 = dégat doublé (super efficace) , 
# 0.5 = dégat moitié (pas très efficace) , 0 = inefficace
#
#  0 Sans type = pas de modificateur
#  1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
#  10 vol 11 psy 12 insecte 13 roche 14 spectre 15 dragon 16 acier 17 tenebre
  $data_table_type = []
#                            0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18
  $data_table_type[ 0 ]=[    1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1]
  $data_table_type[ 1 ]=[    1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   2 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   0 ,   1 ,   1 ,   1 ,   1]
  $data_table_type[ 2 ]=[    1 ,   1 , 0.5 ,   2 ,   1 , 0.5 , 0.5 ,   1 ,   1 ,   2 ,   1 ,   1 , 0.5 ,   2 ,   1 ,   1 , 0.5 ,   1 , 0.5]
  $data_table_type[ 3 ]=[    1 ,   1 , 0.5 , 0.5 ,   2 ,   2 , 0.5 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 , 0.5 ,   1 ,   1]
  $data_table_type[ 4 ]=[    1 ,   1 ,   1 ,   1 , 0.5 ,   1 ,   1 ,   1 ,   1 ,   2 , 0.5 ,   1 ,   1 ,   1 ,   1 ,   1 , 0.5 ,   1 ,   1]
  $data_table_type[ 5 ]=[    1 ,   1 ,   2 , 0.5 , 0.5 , 0.5 ,   2 ,   1 ,   2 , 0.5 ,   2 ,   1 ,   2 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1]
  $data_table_type[ 6 ]=[    1 ,   1 ,   2 ,   1 ,   1 ,   1 , 0.5 ,   2 ,   1 ,   1 ,   1 ,   1 ,   1 ,   2 ,   1 ,   1 ,   2 ,   1 ,   1]
  $data_table_type[ 7 ]=[    1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   2 ,   2 , 0.5 , 0.5 ,   1 ,   1 ,   1 , 0.5 ,   2]
  $data_table_type[ 8 ]=[    1 ,   1 ,   1 ,   1 ,   1 , 0.5 ,   1 , 0.5 , 0.5 ,   2 ,   1 ,   2 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 , 0.5]
  $data_table_type[ 9 ]=[    1 ,   1 ,   1 ,   2 ,   0 ,   2 ,   2 ,   1 , 0.5 ,   1 ,   1 ,   1 ,   1 , 0.5 ,   1 ,   1 ,   1 ,   1 ,   1]
  $data_table_type[ 10 ]=[   1 ,   1 ,   1 ,   1 ,   2 , 0.5 ,   2 , 0.5 ,   1 ,   0 ,   1 ,   1 , 0.5 ,   2 ,   1 ,   1 ,   1 ,   1 ,   1]
  $data_table_type[ 11 ]=[   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 , 0.5 ,   1 ,   1 ,   1 , 0.5 ,   2 ,   1 ,   2 ,   1 ,   1 ,   2 ,   1]
  $data_table_type[ 12 ]=[   1 ,   1 ,   2 ,   1 ,   1 , 0.5 ,   1 , 0.5 ,   1 , 0.5 ,   2 ,   1 ,   1 ,   2 ,   1 ,   1 ,   1 ,   1 ,   1]
  $data_table_type[ 13 ]=[   1 , 0.5 , 0.5 ,   2 ,   1 ,   2 ,   1 ,   2 , 0.5 ,   2 , 0.5 ,   1 ,   1 , 0.5 ,   1 ,   1 ,   2 ,   1 ,   1]
  $data_table_type[ 14 ]=[   1 ,   0 ,   1 ,   1 ,   1 ,   1 ,   1 ,   0 , 0.5 ,   1 ,   1 ,   1 , 0.5 ,   1 ,   2 ,   1 ,   1 ,   2 , 0.5]
  $data_table_type[ 15 ]=[   1 ,   1 , 0.5 , 0.5 , 0.5 , 0.5 ,   2 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   2 ,   1 ,   1 ,   2]
  $data_table_type[ 16 ]=[   1 , 0.5 ,   2 ,   1 ,   1 , 0.5 , 0.5 ,   2 ,   0 ,   2 , 0.5 , 0.5 , 0.5 , 0.5 , 0.5 , 0.5 , 0.5 , 0.5 , 0.5]
  $data_table_type[ 17 ]=[   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   2 ,   1 ,   1 ,   1 ,   0 ,   2 ,   1 , 0.5 ,   1 ,   1 , 0.5 ,   2]
  $data_table_type[ 18 ]=[   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 , 0.5 ,   2 ,   1 ,   1 ,   1 , 0.5 ,   1 ,   1 ,   0 ,   2 , 0.5 ,   1]
# En cas d'ajoute, exemple :
# $data_table_type[ 19 ]=[   1 , 0.5 ,   2 ,   1 ,   1 , 0.5 , 0.5 ,   2 ,   0 ,   2 , 0.5 , 0.5 , 0.5 , 0.5 , 0.5 , 0.5 , 0.5 , 0.5 ,   2]
# $data_table_type[ 20 ]=[   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   2 ,   1 ,   1 ,   1 ,   0 ,   2 ,   1 , 0.5 ,   1 ,   1 , 0.5 , 0.5]
# $data_table_type[ 21 ]=[   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1 ,   1]  

  
# *****************
#      ETAPE 4
# *****************
  
  class Pokemon_Battle_Core
    alias alias_type_string type_string
    def type_string(type)
      return alias_type_string(type) if alias_type_string(type) != nil
      case type
      # Pour chaque type ajouté, ajoutez les 2 lignes suivantes,
      # avec le nom de votre type avec son numéro comme dans l'exemple
      # Les noms sont fakes...
      # ----------
      # when numero_de_type
      #  return "NOM_DE_TYPE"
      # ----------
      # ******** Ajout à partir d'ici *************
      when 18
        return "FEE"
      when 19
        return "COSMIQUE"

      # ******** Ne pas modifier après cette ligne ***********
      end
    end
  end
  
# *****************
#      ETAPE 5
# *****************

  class Pokemon
    # Pour définir votre type custom et utiliser les effets spéciaux des attaques,
    # Creons une fonction pour faciliter la vérification de type comme ca
    # Il faut ajouter ces lignes suivantes
    # -----------------------------------------
    # def type_nom_de_type?
    #   return type_custom?(numero_de_type)
    # end
    # -----------------------------------------
    # ******** Ajout à partir d'ici *************
    def type_fee?
      return type_custom?(18)
    end
    def type_cosmique?
      return type_custom?(19)
    end
    # ******** Ne pas modifier après cette ligne ***********
  end
  
# *****************
#      ETAPE 6
# *****************

# En BDD, onglet système, ajoutez un nouveau type et nommez le.
# Bravo, c'est terminé.

end