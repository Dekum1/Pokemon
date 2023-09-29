#==============================================================================
# ■ Main
#------------------------------------------------------------------------------
# 　各クラスの定義が終わった後、ここから実際の処理が始まります。
#==============================================================================
begin
  # Version actuelle de PSP
  VERSION = "0.10"
  # Ecritures d'informations utiles pour faciliter le développement
  # Décommenter lorsque vous en avez besoin et n'oubliez pas de recommenter
  # ensuite !
  #file = File.open("data.txt", "w")
  # 1.upto(493) do |i|
    # file.write("$data_pokemon[#{i}] = #{$data_pokemon[i].inspect}\n")
  #end
  #file.close

  # Change the $fontface variable to change the font style
  $fontfacebis = ["Pokemon RS", "Pokemon DP"]
  $fontsizebis = 28
  # Change the $fontsize variable to change the font size
  $fontsmall = ["Pokemon Emerald Small", "Pokemon DP", "Trebuchet MS"]
  # Pokemon Emerald Small 2px: 25 , 3px: 37
  $fontsmallsize = 37
  $fs = 34
  
  $fontnarrow = ["Pokemon Emerald Narrow", "Pokemon DP", "Trebuchet MS"]
  # Pokemon Emerald Narrow 3px: 47
  $fontnarrowsize = 47
  $fn = 42

  POKEMON_S::Load_Data.load_in_thread
  Graphics.update
  $thread_data = Thread.new { POKEMON_S::Load_Data.load_component_with_dependencies_data}
  # シーンオブジェクト (タイトル画面) を作成
  $scene = Scene_Title.new
  # $scene が有効な限り main メソッドを呼び出す
  while $scene != nil
    $scene.main
  end
  # フェードアウト
  Graphics.transition(20)
rescue Exception => exception
  EXC::error_handler(exception)
rescue Errno::ENOENT
  # 例外 Errno::ENOENT を補足
  # ファイルがオープンできなかった場合、メッセージを表示して終了する
  filename = $!.message.sub("Ne trouve pas le fichier ou le répertoire - ", "")
  print("Le ficher #{filename} n'a pas été trouvé.")
end
