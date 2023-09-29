#===
#Yuki::Casino
#  Script simulant les machines à sou du casino
#---
#© Nuri Yuri - Tous droits réservés (interdiction d'utilisation inclu en cas de conflit)
#===
module Yuki
  class Casino
    @@Cache=[]
    S_Dir="Graphics/Casino/"
    Z=4000
    BA1_X=74   #Position x de la première bande
    BA2_X=194
    BA3_X=314
    BA_Y=129
    CRE_X=446  #Positions du crédit
    CRE_Y=210
    PAY_X=542
    PAY_Y=210
    BAND=Array.new(5)
    BAND[0]=[1,2,3 ,4,5,6,4, 1,2,3]
    BAND[1]=[5,4,6 ,1,2,1,3, 5,4,6]
    BAND[2]=[2,5,4 ,1,6,5,3, 2,5,4]
    BAND[3]=[3,6,1 ,5,4,2,5, 3,6,1]
    BAND[4]=[4,2,5 ,6,3,1,2, 4,2,5]
    RECT=Rect.new(0,0,84,66)
    RECTN=Rect.new(0,0,18,30)
    Values=[0,0,10,300,20,50,5] #valeurs des images vX
    #===
    #>Initialisation
    #===
    def initialize()
      Graphics.freeze
      #>Chargement du cache
      load_cache() if @@Cache.length == 0
      #>Création des sprites
      @sp_fnt=Sprite.new
      @sp_fnt.z=Z
      @sp_fnt.bitmap=@@Cache[0]
      @sp_ba1=Sprite.new
      @sp_ba1.z=Z+1
      @sp_ba1.x=BA1_X
      @sp_ba1.y=BA_Y
      @sp_ba1.bitmap=Bitmap.new(84,660)
      @sp_ba1.src_rect.height=198
      @sp_ba2=Sprite.new
      @sp_ba2.z=Z+1
      @sp_ba2.x=BA2_X
      @sp_ba2.y=BA_Y
      @sp_ba2.bitmap=Bitmap.new(84,660)
      @sp_ba2.src_rect.height=198
      @sp_ba3=Sprite.new
      @sp_ba3.z=Z+1
      @sp_ba3.x=BA3_X
      @sp_ba3.y=BA_Y
      @sp_ba3.bitmap=Bitmap.new(84,660)
      @sp_ba3.src_rect.height=198
      @sp_cre=Sprite.new
      @sp_cre.z=Z+1
      @sp_cre.x=CRE_X
      @sp_cre.y=CRE_Y
      @sp_cre.bitmap=Bitmap.new(84,30)
      @sp_pay=Sprite.new
      @sp_pay.z=Z+1
      @sp_pay.x=PAY_X
      @sp_pay.y=PAY_Y
      @sp_pay.bitmap=Bitmap.new(84,30)
      #>Génération des bandes.
      gen_band()
      #>Génération des autres variabless
      @pay=0
      @cre=$game_variables[VAR_J]
      @wait=[0,0,0]
      #>Affichage des compteurs.
      gen_cnt(@cre,@sp_cre.bitmap)
      gen_cnt(0,@sp_pay.bitmap)
      Graphics.transition(20)
    end
    
    #===
    #>Lancement
    #===
    def run
      loop do
        Graphics.update
        Input.update
        #>Modification du crédit
        if Input.trigger?(Input::UP) and @cre>0 and @pay<3
          @pay+=1
          @cre-=1
          gen_cnt(@cre,@sp_cre.bitmap)
          gen_cnt(@pay,@sp_pay.bitmap)
        elsif Input.trigger?(Input::DOWN) and @pay>0
          @pay-=1
          @cre+=1
          gen_cnt(@cre,@sp_cre.bitmap)
          gen_cnt(@pay,@sp_pay.bitmap)
        end
        #>Jouer
        if Input.trigger?(Input::C) and @pay>0
          @wait[1]=4
          @wait[2]=8
          play()
        end
        
        #>Quitter
        if Input.trigger?(Input::B)
          break
        end
          
      end
      Graphics.freeze
      dispose()
      Graphics.transition(20)
    end
    
    #===
    #>Jouer :b
    #===
    def play()
      spd=$game_variables[VAR_SPD]*6
      spd=6 if spd<=0
      p1=p2=p3=false
      w=10
      loop do
        Graphics.update
        Input.update
        #>Mise à jour de la bande 1
        if w<1 and Input.trigger?(Input::LEFT) and !p1
          p1=true
        elsif !p1 or @sp_ba1.src_rect.y%66 > 3
          @sp_ba1.src_rect.y+=spd
          @sp_ba1.src_rect.y-=462 if @sp_ba1.src_rect.y >= 462
        end
        #>Mise à jour de la bande 2
        if @wait[1]>0
          @wait[1]-=1
        elsif w<1 and Input.trigger?(Input::UP) and !p2
          p2=true
        elsif !p2 or @sp_ba2.src_rect.y%66 > 3
          @sp_ba2.src_rect.y+=spd
          @sp_ba2.src_rect.y-=462 if @sp_ba2.src_rect.y >= 462
        end
        #Mise à jour de la bande 3
        if @wait[2]>0
          @wait[2]-=1
        elsif w<1 and Input.trigger?(Input::RIGHT) and !p3
          p3=true
        elsif !p3 or @sp_ba3.src_rect.y%66 > 3
          @sp_ba3.src_rect.y+=spd
          @sp_ba3.src_rect.y-=462 if @sp_ba3.src_rect.y >= 462
        end
        #Décrementation du wait qui empêche l'appuis direct (au lancement)
        w-=1 if w>0
        #Vérification de l'arrêt de toute les bandes.
        if p1 and p2 and p3
          a=@sp_ba1.src_rect.y%66
          b=@sp_ba2.src_rect.y%66
          c=@sp_ba3.src_rect.y%66
          if a<=3 and b<=3 and c<=3
            if verif()
              break
            else
              w=10
              p1=p2=p3=false
            end
          end
        end
      end
    end
    
    #===
    #>Vérification des gains et autres
    #===
    def verif()
      o1=@band1[@sp_ba1.src_rect.y/66+1]
      o2=@band2[@sp_ba2.src_rect.y/66+1]
      o3=@band3[@sp_ba3.src_rect.y/66+1]
      c=0
      c+=1 if o1==1
      c+=1 if o2==1
      c+=1 if o3==1
      if o1==o2 and o2==o3 and c<2
        @pay=Values[o1]*@pay
        t=@pay+@cre
        if t>9999
          @pay-=(t-9999)
        end
        gen_cnt(@pay,@sp_pay.bitmap)
        20.times do Graphics.update end
        @pay.times do
          @pay-=1
          @cre+=1
          gen_cnt(@cre,@sp_cre.bitmap)
          gen_cnt(@pay,@sp_pay.bitmap)
          Graphics.update
        end
      end
      $game_variables[VAR_J]=@cre
      if c>1
        return false
      else
        if @pay>0
          @pay.times do |i|
            @pay-=1
            gen_cnt(@pay,@sp_pay.bitmap)
          end
        end
        gen_cnt(@pay,@sp_pay.bitmap)
        return true
      end
    end
    
    #===
    #>Génération des compteur de jeton
    #===
    def gen_cnt(var,bmp)
      bmp.clear
      4.times do |i|
        v=var%10
        bmp.blt(66-i*22,0,@@Cache[1+v],RECTN)
        var/=10
      end
    end
    
    #===
    #>Chargement du cache
    #===
    def load_cache()
      @@Cache[0]=Bitmap.new(S_Dir+"base.png")
      10.times do |i|
        @@Cache[1+i]=Bitmap.new(S_Dir+"n#{i}.png")
      end
      1.step(6) do |i|
        @@Cache[10+i]=Bitmap.new(S_Dir+"v#{i}.png")
      end
    end
    
    #===
    #>Génération des bandes
    #===
    def gen_band()
      @band1=BAND[rand(5)]
      @band2=BAND[rand(5)]
      @band3=BAND[rand(5)]
      ba1=@sp_ba1.bitmap
      ba2=@sp_ba2.bitmap
      ba3=@sp_ba3.bitmap
      10.times do |i|
        ba1.blt(0,i*66,@@Cache[@band1[i]+10],RECT)
        ba2.blt(0,i*66,@@Cache[@band2[i]+10],RECT)
        ba3.blt(0,i*66,@@Cache[@band3[i]+10],RECT)
      end
    end
    
    #===
    #>Dispose
    #===
    def dispose()
      @sp_fnt.dispose
      @sp_ba1.bitmap.dispose
      @sp_ba1.dispose
      @sp_ba2.bitmap.dispose
      @sp_ba2.dispose
      @sp_ba3.bitmap.dispose
      @sp_ba3.dispose
      @sp_cre.bitmap.dispose
      @sp_cre.dispose
      @sp_pay.bitmap.dispose
      @sp_pay.dispose
    end
  end
end
#===
#>Ajout à Interpreter : Méthode d'appel de la machine à sou.
#===
class Interpreter
  def casino
    v=Yuki::Casino.new
    v.run
  end
end