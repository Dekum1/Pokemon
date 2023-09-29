module Keys
  
  NULL   = 0x00		# NULL Value
  
  
  MOUSE_LEFT   = 0x01		# left mouse button
  MOUSE_RIGHT  = 0x02		# right mouse button
  MOUSE_MIDDLE = 0x04		# middle mouse button
  
  BACK      = 0x08  # BACKSPACE key
  TAB       = 0x09  # TAB key
  ENTER     = 0x0D  # ENTER key
  SHIFT     = 0x10  # SHIFT key
  CTRL      = 0x11  # CONTROL key
  ALT       = 0x12  # ALT key
  PAUSE     = 0x13  # PAUSE key
  CAPS_LOCK = 0x14  # CAPS LOCK key
  ESCAPE    = 0x1B  # ESCAPE key
  SPACE     = 0x20  # SPACEBAR key
  PAGE_UP   = 0x21  # PAGE UP key
  PAGE_DOWN = 0x22  # PAGE DOWN key
  
  LEFT  = 0x25  # LEFT arrow
  UP    = 0x26  # UP arrow
  RIGHT = 0x27  # RIGHT arrow
  DOWN  = 0x28  # DOWN arrow
  
  SCREEN_SHOT = 0x2C  # SCREENSHOT key
  INSERT      = 0x2D  # INSERT key
  DELETE      = 0x2E  # DELETE key
  
  N_0		 = 0x30		# 0 key
  N_1		 = 0x31		# 1 key
  N_2		 = 0x32		# 2 key
  N_3		 = 0x33		# 3 key
  N_4		 = 0x34		# 4 key
  N_5		 = 0x35		# 5 key
  N_6		 = 0x36		# 6 key
  N_7		 = 0x37		# 7 key
  N_8		 = 0x38		# 8 key
  N_9		 = 0x39		# 9 key
  
  A		 = 0x41		# A key
  B		 = 0x42		# B key
  C		 = 0x43		# C key
  D		 = 0x44		# D key
  E		 = 0x45		# E key
  F		 = 0x46		# F key
  G		 = 0x47		# G key
  H		 = 0x48		# H key
  I		 = 0x49		# I key
  J		 = 0x4A		# J key
  K		 = 0x4B		# K key
  L		 = 0x4C		# L key
  M		 = 0x4D		# M key
  N		 = 0x4E		# N key
  O		 = 0x4F		# O key
  P		 = 0x50		# P key
  Q		 = 0x51		# Q key
  R		 = 0x52		# R key
  S		 = 0x53		# S key
  T		 = 0x54		# T key
  U		 = 0x55		# U key
  V		 = 0x56		# V key
  W		 = 0x57		# W key
  X		 = 0x58		# X key
  Y		 = 0x59		# Y key
  Z		 = 0x5A		# Z key
  
  LWIN	  = 0x5B		# Left Windows key (Microsoft Natural keyboard) 
  RWIN	  = 0x5C		# Right Windows key (Natural keyboard)
  APPS	  = 0x5D		# Applications key (Natural keyboard)
  
  NUM_0   = 0x60		# Numeric keypad 0 key
  NUM_1   = 0x61		# Numeric keypad 1 key
  NUM_2   = 0x62		# Numeric keypad 2 key
  NUM_3   = 0x63		# Numeric keypad 3 key
  NUM_4   = 0x64		# Numeric keypad 4 key
  NUM_5   = 0x65		# Numeric keypad 5 key
  NUM_6   = 0x66		# Numeric keypad 6 key
  NUM_7   = 0x67		# Numeric keypad 7 key
  NUM_8   = 0x68		# Numeric keypad 8 key
  NUM_9	  = 0x69		# Numeric keypad 9 key
  
  NUM_MULTIPLY  = 0x6A		# Multiply key (*)
  NUM_ADD	      = 0x6B		# Add key (+)
  NUM_SEPARATOR = 0x6C		# Separator key
  NUM_SUBTRACT  = 0x6D		# Subtract key (-)
  NUM_DECIMAL   = 0x6E		# Decimal key
  NUM_DIVIDE	  = 0x6F		# Divide key (/)
  
  CAPSLOCK  = 0x14		# CAPS LOCK key
  
  SEMI_COLON    = 0xBE		#Semi-colon Key (;)
  EQUAL         = 0xBB		#Equal Key (=)
  COMMA         = 0xBC		#Comma Key (,)
  DASH          = 0xBD		#Dash Key (-)
  PERIOD        = 0xBE		#Period Key (.)
  SLASH         = 0xBF		#Slash Key (/)
  ACCENT        = 0xC0		#Accent Key (`)
  OPEN_BRACKET  = 0xDB	  #Open Bracket ([)
  F_SLASH       = 0xDC		#Forward Slash (\)
  CLOSE_BRACKET = 0xDB	  #Close Bracket (])
  SQUARE        = 0xDE		#Square Key (²)
  EXCLAMATION   = 0xDF    #Exclamation key (!)
  DOLLAR        = 0xBA    #Dollar key ($)
  ASTERISK      = 0xDC    #Asterix key (*)
  CIRCUMFLEX    = 0xDD    #Circumflex key (^)
  U_GRAVE       = 0xC0    #U grave (ù)
  
  
  COMPARATOR = 0xE2    # Comparator key (<)
  
  F1		  = 0x70		# F1 key
  F2		  = 0x71		# F2 key
  F3		  = 0x72		# F3 key
  F4		  = 0x73		# F4 key
  F5		  = 0x74		# F5 key
  F6		  = 0x75		# F6 key
  F7		  = 0x76		# F7 key
  F8		  = 0x77		# F8 key
  F9		  = 0x78		# F9 key
  F10	    = 0x79		# F10 key
  F11	    = 0x7A		# F11 key
  F12	    = 0x7B		# F12 key
  
  NUMLOCK   = 0x90		# NUM LOCK key
  SCROLLOCK = 0x91		# SCROLL LOCK key
  
  L_SHIFT	    = 0xA0		# Left SHIFT key
  R_SHIFT	    = 0xA1		# Right SHIFT key
  L_CONTROL   = 0xA2		# Left CONTROL key
  R_CONTROL   = 0xA3		# Right CONTROL key
  L_ALT	      = 0xA4		# Left ALT key
  R_ALT	      = 0xA5		# Right ALT key
