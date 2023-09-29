#-------------------------------------------------------------------------------
# Ajouts de méthodes pour Ruby
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#                              Les listes
#-------------------------------------------------------------------------------
class Array
  
  #--------------------------------------------------
  # Mélanger
  #--------------------------------------------------
  def shuffle
    sort_by { rand }
  end

  def shuffle!
    self.replace shuffle
  end
  
  def switch( liste )
    tab = self.clone
    liste.each {|key, value|
      self[value] = tab[key]
    }
  end
  
  #--------------------------------------------------
  # Tri par insertion
  #--------------------------------------------------
  #----- Version utilisable dans les scripts
  def insertionSort(arr = self, left = 0, right = self.length-1)
    #Tri classique
    if !block_given?
      (left+1).upto(right) do |i| 
        temp = arr[i]
        j = i
        while arr[j-1] > temp and j > left
          arr[j] = arr[j-1]
          j -= 1
        end
        arr[j] = temp
      end
    #Si un critère de comparaison est donné
    else
      (left+1).upto(right) do |i|
        temp = arr[i]
        j = i
        while yield(temp, arr[j-1]) == -1 and j > left
          arr[j] = arr[j-1]
          j -= 1
        end
        arr[j] = temp
      end
    end
    self.replace arr
  end
  
  #------ Tri par insertion sans possibilité de block de critère de comparaison
  #------ !!!! Pour une Utilisations interne !!!!  
  def insertionSort_noblock(arr = self, left = 0, right = self.length-1)
    (left+1).upto(right) do |i|
      temp = arr[i]
      j = i
      while arr[j-1] > temp and j > left
        arr[j] = arr[j-1]
        j -= 1
      end
      arr[j] = temp
    end
    self.replace arr
  end
  
  #------ Tri par insetion avec obligatoirement un block de critère de comparaison
  #------ !!!! Pour une Utilisations interne !!!!
  def insertionSort_withblock(arr = self, left = 0, right = self.length-1)
    (left+1).upto(right) do |i|
      temp = arr[i]
      j = i
      while yield(temp, arr[j-1]) == -1 and j > left
        arr[j] = arr[j-1]
        j -= 1
      end
      arr[j] = temp
    end
    self.replace arr
  end
  
  #--------------------------------------------------
  # Tri fusion amélioré
  #--------------------------------------------------
  
  #----------------------------
  #fusionner deux listes triées
  #----------------------------
  #------ Version utilisable dans les scripts
  def merge(arr1, arr2)
    arr = []
    if !block_given?
      while !arr1.empty? and !arr2.empty?
        if arr1[0] <= arr2[0]
          arr.push(arr1.shift)
        else
          arr.push(arr2.shift)
        end
      end
      arr.concat(arr1).concat(arr2)
    else
      while !arr1.empty? and !arr2.empty?
        if yield(arr1[0], arr2[0]) <= 0
          arr.push(arr1.shift)
        else
          arr.push(arr2.shift)
        end
      end
      arr.concat(arr1).concat(arr2)
    end
  end
  
  #------ Fusion sans block de comparaison possible
  #------ !!!! Pour une utilisation interne !!!!
  def merge_noblock(arr1, arr2)
    arr = []
    while !arr1.empty? and !arr2.empty?
      if arr1[0] <= arr2[0]
        arr.push(arr1.shift)
      else
        arr.push(arr2.shift)
      end
    end
    arr.concat(arr1).concat(arr2)
  end
  
  #------ Fusion avec block de comparaison obligatoire
  #------ !!!! Pour une utilisation interne !!!!
  def merge_withblock(arr1, arr2)
    arr = []
    while !arr1.empty? and !arr2.empty?
      if yield(arr1[0], arr2[0]) <= 0
        arr.push(arr1.shift)
      else
        arr.push(arr2.shift)
      end
    end
    arr.concat(arr1).concat(arr2)
  end
  
  #----------------------------
  # Tri fusion
  #----------------------------
  
  #------ Tri fusion : renvoie une nouvelle liste et ne change par la liste d'origine
  #------ Version utilisable dans les scripts
  def mergeSort(arr = self, &block) 
    len = arr.length
    if !block_given?
      if len <=32
        arr.insertionSort
        return arr
      else
        m = len/2
        left = mergeSort_noblock(arr[0...m])
        right = mergeSort_noblock(arr[m...len])
        merge_noblock(left, right)
      end
    else
      if len <=32
        arr.insertionSort &block
        return arr
      else
        m = len/2
        left = mergeSort_withblock(arr[0...m], &block)
        right = mergeSort_withblock(arr[m...len], &block)
        merge_withblock(left, right, &block)
      end
    end
  end
  
  #------ Tri fusion sans block de comparaison possible
  #------ !!!! Pour une utilisation interne !!!!
  def mergeSort_noblock(arr = self) 
    len = arr.length
    if len <=32
      arr.insertionSort_noblock
      return arr
    else
      m = len/2
      left = mergeSort_noblock(arr[0...m])
      right = mergeSort_noblock(arr[m...len])
      merge(left, right)
    end
  end
  
  #------ Tri fusion avec block de comparaison obligatoire
  #------ !!!! Pour une utilisation interne !!!!
  def mergeSort_withblock(arr = self, &block) 
    len = arr.length
    if len <=32
      arr.insertionSort_withblock &block
      return arr
    else
      m = len/2
      left = mergeSort_withblock(arr[0...m], &block)
      right = mergeSort_withblock(arr[m...len], &block)
      merge_withblock(left, right, &block)
    end
  end
  
  #------ Tri fusion : la liste d'origine sera triée
  def mergeSort! &block
    self.replace mergeSort(self, &block)
  end
  
