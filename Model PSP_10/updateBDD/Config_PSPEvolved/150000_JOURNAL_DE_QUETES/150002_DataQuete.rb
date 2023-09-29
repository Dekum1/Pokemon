module POKEMON_S
  #==============================================================================
  # ■ Systeme de gestion de quête
  #------------------------------------------------------------------------------
  # Script créé par Tonyryu
  # Attention : Ce script est ma propriété en tant que création et il est donc
  # soumis au droit de la propriété intellectuelle ( http://www.irpi.ccip.fr/ ).
  # En aucun cas, il ne doit être copié ou publié vers un autre forum sans en
  # avoir reçu mon accord au préalable.
  #
  # adapté à PSP4G+ par Zelda puis Sphinx
  #==============================================================================
  
  #==============================================================================
  # ■ Data_Quete
  #------------------------------------------------------------------------------
  #  Contient la définition des quêtes
  #   Version   Date          Auteur        Commentaires
  #   1.00      12/09/2007    Tonyryu       Création
  #   1.01      23/09/2007    Tonyryu       Correction d'un bug de comparaison
  #   1.02      26/09/2007    Tonyryu       Correction Anomalie : caractere '\n' non interprété
  #   1.03      03/10/2007    Tonyryu       Correction Anomalie : quete_echouer et quete_finir buggés
  #   1.04      16/07/2008    Tonyryu       Ajout fonction quete_tuer_monstre
  #   1.05      22/07/2008    Tonyryu       Ajout fonction quete_objectif_termine? ,correction d'un bug de validation de quête, les objectifs terminés sont grisés
  #   2.00       2/01/2008    Sphinx        Adaptation à PSP4G+
  #
  #==============================================================================
  class Data_Quete
    attr_accessor   :tab_def_quete
    
    #--------------------------------------------------------------------------
    # ● initialize
    #-------------------------------------------------------------------------- 
    def initialize
      # Création du tableau de quêtes
      @tab_def_quete = []
      # Définition des quêtes
  
=begin
  STRUCTURE GENERALE DE LA DEFINITION D'UNE QUÊTE (où n est le n°de la quête) :
      @tab_def_quete[n] = { "lancement"  => [CONDITIONS],
                            "nom"  => "NOM",
                            "desc" => "DESC1"+
                                     "\nDESC2"+
                                     "\nDESC3"+
                                     "\nDESC4",
                            "but"  => [OBJECTIFS],
                            "gain" => [GAINS]}
      
      CONDITIONS : "AUCUN" : aucune condition de lancement
                   Liste d'IDs des quêtes nécessaires pour le lancement
                   de la quête.
      NOM : nom de la quête
      DESC1 -> DESC4 : description de la quête sur 4 lignes (laisser \n si
                       ligne vide)
      OBJECTIFS : - ["TR_OBJ",Nbre,ID]
                        >> Nbre : nbre d'objets à trouver
                        >> ID : ID de l'objet à trouver

                  - ["PARLER","NOM"]
                        >> NOM : Nom du personnage à rencontrer

                  - ["VOIR",Nbre,ID,POKES]
                        >> Nbre : nbre de pokémons à voir
                        >> ID : NOM entre "" ou ID du pokémon à voir
                        >> POKES : * true :  ne prend pas en compte
                                             les pokémons des
                                             dresseurs
                                   * false : prend en compte les pokémons des
                                             dresseurs
                                   * non précisé >> true

                  - ["VAINCRE",Nbre,ID,POKES]
                        >> Nbre : nbre de pokémons à vaincre
                        >> ID : NOM entre "" ou ID du pokémon à vaincre
                        >> POKES : * true :  ne prend pas en compte
                                             les pokémons des
                                             dresseurs
                                   * false : prend en compte les pokémons des
                                             dresseurs
                                   * non précisé >> true

                  - ["CAPTURER",Nbre,ID,POKES]
                        >> Nbre : nbre de pokémons à capturer
                        >> ID : NOM entre "" ou ID du pokémon à capturer
                        >> POKES : * true :  ne prend pas en compte
                                             les pokémons des
                                             dresseurs
                                   * false : prend en compte les pokémons des
                                             dresseurs
                                   * non précisé >> true

      GAINS : - ["EXP",gain]
                    >> gain : expérience que l'équipe gagne (l'expérience est
                              partagée entre tous les pokémons de l'équipe)

              - ["ARGENT",somme]
                    >> somme : argent remporté

              - ["OBJ",nb,ID]
                    >> ID : ID de l'objet remporté
                    >> nb : nbre d'objets remportés

              - ["POKE",ID,lv,shiny]
                    >> ID : NOM entre "" ou ID du pokémon remporté
                    >> lv : niveau du poké remporté
                    >> shiny : true : poké shiny / false : poké non shiny

=end

      # Exemple en bas... Vous pouvez aussi copiez celui-ci et le collez
      # en dessous pour ensuite le modifiez si vous voulez.
      
      @tab_def_quete[1] = { "lancement"  => [1],
                            "nom"  => "Le Tuto du Kits",
                            "desc" => "Pour términer cette quête,"+
                                     "\nVous devez allé voir Danny Phenton dans son Arènes"+
                                     "\nde la Programmation afin de prouver votre valeur et"+
                                     "\ntésté le Starter Kits PSP 0.9.2 Remastered.",
                            "but"  => [["PARLER","/ Vaincre Danny Phenton"]],
                            "gain" => [["OBJ",1,1],["EXP",2500]]}


    end
  end
  # Créer les données de quête
  $data_quete = Data_Quete.new
end