end

#==============================================================================
#
# Keyboard Script v3									  created by: cybersam
#
# its a small update...
# this have a script in it that allows you to insert a text with the keyboard
# inside the game... scroll down the script lit and you'll see it ^-^
# there is a new event on the map that shows you how it works...
# you can use the variables and command in the event in a script as well 
# since it works with "call script"
# now then... have fun with it ^-^
#
#==============================================================================
#
# hi guys.... it me again... ^-^
#
# now... this script is for more keys to press...
# anyone you like...
#
# mostly all keys are added...
#
# this version is now as module and easier to add to every script and 
# every event...
#
# here is nothing you need to change...
# only if you want to add more keys...
# add them in separate block below the last block 
# so you wont get confused... ^-^ 
# for the mouse is now only 5 buttons... 
# if you want more buttons couse your mouse have more...
# then you'll have to wait till microsoft update there stuff... ^-^
#
# i'll try to make the mouse-wheel work...
# i cant promess anything... ^-^
#
# till next update you cann add more stuff or just use it as it is atm...
#
# in the next release will be hopefully the mouse-wheel (not sure though)
# and the joy-stick/pad buttons... 
# but before that i'll have to reasearch a little about that... ^-^
#==============================================================================
module Keyboard
	
  FULL_USED_KEYS = [
    Keys::A,
    Keys::B,
    Keys::C,
    Keys::D,
    Keys::E,
    Keys::F,
    Keys::G,
    Keys::H,
    Keys::I,
    Keys::J,
    Keys::K,
    Keys::L,
    Keys::M,
    Keys::N,
    Keys::O,
    Keys::P,
    Keys::Q,
    Keys::R,
    Keys::S,
    Keys::T,
    Keys::U,
    Keys::V,
    Keys::W,
    Keys::X,
    Keys::Y,
    Keys::Z,
    Keys::SPACE,
    Keys::NUM_DIVIDE,
    Keys::SEMI_COLON,
    Keys::EQUAL,
    Keys::COMMA,
    Keys::DASH,
    Keys::SLASH,
    Keys::ACCENT,
    Keys::OPEN_BRACKET,
    Keys::F_SLASH,
    Keys::CLOSE_BRACKET,
    Keys::PERIOD,
    Keys::N_0,
    Keys::N_1,
    Keys::N_2,
    Keys::N_3,
    Keys::N_4,
    Keys::N_5,
    Keys::N_6,
    Keys::N_7,
    Keys::N_8,
    Keys::N_9,
    Keys::NUM_0,
    Keys::NUM_1,
    Keys::NUM_2,
    Keys::NUM_3,
    Keys::NUM_4,
    Keys::NUM_5,
    Keys::NUM_6,
    Keys::NUM_7,
    Keys::NUM_8,
    Keys::NUM_9,
    Keys::NUM_MULTIPLY,
    Keys::NUM_ADD,
    Keys::NUM_SEPARATOR,
    Keys::NUM_SUBTRACT,
    Keys::NUM_DECIMAL,
    Keys::NUM_DIVIDE,
    Keys::ENTER,
    Keys::ESCAPE,
    Keys::SQUARE,
    Keys::CTRL,
    Keys::R_ALT,
    Keys::UP,
    Keys::DOWN,
    Keys::LEFT,
    Keys::RIGHT,
    Keys::BACK,
    Keys::CAPS_LOCK,
    Keys::SHIFT,
    Keys::DELETE,
    Keys::INSERT,
    Keys::DOLLAR,
    Keys::CIRCUMFLEX,
    Keys::COMPARATOR,
    Keys::EXCLAMATION,
    Keys::U_GRAVE,
    Keys::TAB,
  ]

  PARTIAL_USED_KEYS = [
    Keys::A,
    Keys::C,
    Keys::D,
    Keys::S,
    Keys::Q,
    Keys::W,
    Keys::X,
    Keys::NUM_0,
    Keys::SPACE,
    Keys::ENTER,
    Keys::SHIFT,
    Keys::ESCAPE,
    Keys::SQUARE,
    Keys::CTRL,
    Keys::UP,
    Keys::DOWN,
    Keys::LEFT,
    Keys::RIGHT,
    Keys::BACK,
    Keys::F9,
  ]
  