end

class Integer
  
  def between(nb1, nb2 = nb1)
    if nb2 > nb1
      return (self >= nb1 and self <= nb2)
    else
      return (self <= nb1 and self >= nb2)
    end
    return false
  end
  
  def nb_chiffres
    t = self
    c = 1
    while(t > 10)
      c += 1
      t /= 10
    end
    return c
  end
  
  def sgn
    if self >= 0
      return 1
    else
      return -1
    end
  end
  
  def even?
     return self % 2 == 0
   end
   
  def odd?
    return self % 2 == 1
  end

end

#-------------------------------------------------------------------------------
# Les chaînes de caractères
#-------------------------------------------------------------------------------
# Ajouts de méthode(s) dans la classe String
class String
  # Les correspondant entre les carractères accentués et ceux non accentués
  # Hash Tableau de "charactère(s) avec accent" => "charactère sans accent"
  HASH_ACCENTS = {
    ['á','à','â','ä','ã'] => 'a',
    ['é','è','ê','ë'] => 'e',
    ['í','ì','î','ï'] => 'i',
    ['ó','ò','ô','ö','õ'] => 'o',
    ['ú','ù','û','ü'] => 'u',
    ['ç'] => 'c',
    ['ñ'] => 'n'
  }
  
  HASH_SPECIAL_CHARS = ['?', '@', ',', '^', ';', ':', '#', '[', ']', '{', '}', '$', '%', '&', '\'', '(', ')', '*', '+', '-', '.', '/', '\\', '<', '>', '=', '?', '!', '`', '~', '_', '"', "|"] 

  #----------------------------
  # Vérifier si la chaîne finit pas une chaîne de caractère particulière
  #----------------------------
  def end_with?(str)
    size = str.size
    return self.slice(-size, size) == str
  end

  # Met un texte en taille minuscule (downcase) et supprime les accents
  # Retourne la chaîne de caractère au bon format
  def downcase_remove_accents
    str = self.downcase
    HASH_ACCENTS.each do |accents, char_no_accent|
      accents.each do |char_with_accent|
        str = str.gsub(char_with_accent, char_no_accent)
      end
    end
    return str
  end
  
  # Met un texte en taille majuscule (upcase) et supprime les accents
  # Retourne la chaîne de caractère au bon format
  def upcase_remove_accents
    str = self.downcase_remove_accents
    str = self.upcase
    return str
  end
  
  # Met un texte en taille minuscule (downcase) et supprime les accents et caractères spéciaux
  # Retourne la chaîne de caractère au bon format
  def downcase_remove_accents_special_chars
    str = self.downcase_remove_accents
    HASH_SPECIAL_CHARS.each do |special_char|
      str = str.gsub(special_char, '')
    end
    return str
  end
end



def explore(path)
  if not(FileTest.exist?(path))
    return ["Aucun"]
  end
  command = []
  dir = []
  d = Dir.open(path)
  d = d.sort - [".", ".."]
  d.each {|file|
    case File.ftype(path+"/"+file)
    when "directory"
      command.push(file)
      dir.push(true)
    when "file"
      command.push(file)
      dir.push(false)
    end
  }
  
  temp = []
  
  for i in 0..command.length-1
    if dir[i]
      command[i] += "/"
      temp.push(command[i])
    end
  end
  
  dir.delete(true)
  for element in temp
    command.delete(element)
  end
  
  temp.reverse!
  
  for element in temp
    dir.unshift(true)
    command.unshift(element)
  end
  
  return [command, dir]
end

#miniumun entre deux valeurs
def min(a,b)
  if a < b then a else b end
end

#maximum entre deux valeur
def max(a,b)
  if a > b then a else b end
end
