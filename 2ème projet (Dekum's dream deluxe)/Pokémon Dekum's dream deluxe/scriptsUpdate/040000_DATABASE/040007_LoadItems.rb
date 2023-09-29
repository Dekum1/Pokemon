#==============================================================================
# ■ Item
# Pokemon Script Project - Krosk 
# 25/08/07
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Données du Sac
#-----------------------------------------------------------------------------
# Load_Items - Damien Linux
# 14/11/2020
#-----------------------------------------------------------------------------
module POKEMON_S  
  class Load_Data
    class Load_Items
      class << self
        def load
          #-------------------------------------------------------------
          # $data_item
          #   [Nom, Icone, Type, Description, Prix, Profil, Texte à l'utilisation, data, log_data_A, log_data_B, log_data_C]
          #   Type: "ITEM"
          #         "BALL"
          #         "TECH"
          #         "BERRY"
          #         "KEY"
          #
          #   [ tenable/jetable, usage limité, usage en map, usage en combat, usage sur pokémon, apte/non apte]
          #
          #   data paramètre général: common_event_id, effect
          #
          #   log_data_A paramètre de soin: [recover_hp_rate, recover_hp, recover_pp_rate, recover_pp]
          #   log_data_B paramètre de statut: [minus_state]
          #-------------------------------------------------------------
          #-----------------------------------------------------------------------------
          # 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé, 8: Toxic
          # @confuse (6), @flinch (7)
          #-----------------------------------------------------------------------------
          
          $data_item = []
          $data_item[ 0 ]=["erreur","return.png","ITEM","erreur", 0 ,"" ,"" , {} ]
          if FileTest.exist?("Data/data_item.txt")
            begin
              file = File.open("Data/data_item.txt", "rb")
              file.readchar
              file.readchar
              file.readchar
              
              file.each {|line| eval(line) }
              file.close
            rescue Exception => exception
              EXC::error_handler(exception, file)
            end
          end
          
          if FileTest.exist?("Data/data_item.txt")
            $data_items       = load_data("Data/Items.rxdata")
            1.upto($data_items.length - 1) do |i|
              item = $data_items[i]
              
              if $data_item[i] == nil
                $data_item[i] = []
              end
              
              string = item.description.split('//')
              
              # Description après usage
              if string[1] != nil
                $data_item[i].unshift(string[1])
              else
                $data_item[i].unshift("")
              end
              
              # Profil perso          
              custom_list = [false, false, false, false, false, false]
              item.element_set.each do |element|
                case element
                when 34
                  custom_list[0] = true
                when 35
                  custom_list[1] = true
                when 36
                  custom_list[2] = true
                when 37
                  custom_list[3] = true
                when 38
                  custom_list[4] = true
                when 39
                  custom_list[5] = true
                end
              end
              $data_item[i].unshift(custom_list)
                
              # Prix
              $data_item[i].unshift(item.price)
                
              # Description
              if string[0] != nil
                $data_item[i].unshift(string[0])
              else
                $data_item[i].unshift("")
              end
              
              # Poche
              case item.element_set[0]
              when 28
                $data_item[i].unshift("ITEM")
              when 29
                $data_item[i].unshift("BALL")
              when 30
                $data_item[i].unshift("TECH")
              when 31
                $data_item[i].unshift("BERRY")
              when 32
                $data_item[i].unshift("KEY")
              else
                $data_item[i].unshift("ITEM")
              end
              
              $data_item[i].unshift(item.icon_name)
              
              $data_item[i].unshift(item.name)
              
              $data_item[i][8] = [item.recover_hp_rate, item.recover_hp, item.recover_sp_rate, item.recover_sp]
              $data_item[i][9] = item.minus_state_set
                
              if $data_item[i][7] == nil
                $data_item[i][7] = {}
              end
              
              $data_item[i][7]["recover_hp_rate"] = item.recover_hp_rate
              $data_item[i][7]["recover_hp"] = item.recover_hp
              $data_item[i][7]["recover_pp_all"] = item.recover_sp_rate
              $data_item[i][7]["recover_pp"] = item.recover_sp
              $data_item[i][7]["recover_state"] = item.minus_state_set
              
              if item.common_event_id != 0
                $data_item[i][7]["event"] = item.common_event_id
              end
              
            end
          else
            $data_item = load_data("Data/data_item.rxdata")
          end
        end
      end
    end
  end
end