# MINUSCULES
  CHAR_TABLE = Array.new(255, nil)
  CHAR_TABLE[Keys::SPACE] = ' '
  CHAR_TABLE[Keys::A] = 'a'
  CHAR_TABLE[Keys::B] = 'b'
  CHAR_TABLE[Keys::C] = 'c'
  CHAR_TABLE[Keys::D] = 'd'
  CHAR_TABLE[Keys::E] = 'e'
  CHAR_TABLE[Keys::F] = 'f'
  CHAR_TABLE[Keys::G] = 'g'
  CHAR_TABLE[Keys::H] = 'h'
  CHAR_TABLE[Keys::I] = 'i'
  CHAR_TABLE[Keys::J] = 'j'
  CHAR_TABLE[Keys::K] = 'k'
  CHAR_TABLE[Keys::L] = 'l'
  CHAR_TABLE[Keys::M] = 'm'
  CHAR_TABLE[Keys::N] = 'n'
  CHAR_TABLE[Keys::O] = 'o'
  CHAR_TABLE[Keys::P] = 'p'
  CHAR_TABLE[Keys::Q] = 'q'
  CHAR_TABLE[Keys::R] = 'r'
  CHAR_TABLE[Keys::S] = 's'
  CHAR_TABLE[Keys::T] = 't'
  CHAR_TABLE[Keys::U] = 'u'
  CHAR_TABLE[Keys::V] = 'v'
  CHAR_TABLE[Keys::W] = 'w'
  CHAR_TABLE[Keys::X] = 'x'
  CHAR_TABLE[Keys::Y] = 'y'
  CHAR_TABLE[Keys::Z] = 'z'
  CHAR_TABLE[Keys::NUM_0] = '0'
  CHAR_TABLE[Keys::NUM_1] = '1'
  CHAR_TABLE[Keys::NUM_2] = '2'
  CHAR_TABLE[Keys::NUM_3] = '3'
  CHAR_TABLE[Keys::NUM_4] = '4'
  CHAR_TABLE[Keys::NUM_5] = '5'
  CHAR_TABLE[Keys::NUM_6] = '6'
  CHAR_TABLE[Keys::NUM_7] = '7'
  CHAR_TABLE[Keys::NUM_8] = '8'
  CHAR_TABLE[Keys::NUM_9] = '9'
  CHAR_TABLE[Keys::N_0]    = '='
  CHAR_TABLE[Keys::N_1]    = '&'
  CHAR_TABLE[Keys::N_2]    = 'é'
  CHAR_TABLE[Keys::N_3]    = '"'
  CHAR_TABLE[Keys::N_4]    = '\''
  CHAR_TABLE[Keys::N_5]    = '('
  CHAR_TABLE[Keys::N_6]    = '-'
  CHAR_TABLE[Keys::N_7]    = 'è'
  CHAR_TABLE[Keys::N_8]    = '_'
  CHAR_TABLE[Keys::N_9]    = 'ç'
  CHAR_TABLE[Keys::SEMI_COLON]    = ';'
  CHAR_TABLE[Keys::EQUAL]         = '='
  CHAR_TABLE[Keys::COMMA]         = ','
  CHAR_TABLE[Keys::SLASH]         = ':'
  CHAR_TABLE[Keys::CLOSE_BRACKET] = ')'
  CHAR_TABLE[Keys::SQUARE]        = '²'
  CHAR_TABLE[Keys::EXCLAMATION]   = '!'
  CHAR_TABLE[Keys::COMPARATOR]    = '<'
  CHAR_TABLE[Keys::DOLLAR]        = '$'
  CHAR_TABLE[Keys::ASTERISK]      = '*'
  CHAR_TABLE[Keys::U_GRAVE]       = 'ù'
  CHAR_TABLE[Keys::NUM_MULTIPLY]  = '*'
  CHAR_TABLE[Keys::NUM_ADD]       = '+'
  CHAR_TABLE[Keys::NUM_SEPARATOR] = '.'
  CHAR_TABLE[Keys::NUM_SUBTRACT]  = '-'
  CHAR_TABLE[Keys::NUM_DECIMAL]   = '.'
  CHAR_TABLE[Keys::NUM_DIVIDE]    = '/'
  
