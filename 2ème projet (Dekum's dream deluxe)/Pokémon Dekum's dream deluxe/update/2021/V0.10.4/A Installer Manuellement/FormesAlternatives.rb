Dans FormesAlola :
l.41 :
Remplacez :
def alt_movepool(erase = false)
       
      list = alt_movepool_list
      reprod = []
      skills = []
      ct = []
      if list != []
        for i in list
          if (i[0] == @id or i[0] == @name) and i[1] == @form
            for skill in i[2]
              if skill[0].type == Fixnum
                skills.push(skill)
              else
                skills.push([Skill_Info.id(skill[0]), skill[1]])
              end
            end
            for skill in i[3]
              ct.push(skill)
            end
            for skill in i[4]
              if skill.type == Fixnum
                reprod.push(skill)
              else
                reprod.push(Skill_Info.id(skill))
              end
            end
          end
        end
      end
       
      if ct != [nil]
        @skills_allow = ct
      end
 
      if skills != [nil] and skills != []
        @skills_table = skills
        return if erase == false
        @skills_set = []
        initialize_skill
      end
    end
Par :
def alt_movepool(erase = false)
       
      list = alt_movepool_list
      reprod = []
      skills = []
      ct = []
      if list != []
        list.each do |i|
          if (i[0] == @id or i[0] == @name) and i[1] == @form
            next if i[2] == nil
            i[2].each do |skill|
              next if skill == nil
              if skill[0].type == Fixnum
                skills.push(skill)
              else
                skills.push([Skill_Info.id(skill[0]), skill[1]])
              end
            end
            next if i[3] == nil
            i[3].each do |skill|
              next if skill == nil
              ct.push(skill)
            end
            next if i[4] == nil
            i[4].each do |skill|
              next if skill == nil
              if skill.type == Fixnum
                reprod.push(skill)
              else
                reprod.push(Skill_Info.id(skill))
              end
            end
          end
        end
      end
       
      if ct != [nil]
        @skills_allow = ct
      end
 
      if skills != [nil] and skills != []
        @skills_table = skills
        return if erase == false
        @skills_set = []
        initialize_skill
      end
    end