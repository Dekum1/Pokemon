#==============================================================================
# ■ Gestion_Effets
# Pokemon Script Project - Krosk 
# Gestion_Effets - Damien Linux
# 13/01/2020
#-----------------------------------------------------------------------------
# Modulable
#-----------------------------------------------------------------------------
# Attribution des ID des effets aux clés d'exécution de ces effets
#-----------------------------------------------------------------------------
module POKEMON_S
  ID_EFFECTS = {
                  # BERCEUSE / HYPNOSE / GROBISOU / SIFFL'HERBE / TROU NOIR
                  1 => :sommeil,
                  # DARD-VENIN / PUREDPOIS / DETRITUS / BOMB-BEURK / 
                  # DIRECT TOXIK / DETRICANON / CRADOVAGUE
                  2 => :poison,
                  # VOL-VIE / MEGA-SANGSUE / VAMPIRISME / GIGA-SANGSUE / 
                  # VAMPIPOING / ENCORNEBOIS
                  3 => :recuperation_pv,
                  # POING DE FEU / FLAMMECHE / LANCE-FLAMME / DEFLAGRATION / 
                  # CANICULE / EBULLILAVE / CROCS FEU / FLAMME BLEUE / 
                  # FEU D'ENFER / INCENDIE
                  4 => :brulure,
                  # POING-GLACE / LASER GLACE / BLIZZARD / POUDREUSE / 
                  # CROCS GIVRE
                  5 => :gel,
                  # POING ECLAIR / PLAQUAGE / ECLAIR / TONNERRE / 
                  # LECHOUILLE / ELECANON / ETINCELLE / DRACOSOUFFLE / 
                  # FORTE-PAUME / CROCS ECLAIR / COUP D'JUS / CHARGE FOUDRE
                  6 => :paralysie,
                  # DESTRUCTION / EXPLOSION
                  7 => :auto_ko,
                  # DEVOREVE
                  8 => :devoreve,
                  # MIMIQUE
                  9 => :mimique,
                  # YOGA / AFFUTAGE / GRONDEMENT
                  10 => :augmente_attaque,
                  # ARMURE / REPLI
                  11 => :augmente_defense,
                  # NITROCHARGE
                  12 => :augmente_vitesse,
                  # CROISSANCE
                  13 => :croissance,
                  # BOULE ELEK
                  14 => :boule_elek,
                  # VIBRA SOIN
                  15 => :vibra_soin,
                  # REFLET
                  16 => :augmente_esquive,
                  # METEORES / FEINTE / POING OMBRE / AEROPIQUE / 
                  # FEUILLEMAGIK / ONDE DE CHOC / AURASPHERE / BOMBAIMANT
                  17 => :sans_echec,
                  # RUGISSEMENT
                  18 => :baisse_attaque,
                  # MIMI-QUEUE / GROZ'YEUX
                  19 => :baisse_dfe,
                  # SECRETION
                  20 => :secretion,
                  # EBULLITION
                  21 => :ebullition,
                  # MANIA
                  22 => :mania,
                  # JET DE SABLE / BROUILLARD / TELEKINESIE / FLASH
                  23 => :baisse_precision,
                  # DOUX PARFUM
                  24 => :doux_parfum,
                  # BUEE NOIR / BAIN DE SMOG 
                  25 => :annule_changement_stats,
                  # PATIENCE
                  26 => :patience,
                  # DANSE-FLEUR / COLERE
                  27 => :multi_tour_confus,
                  # CYCLONE / HURLEMENT / PROJECTION
                  28 => :changement_force,
                  # TORGNOLES / POINT COMETE / FURIE / DARD-NUEE / PICANON / 
                  # PILONNAGE / COMBO-GRIFFE / CHARGE-OS / COGNE / 
                  # BALLE GRAINE / STALAGTITE / BOULE ROC / PLUMO-QUEUE
                  29 => :attaque_combo,
                  # ADAPTATION
                  30 => :adaptation,
                  # MAWASHI GERI / COUP D'BOULE / MORSURE / MASSD'OS / 
                  # EBOULEMENT / CROC DE MORT / VIBROBSCUR / DRACOCHARGE / 
                  # LAME D'AIR / PSYKOUD'BOUL / TETE DE FER / CREVECOEUR
                  31 => :apeurer,
                  # SOIN / PARESSE / APPEL SOIN
                  32 => :guerison,
                  # TOXIK
                  33 => :toxik,
                  # JACKPOT
                  34 => :jackpot,
                  # MUR LUMIERE
                  35 => :mur_lumiere,
                  # TRIPLATTAQUE
                  36 => :triplattaque,
                  # REPOS
                  37 => :repos,
                  # GUILLOTINE / EMPAL'KORNE / ABIME / GLACIATION
                  38 => :ko_un_coup,
                  # COUPE VENT
                  39 => :coupe_vent,
                  # CROC FATAL
                  40 => :croc_fatal,
                  # DRACO-RAGE
                  41 => :draco_rage,
                  # ETREINTE / LIGOTAGE / DANSEFLAMME / CLAQUOIR / SIPHON / 
                  # TOURBI-SABLE / VORTEX MAGMA 
                  42 => :ligotement,
                  # POING KARATE / TRANCH'HERBE / PINCE-MASSE / TRANCHE / 
                  # AEROBLAST / COUP-CROIX / TRANCH'AIR / LAME-FEUILLE / 
                  # TRANCHE-NUIT / GRIFFE OMBRE / COUPE PSYCHO / 
                  # POISON-CROIX / LAME DE ROC / APPEL ATTAK / SPATIO-RIFT / 
                  # SOUFFLE GLACE / YAMA ARASHI / TUNNELIER
                  43 => :critique_eleve,
                  # DOUBLE PIED / OSMERANG / COUP DOUBLE / DOUBLE BAFFE / 
                  # LANCECROU
                  44 => :double_frappe,
                  # PIED SAUTE / PIED VOLTIGE
                  45 => :coup_rate_blesse,
                  # BRUME
                  46 => :brume,
                  # PUISSANCE
                  47 => :puissance,
                  # BELIER / SACRIFICE / LUTTE / ECLAIR FOU
                  48 => :charge_blesse,
                  # ULTRASON / ONDE FOLIE / DOUX BAISER
                  49 => :confusion,
                  # DANSE-LAMES
                  50 => :danse_lames,
                  # BOUCLIER / ACIDARMURE / MUR DE FER / COTOGARDE
                  51 => :augmente_defense_2,
                  # HATE / POLIROCHE / ALLEGEMENT
                  52 => :augmente_vitesse_2,
                  # LUMIQUEUE / MACHINATION
                  53 => :augmente_attaque_spe_2,
                  # AMNESIE
                  54 => :amnesie,
                
                  # MORPHING
                  57 => :morphing,
                  # CHARME / DANSE-PLUME
                  58 => :baisse_attaque_2,
                  # GRINCEMENT
                  59 => :baisse_defense_2,
                  # SPORE COTON / GRIMACE
                  60 => :baisse_vitesse_2,
                  # ERE GLACIAIRE / TOILE ELEK
                  61 => :baisse_vitesse,
                  # CROCO LARME / STRIDO-SON / FULMIGRAINE / BOMBE ACIDE
                  62 => :baisse_defense_spe_2,
                  
                  # PROTECTION
                  65 => :protection,
                  # GAZ TOXIK
                  66 => :gaz_toxik,
                  # INTIMIDATION
                  67 => :intimidation,
                  # ONDE BOREALE
                  68 => :onde_boreale,
                  # ACIDE / QUEUE DE FER / ECLATE-ROC / ECLATEGRIFFE / 
                  # COQUILAME
                  69 => :baisse_defense_attaque,
                  # BULLE D'O / CONSTRICTION / ECUME / VENT GLACE / 
                  # TOMBEROCHE / TIR DE BOUE / PIETISOL / BALAYETTE
                  70 => :baisse_vitesse_attaque,
                  # BALL'BRUME / ABOIEMENT / SURVINSECTE 
                  71 => :baisse_attaque_spe,
                  # PSYKO / MACHOUILLE / BALL'OMBRE / LUMI-ECLAT / BOURDON / 
                  # EXPLOFORCE / ECO-SPHERE / TELLURIFORCE / LUMINOCANON / 
                  # LUMI ECLAT
                  72 => :baisse_defense_spe,
                  # COUD'BOUE / OCTAZOOKA / OCROUPI / BOUE-BOMBE / 
                  # MIROI-TIR / PHYTOMIXEUR / EXPLONUIT
                  73 => :baisse_precision_attaque,
                  
                  # PIQUE
                  75 => :pique,
                  # RAFALE PSY / CHOC MENTAL / UPPERCUT / DYNAMOPOING / 
                  # RAYON SIGNAL / VIBRAQUA / ESCALADE / BABIL / 
                  # VENT VIOLENT
                  76 => :confusion_attaque,
                  # DOUBLE-DARD
                  77 => :double_dard,
                  # CORPS PERDU
                  78 => :corps_perdu,
                  # CLONAGE
                  79 => :clonage_attaque,
                  # RAFALE FEU / HYDROBLAST / VEGE-ATTAK / GIGA IMPACT / 
                  # ROC-BOULET / HURLE-TEMPS
                  80 => :rechargement,
                  # FRENESIE
                  81 => :frenesie,
                  # COPIE
                  82 => :copie,
                  # METRONOME
                  83 => :metronome,
                  # VAMPIGRAINE
                  84 => :vampigraine,
                  # TREMPETTE
                  85 => :trempette,
                  # ENTRAVE
                  86 => :entrave,
                  # FRAPPE ATLAS / TENEBRES
                  87 => :degats_niveau,
                  # VAGUE PSY
                  88 => :vague_psy,
                  # RIPOSTE
                  89 => :riposte,
                  # ENCORE
                  90 => :encore,
                  # BALANCE
                  91 => :balance,
                  # RONFLEMENT
                  92 => :ronflement,
                  # CONVERSION 2
                  93 => :conversion_2,
                  # LIRE-ESPRIT / VEROUILLAGE
                  94 => :reussite_sur,
                  # GRIBOUILLE
                  95 => :gribouille,
                  
                  # BLABLA DODO
                  97 => :blabla_dodo,
                  # PRLVT.DESTIN
                  98 => :prlvt_destin,
                  # FLEAU / CONTRE
                  99 => :degats_faible,
                  # DEPIT
                  100 => :depit,
                  # FAUX CHAGE
                  101 => :faux_chage,
                  # GLAS DE SOIN / AROMATHERAPI
                  102 => :soin_status,
                  # VIVE-ATTAQUE / MACH PUNCH / VIT. EXTREME / ONDE VIDE / 
                  # PISTO-POING / ECLATS GLACE / OMBRE PORTEE / AQUA JET / 
                  # A LA QUEUE
                  103 => :attaque_avant,
                  # TRIPLE PIED
                  104 => :triple_pied,
                  # LARCIN / IMPLORE
                  105 => :pique_objet,
                  # TOILE / REGARD NOIR / BARRAGE
                  106 => :empeche_fuite,
                  # CAUCHEMARD
                  107 => :cauchemard,
                  # LILLIPUT
                  108 => :lilliput,
                  # MALEDICTION
                  109 => :malediction,
                  
                   # ABRI / DETECTION / GARDE LARGE
                  111 => :encaissement_attaque,
                  # PICOTS
                  112 => :picots,
                  # CLAIRVOYANCE / FLAIR
                  113 => :empeche_esquive,
                  # REQUIEM
                  114 => :requiem,
                  # TEMPETESABLE
                  115 => :tempetesable,
                  # TENACITE
                  116 => :tenacite,
                  # ROULADE / BALL'GLACE
                  117 => :multi_tour_puissance,
                  # VANTARDISE
                  118 => :vantardise,
                  # TAILLADE / ECHO
                  119 => :effets_augmentes_tour,
                  # ATTRACTION
                  120 => :attraction,
                  # RETOUR
                  121 => :retour,
                  # CADEAU
                  122 => :cadeau,
                  # FRUSTRATION
                  123 => :frustration,
                  # RUNE PROTECT
                  124 => :rune_protect,
                  # ROUE DE FEU / FEU SACRE
                  125 => :degele_brule,
                  # AMPLEUR
                  126 => :ampleur,
                  # RELAIS
                  127 => :relais,
                  # POURSUITE
                  128 => :poursuite,
                   # TOUR RAPIDE
                  129 => :tour_rapide,
                  # SONICBOOM
                  130 => :sonicboom,
                  
                  # AURORE
                  132 => :aurore,
                  # SYNTHESE
                  133 => :synthese,
                  # RAYON LUNE
                  134 => :rayon_lune,
                  # PUIS.CACHEE
                  135 => :puis_cachee,
                  # DANSE-PLUIE
                  136 => :danse_pluie,
                  # ZENITH
                  137 => :zenith,
                  # AILE D'ACIER
                  138 => :aile_acier,
                  # GRIFFE ACIER / POING METEOR
                  139 => :augmente_attaque_attaque,
                  # POUV.ANTIQUE / VENT ARGENTE / VENT MAUVAIS 
                  140 => :augmente_stats,
                  
                  # COGNOBIDON
                  142 => :cognobidon,
                  # BOOST
                  143 => :boost,
                  # VOILE MIROIR
                  144 => :voile_miroir,
                  # COUD'KRANE
                  145 => :coud_krane,
                  # OURAGAN
                  146 => :ouragan,
                  # SEISME
                  147 => :seisme ,
                  # PRESCIENCE 
                  148 => :prescience,
                  # TORNADE
                  149 => :tornade,
                  # ECRASEMENT / POING DARD / ETONNEMENT / EXTRASENSEUR / 
                  # CHUTE GLACE / BULLDOBOULE
                  150 => :apeurer_attaque,
                  # LANCE-SOLEIL
                  151 => :lance_soleil,
                  # FATAL FOUDRE
                  152 => :fatal_foudre,
                  # TELEPORT
                  153 => :teleport,
                  # BASTON
                  154 => :baston,
                  # CARNAREKET
                  155 => :carnareket,
                  # BOUL'ARMURE
                  156 => :boul_armure,
                  # E-COQUE / LAIT A BOIRE 
                  157 => :regagne_pv_moitie,
                  # BLUFF
                  158 => :bluff,
                  # BROUHAHA
                  159 => :brouhaha,
                  # STOCKAGE
                  160 => :stockage,
                  # RELACHE
                  161 => :relache,
                  # AVALE
                  162 => :avale,
                  
                  # GRELE
                  164 => :grele,
                  # TOURMENTE
                  165 => :tourmente,
                  # FLATTERIE
                  166 => :flatterie,
                  # FEU FOLLET
                  167 => :feu_follet,
                  # SOUVENIR
                  168 => :souvenir,
                  # FACADE
                  169 => :facade,
                  # MITRA-POING
                  170 => :mitra_poing,
                  # STIMULANT
                  171 => :stimulant,
                  # PAR ICI
                  172 => :par_ici,
                  # FORCE-NATURE
                  173 => :force_nature,
                  # CHARGEUR
                  174 => :chargeur,
                  # PROVOC
                  175 => :provoc,
                  # COUP D'MAIN
                  176 => :coup_main,
                  # TOURMAGIK / PASSE-PASSE
                  177 => :echange_objet,
                  # IMITATION
                  178 => :imitation,
                  # VOEU
                  179 => :voeu,
                  # ASSISTANCE
                  180 => :assistance,
                  # RACINES
                  181 => :racines,
                  # SURPUISSANCE
                  182 => :surpuissance,
                  # REFLET MAGIK
                  183 => :reflet_magik,
                  # RECYCLAGE
                  184 => :recyclage,
                  # VENDETTA / AVALANCHE
                  185 => :puissant_si_blesse,
                  # CASSE-BRIQUE
                  186 => :casse_brique,
                  # BAILLEMENT
                  187 => :baillement,
                  # SABOTAGE
                  188 => :sabotage,
                  # EFFORT
                  189 => :effort,
                  # ERUPTION / GICLEDO
                  190 => :degats_si_pv,
                  # ECHANGE
                  191 => :echange,
                  # POSSESSIF
                  192 => :possessif,
                  # REGENERATION
                  193 => :regeneration,
                  # RANCUNE
                  194 => :rancune,
                  # SAISIE
                  195 => :saisie,
                  # BALAYAGE / NOEUD HERBE
                  196 => :poids_degats,
                  # TACLE LOURD / TACLE FEU
                  197 => :tacle,
                  # DAMOCLES / ELECTALE / RAPACE / MARTOBOIS / 
                  # FRACASS'TETE / PEIGNEE
                  198 => :degats,
                  # DANSE-FOLLE
                  199 => :danse_folle,
                  # PIED BRULEUR
                  200 => :pied_bruleur,
                  # LANCE-BOUE
                  201 => :lance_boue,
                  # CROCHET VENIN
                  202 => :crochet_venin,
                  # BALL'METEO
                  203 => :ball_meteo,
                  # SURCHAUFFE / PSYCHO BOOST / DRACO METEOR / TEMPETEVERTE
                  204 => :baisse_attaque_spe_attaque,
                  # CHATOUILLE
                  205 => :chatouille,
                  # FORCE COSMIK / APPEL DEFENS
                  206 => :augmentation_dfs_dfe,
                  # STRATOPERCUT
                  207 => :stratopercut,
                  # GONFLETTE
                  208 => :gonflette,
                  # QUEUE POISON
                  209 => :queue_poison,
                  # TOURNIQUET
                  210 => :tourniquet,
                  # PLENITUDE
                  211 => :plenitude,
                  # DANSE DRACO
                  212 => :danse_draco,
                  
                  # ATTERISSAGE
                  214 => :atterissage,
                  # GRAVITE
                  215 => :gravite,
                  # OEIL MIRACLE
                  216 => :oeil_miracle,
                  # REVEIL FORCE
                  217 => :reveil_force,
                  # MARTO-POING
                  218 => :marto_poing,
                  # GYROBALLE
                  219 => :gyroballe,
                  # VOEU SOIN
                  220 => :voeu_soin,
                  # SAUMURE
                  221 => :saumure,
                  # DON NATUREL
                  222 => :don_naturel,
                  # RUSE
                  223 => :ruse,
                  # PICORE / PIQURE
                  224 => :mange_baie,
                  # VENT ARRIERE
                  225 => :vent_arriere,
                  # ACUPRESSION
                  226 => :acupression,
                  # FULMIFER
                  227 => :fulmifer,
                  # DEMI-TOUR
                  228 => :demi_tour,
                  # CLOSE COMBAT
                  229 => :close_combat,
                  # REPRESAILLES
                  230 => :represailles,
                  # ASSURANCE
                  231 => :assurance,
                  # EMBARGO
                  232 => :embargo,
                  # DEGOMMAGE
                  233 => :degommage,
                  # ECHANGE PSY
                  234 => :echange_psy,
                  # ATOUT
                  235 => :atout,
                  # ANTI-SOIN
                  236 => :anti_soin,
                  # ESSORAGE / PRESSE
                  237 => :degats_plus_de_pv,
                  # ASTUCE FORCE
                  238 => :astuce_force,
                  # SUC DIGESTIF
                  239 => :suc_digestif,
                  # AIR VEINARD
                  240 => :air_veinard,
                  # MOI D'ABORD
                  241 => :moi_dabord,
                  # PHOTOCOPIE
                  242 => :photocopie,
                  # PERMUFORCE
                  243 => :permuforce,
                  # PERMUGARDE
                  244 => :permugarde,
                  # PUNITION
                  245 => :punition,
                  # DERNIERECOUR
                  246 => :dernierecour,
                  # SOUCIGRAINE
                  247 => :soucigraine,
                  # COUP BAS
                  248 => :coup_bas,
                  # PICS TOXIK
                  249 => :pics_toxik,
                  # PERMUCOEUR
                  250 => :permucoeur,
                  # ANNEAU HYDRO
                  251 => :anneau_hydro,
                  # VOL MAGNETIK
                  252 => :vol_magnetik,
                  # BOUTEFEU
                  253 => :boutefeu,
                  # CROCS ECLAIR
                  254 => :crocs_eclair,
                  # CROCS GIVRE
                  255 => :crocs_givre,
                  # CROCS FEU
                  256 => :crocs_feu,
                  # ANTI-BRUME
                  257 => :anti_brume,
                  # DISTORSION
                  258 => :distorsion,
                  # SEDUCTION
                  259 => :seduction,
                  # PIEGE DE ROC
                  260 => :piege_de_roc,
                  # CAGE-ECLAIR
                  261 => :cage_eclair,
                  # PARA-SPORE
                  262 => :para_spore,
                  # RAYON-CHARGE / DANSE DU FEU
                  263 => :augmentation_attaque_spe,
                  # REVENANT
                  264 => :revenant,
                  # POUDRE TOXIK
                  265 => :poudre_toxik,
                  # POUDRE DODO / SPORE
                  266 => :poudre_dodo,
                  # CHANGE ECLAIR
                  267 => :change_eclair,
                  # JUGEMENT
                  268 => :jugement,
                  # ULTRALASER
                  269 => :ultralaser,
                  # AIGUISAGE
                  270 => :aiguisage,
                  # CORPS MAUDIT
                  271 => :corps_maudit,
                  # DEFAITISTE
                  272 => :defaitiste,
                  # RENGORGEMENT
                  273 => :rengorgement,
                  # PAPILLODANSE
                  274 => :papillodanse,
                  # DEFENSE SPEC.
                  275 => :defense_spec,
                  
                  # TUNNEL
                  2480 => :tunnel,
                  # VOL
                  2481 => :vol,
                  # REBOND
                  2482 => :rebond,
                  # PLONGEE
                  2483 => :plongee
                }
end