# MAJUSCULES
  CHAR_TABLE_MAJ =  Array.new(255, nil)
  CHAR_TABLE_MAJ[Keys::A] = 'A'
  CHAR_TABLE_MAJ[Keys::B] = 'B'
  CHAR_TABLE_MAJ[Keys::C] = 'C'
  CHAR_TABLE_MAJ[Keys::D] = 'D'
  CHAR_TABLE_MAJ[Keys::E] = 'E'
  CHAR_TABLE_MAJ[Keys::F] = 'F'
  CHAR_TABLE_MAJ[Keys::G] = 'G'
  CHAR_TABLE_MAJ[Keys::H] = 'H'
  CHAR_TABLE_MAJ[Keys::I] = 'I'
  CHAR_TABLE_MAJ[Keys::J] = 'J'
  CHAR_TABLE_MAJ[Keys::K] = 'K'
  CHAR_TABLE_MAJ[Keys::L] = 'L'
  CHAR_TABLE_MAJ[Keys::M] = 'M'
  CHAR_TABLE_MAJ[Keys::N] = 'N'
  CHAR_TABLE_MAJ[Keys::O] = 'O'
  CHAR_TABLE_MAJ[Keys::P] = 'P'
  CHAR_TABLE_MAJ[Keys::Q] = 'Q'
  CHAR_TABLE_MAJ[Keys::R] = 'R'
  CHAR_TABLE_MAJ[Keys::S] = 'S'
  CHAR_TABLE_MAJ[Keys::T] = 'T'
  CHAR_TABLE_MAJ[Keys::U] = 'U'
  CHAR_TABLE_MAJ[Keys::V] = 'V'
  CHAR_TABLE_MAJ[Keys::W] = 'W'
  CHAR_TABLE_MAJ[Keys::X] = 'X'
  CHAR_TABLE_MAJ[Keys::Y] = 'Y'
  CHAR_TABLE_MAJ[Keys::Z] = 'Z'
  CHAR_TABLE_MAJ[Keys::N_0]    = '0'
  CHAR_TABLE_MAJ[Keys::N_1]    = '1'
  CHAR_TABLE_MAJ[Keys::N_2]    = '2'
  CHAR_TABLE_MAJ[Keys::N_3]    = '3'
  CHAR_TABLE_MAJ[Keys::N_4]    = '4'
  CHAR_TABLE_MAJ[Keys::N_5]    = '5'
  CHAR_TABLE_MAJ[Keys::N_6]    = '6'
  CHAR_TABLE_MAJ[Keys::N_7]    = '7'
  CHAR_TABLE_MAJ[Keys::N_8]    = '8'
  CHAR_TABLE_MAJ[Keys::N_9]    = '9'
  CHAR_TABLE_MAJ[Keys::SEMI_COLON]    = '.'
  CHAR_TABLE_MAJ[Keys::EQUAL]         = '+'
  CHAR_TABLE_MAJ[Keys::COMMA]         = '?'
  CHAR_TABLE_MAJ[Keys::SLASH]         = '/'
  CHAR_TABLE_MAJ[Keys::CLOSE_BRACKET] = '°'
  CHAR_TABLE_MAJ[Keys::EXCLAMATION]   = '§'
  CHAR_TABLE_MAJ[Keys::COMPARATOR]    = '>'
  CHAR_TABLE_MAJ[Keys::DOLLAR]        = '£'
  CHAR_TABLE_MAJ[Keys::ASTERISK]      = 'µ'
  CHAR_TABLE_MAJ[Keys::U_GRAVE]       = '%'
  
