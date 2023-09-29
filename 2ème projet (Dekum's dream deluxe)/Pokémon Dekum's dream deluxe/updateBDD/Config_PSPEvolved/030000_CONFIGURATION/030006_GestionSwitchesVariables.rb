#==============================================================================
# ■ Gestion_Switches_Variables
# Pokemon Script Project - Krosk 
# Gestion_Switches_Variables - Damien Linux
# 14/01/2020
#-----------------------------------------------------------------------------
# Modulable
#-----------------------------------------------------------------------------
# ------------------------------------------------------------
#     Interrupteurs
# ------------------------------------------------------------
# -- Système Jour/Nuit --
# SWITCH_EXTERIEUR définit si la map est en exterieure (true) ou pas (false)
SWITCH_EXTERIEUR = 2 
MATIN_SWITCHES = 3
APRES_MIDI_SWITCHES = 4
NUIT_SWITCHES = 5

# -- Choix Perso --
FILLE = 9 # Héroïne
GARCON = 8 # Héros

# Animation des Pokémon du menu
ANIMATION_MENU = 10

CHAUSSURE_DE_SPORT = 11 # Utilisation des chassures de sports

DISTRIBUTEUR = 12 # Si activé, le shop se transforme en distributeur au lieu d'un magasin 

# -- Combat VS 6G --
LANCEMENT_VS = 15
ANIMATION_VS = 16
EFFACEMENT_VS = 17

BLOQUEE = 18 # Empêche l'effet sonore "BUMP" en cas d'obstacle déjà rencontré

MODE_REGIONAL = 20 # Pokédex régional

# -- Soin Equipe --
CENTRE_POKEMON = 23
CLIGNOTEMENT = 24

PKM_TRANSPARENT_SWITCHES = 25 # Index de l'interrupteur pour rendre invisible

# -- Activation Badge --
BADGE_1 = 27
BADGE_2 = 28
BADGE_3 = 29
BADGE_4 = 30
BADGE_5 = 31
BADGE_6 = 32
BADGE_7 = 33
BADGE_8 = 34

# -- Etat Combat --
INTERDICTION_FUITE = 37 # Interdiction de fuire
INTERDICTION_CAPTURE = 36 # Interdiction de capturer un pokémon

# -- Autorisation --
BICYCLETTE_AUTORISE = 39
TUNNEL_AUTORISE = 40
FLASH_AUTORISE = 41
ANTI_BRUME_AUTORISE = 42
COUPE_AUTORISE = 43
ECLATE_ROC_AUTORISE = 44
VOL_AUTORISE = 45
SURF_AUTORISE = 46
FORCE_AUTORISE = 48
# Indique que la canne peut être possible (automatique)
AUTORISE_CANNE = 51

# -- Action --
EN_BICYCLETTE = 52 # Lorsque l'utilisateur utilise sa bicyclette
MODE_SURF = 53
FORCE = 54

# -- Endroit Spécial --
PISTE_CYCLABE = 59

# -- Gestion des baies
LANCEMENT_BAIE = 61

OMBRE_NON_ACTIF = 62

POKEMON_ANIME = 63

# -- Condition CS --
FLASH_UTILISE = 65
SURF_IMPOSSIBLE = 66
ANTI_BRUME_UTILISE = 67

# -- Acquisition --
ACCES_JOURNAL = 73 # Accès au journal des quêtes

# -- Carte --
MAPLINK_SWITCHES = 82 # Activation du Maplink

# -- Localisation --
GROTTE = 87 # Si on est dans une grotte, utile pour la sombre ball
SURF_PECHE = 88 # Si on pêche ou que surf est activé, utile pour la scuba ball

# -- Paramètre Combat -
EXP_BLOQUE = 90 # Si true alors les acteurs ne gagnent pas de points d'expériences
SWITCH_POKEMON_BLOQUE = 91   # Si true alors le choix de switch n'est pas affiché lorsque le pokémon adverse est K.O.

SORTIR_BATIMENT = 92

# -- Reflets --
GRAPHISME_3G = 93
GRAPHISME_4G = 94
GRAPHISME_5G = 95

JINGLE = 104 # Si true les jingles lors de l'obtention des objets sont activés

# -- Parc Safari --
MODE_SAFARI = 107 # Utilisation du combat en mode Safari
SAFARI_ACTIF = 108
SAFARI_TERMINE = 109

PANTHEON_FIN = 1500

# ------------------------------------------------------------
#     Variables
# ------------------------------------------------------------
MAP_ID = 1
MAP_X = 2
MAP_Y = 3
INDEX_POKEMON = 4
INDEX_SKILL = 5
CARTE = 6
PENSION = 7
SAVESLOT = 8
TRAINER_CODE = 9
ECHANGE_DATA = 10
VAR_SPD = 11
VAR_J = 12
TUNNEl_DIRECTION = 13

SUCCES_CANNE = 20

RARETE_CANNE = 22

# Variables où sont enregistrées les données de Temps.
# Penser à utiliser TIMESYS::update_variables pour les mettres à jour avant de
# les appeler
TS_MIN = 23
TS_HOUR = 24
TS_MDAY = 25

TS_MONTH = 28
TS_NAMEDAY = 29
ID_CARTE = 30
ID_CARTE_BICYCLETTE = 31
IA_SWITCH_BATTLE = 32 # 0 : Parcours séquentiel / 1 : aléatoire / 2 : IA de Switch
NAVIGATION_BOITE = 33
CONFIGURATION_BATTLE_WILD = 34
CONFIGURATION_BATTLE_TRAINER = 35
LEVEL_TOUR_COMBAT = 36 # Variables définissant le niveau des pokémon pendant un combat Si 0 alors les niveaux ne sont pas retouchés
INDEX_BATTLE = 37 # Détermine la page dans "Groupes" de la BDD qui est vérifié pour lancer un combat. Par défaut il s'agit de la page 1
INDEX_WILD_BATTLE = 38 # Détermine la page "Groupes" de la BDD qui est vérifié pour lancer un combat contre un pokémon sauvage. Par défaut il s'agit de la page 1

OLD_X_HEROS = 40
X_HEROS = 41
OLD_Y_HEROS = 42
Y_HEROS = 43

# Indicateur de saison
TS_SEASON = 45
# Indicateur Jour/Nuit
TS_NIGHTDAY = 46
TRAINER = 47

JOUR_BAIE = 48 # Comparé avec TS_MDAY, permet d'actualiser les baies

# -- Parc Safari --
NOMBRE_DE_PAS = 52
PAS_MAXIMUM = 53

# Utilisation de canne possible : à activer sur la map où la canne est utilisable ET que des Pokémon
# peuvent être capturés
CANNE_UTILISABLE = 97
             
ASCENSEUR = 516
                  
CONTENT_DRESSEUR_1 = 1501
CONTENT_DRESSEUR_2 = 1502
CONTENT_DRESSEUR_3 = 1503
CONTENT_DRESSEUR_4 = 1504