module CONSTS
  AGES = (14..70).map { |num| [num, num]}.to_h
  GRADES = { "level_1"=>"Основное общее образование (школа)",
            "level_2"=>"Среднее профессиональное образование (техникум, колледж)",
          "level_3"=>"Высшее образование" }
  PURPOSE = {"purpose_1"=> "Развлекательная",
            "purpose_2"=> "Обращение к психологу/диагносту",
            "purpose_3"=> "Исследование ЦПД МВД",
            "purpose_4"=> "Аттестация работников транспортной инфраструктуры"
      }
end