#Alt Gr
  CHAR_TABLE_ALT_GR = Array.new(255, nil)
  CHAR_TABLE_ALT_GR[Keys::N_0]    = '@'
  CHAR_TABLE_ALT_GR[Keys::N_3]    = '#'
  CHAR_TABLE_ALT_GR[Keys::N_4]    = '{'
  CHAR_TABLE_ALT_GR[Keys::N_5]    = '['
  CHAR_TABLE_ALT_GR[Keys::N_6]    = '|'
  CHAR_TABLE_ALT_GR[Keys::N_8]    = '\\'
  CHAR_TABLE_ALT_GR[Keys::N_9]    = '^'
  CHAR_TABLE_ALT_GR[Keys::EQUAL]         = '}'
  CHAR_TABLE_ALT_GR[Keys::CLOSE_BRACKET] = ']'
  CHAR_TABLE_ALT_GR[Keys::DOLLAR]        = '¤'
  
# - Cironflex
  CHAR_TABLE_CIRCUMFLEX = Array.new(255,nil)
  CHAR_TABLE_CIRCUMFLEX[Keys::A] = ['â', 'Â']
  CHAR_TABLE_CIRCUMFLEX[Keys::E] = ['ê', 'Ê']
  CHAR_TABLE_CIRCUMFLEX[Keys::I] = ['î', 'Î']
  CHAR_TABLE_CIRCUMFLEX[Keys::O] = ['ô', 'Ô']
  CHAR_TABLE_CIRCUMFLEX[Keys::U] = ['û', 'Û']
  
# - Trema
# Minuscules
  CHAR_TABLE_TREMA = Array.new(255, nil)
  CHAR_TABLE_TREMA[Keys::A] = ['ä', 'Ä']
  CHAR_TABLE_TREMA[Keys::E] = ['ë', 'Ë']
  CHAR_TABLE_TREMA[Keys::I] = ['ï', 'Ï']
  CHAR_TABLE_TREMA[Keys::O] = ['ö','Ö']
  CHAR_TABLE_TREMA[Keys::U] = ['ü','Ü']
  
# - Tild
#Minuscules
  CHAR_TABLE_TILD = Array.new(255, nil)
  CHAR_TABLE_TILD[Keys::A] = ['ã', 'Ã']
  CHAR_TABLE_TILD[Keys::O] = ['õ', 'Õ']
  CHAR_TABLE_TILD[Keys::N] = ['ñ', 'Ñ']
  
#Accent
  CHAR_TABLE_ACCENT = Array.new(255, nil)
  CHAR_TABLE_ACCENT[Keys::A] = ['à', 'À']
  CHAR_TABLE_ACCENT[Keys::E] = ['è', 'È']
  CHAR_TABLE_ACCENT[Keys::I] = ['ì', 'Ì']
  CHAR_TABLE_ACCENT[Keys::O] = ['ò', 'Ò']
  CHAR_TABLE_ACCENT[Keys::U] = ['ù', 'Ù']
  
  module_function
  
  def check(key)
    Win32API.new("user32","GetAsyncKeyState",['i'],'i').call(key) & 0x01 == 1  # key 0
  end
end


