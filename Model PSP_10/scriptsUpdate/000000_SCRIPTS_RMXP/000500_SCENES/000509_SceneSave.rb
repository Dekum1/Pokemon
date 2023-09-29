#==============================================================================
# ■ Scene_Save
#------------------------------------------------------------------------------
# 　セーブ画面の処理を行うクラスです。
#==============================================================================

class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super("Voulez vous sauvegarder la partie ?")
  end
  #--------------------------------------------------------------------------
  # ● 決定時の処理
  #--------------------------------------------------------------------------
  def on_decision(filename)
    # セーブ SE を演奏
    $game_system.se_play($data_system.save_se)
    # セーブデータの書き込み
    file = File.open(filename, "wb")
    write_save_data(file)
    file.close
    # イベントから呼び出されている場合
    if $game_temp.save_calling
      # セーブ呼び出しフラグをクリア
      $game_temp.save_calling = false
      # マップ画面に切り替え
      $scene = Scene_Map.new
      return
    end
    # メニュー画面に切り替え
    $scene = Scene_Menu.new(4)
  end
  #--------------------------------------------------------------------------
  # ● キャンセル時の処理
  #--------------------------------------------------------------------------
  def on_cancel
    # キャンセル SE を演奏
    $game_system.se_play($data_system.cancel_se)
    # イベントから呼び出されている場合
    if $game_temp.save_calling
      # セーブ呼び出しフラグをクリア
      $game_temp.save_calling = false
      # マップ画面に切り替え
      $scene = Scene_Map.new
      return
    end
    # メニュー画面に切り替え
    $scene = Scene_Menu.new(4)
  end
end