module Input_Scene  
  A = Keys::SHIFT
  B = [Keys::X, Keys::ESCAPE, Keys::NUM_0]
  C = [Keys::SPACE, Keys::ENTER, Keys::C]
  X = Keys::A
  Y = Keys::S
  Z = Keys::D
  L = Keys::Q
  R = Keys::W
  F9 = Keys::F9
  
  DOWN  = Keys::DOWN
  LEFT  = Keys::LEFT
  RIGHT = Keys::RIGHT
  UP    = Keys::UP
  
  CTRL  = Keys::CTRL
  ALT   = Keys::ALT
  
  
  @used_keysset =  Keyboard::PARTIAL_USED_KEYS
  
  @count        = Hash.new(-1)
  @used_i       = []
  @repeat_rate  = Graphics.frame_rate
  
  @caps_locked  = false
  @maj          = false
  @special_char = ''   # caractére spécial : ^ ¨ ~
  
  module_function  
  
  def update
    @used_i = []
    for k in @used_keysset
      if press?(k)
        @count[k] = (@count[k]+1)%@repeat_rate
      end
      if Keyboard.check(k)
        @used_i.push k
        @count[k] = 0
      end
    end
    
    @caps_locked = !@caps_locked if trigger?(Keys::CAPS_LOCK)
    @maj    = press?(Keys::SHIFT)
    @alt_gr = press?(Keys::R_ALT)
    @special_char = get_special_char
  end
  
  def press?(key)
    if key.type == Array
      for k in key
        return true if press?(k)
      end
      return false
    end
    return true unless Win32API.new("user32","GetKeyState",['i'],'i').call(key).between?(0, 1)
    return false
  end
  
  def trigger?(key)
    if key.type == Array
      for k in key
        return true if trigger?(k)
      end
      return false
    end
    return @used_i.include?(key)
  end
  
  def repeat?(key)
    if key.type == Array
      for k in key
        return true if repeat?(k)
      end
      return false
    end
    
    if trigger?(key)
      return true
    end
    
    if press?(key)
      return @count[key] == 0
    end
    
    return false
  end
  
  def key_triggered?
    return !@used_i.empty?
  end
  
  def dir4
    return 2 if press? Keys::DOWN
    return 4 if press? Keys::LEFT
    return 6 if press? Keys::RIGHT
    return 8 if press? Keys::UP
    
    return 0
  end
   
  def dir8
    return 1 if press? Keys::DOWN and press? Keys::LEFT
    return 3 if press? Keys::DOWN and press? Keys::RIGHT
    return 7 if press? Keys::UP and press? Keys::RIGHT
    return 9 if press? Keys::UP and press? Keys::LEFT
    return dir4
  end
  
  def get_char
    if !@used_i.empty?
      key = @used_i.first
      if maj?
        c = Keyboard::CHAR_TABLE_MAJ[key]
      elsif @alt_gr
        c = Keyboard::CHAR_TABLE_ALT_GR[key]
      else
        c = Keyboard::CHAR_TABLE[key]
      end
      c = '' if c == nil
      return compose_char(key, c)
    end
    return ['', 0]
  end
  
  def maj?
    return ((@caps_locked and !@maj) or (!@caps_locked and @maj))
  end
  
  def get_special_char
    return '^'  if trigger?(Keys::CIRCUMFLEX) and !@maj
    return '¨'  if trigger?(Keys::CIRCUMFLEX) and @maj
    return '~'  if trigger?(Keys::N_2)        and @alt_gr
    return '`'  if trigger?(Keys::N_7)        and @alt_gr
    return @special_char #Aucun d'eux, le special char est conservé.
  end
  
  def compose_char(key, char)
    size = 0
    if @special_char != '' and char != ''
      case @special_char
      when '^'
        s_char  = Keyboard::CHAR_TABLE_CIRCUMFLEX[key]
      when '¨'
        s_char  = Keyboard::CHAR_TABLE_TREMA[key]
      when '~'
        s_char  = Keyboard::CHAR_TABLE_TILD[key]
      when '`'
        s_char  = Keyboard::CHAR_TABLE_ACCENT[key]
      end
      if s_char != nil
        size = maj? ? 0 : 1
        s_char = s_char[(maj? ? 1 : 0)] 
      end
      char    = (s_char == nil ? @special_char + char : s_char) 
      @special_char = ''
      
    end
    return [char, char.size - size] 
  end
  
  def set_keysset(name)
    case name
    when :full
      @used_keysset = Keyboard::FULL_USED_KEYS
    when :partial
      @used_keysset = Keyboard::PARTIAL_USED_KEYS
    end
  end
end