-- Surg, note: "cookingtime" and "burningtime" values sets for ideal conditions, without heating and buffs coefficients.

local foods =
{
    -- 01 Loaf of Bread
    quagmire_food_001 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 return names.quagmire_flour and names.quagmire_flour == count
               end,
        stations = {"oven"},
        cravings = {"bread", "snack"},
        cookingtime = 11,
        burningtime = 6,
    },
    -- 02 Potato Chips
    quagmire_food_002 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.potato and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.mushroom and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.garlic and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.potato > 3) then return false end
                    if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"snack", "veggie"},
        cookingtime = 23,
        burningtime = 6,
    },
    -- 03 Vegetable Soup
    quagmire_food_003 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in tomato, how much? (currently algorithm can only 1)
                 --                  can we put in garlic, how much? (currently algorithm can only 1)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 local result = tags.veggie and not tags.inedible and not names.quagmire_flour and not tags.herbal and not names.quagmire_spotspice_ground and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.potato and tags.potato > 2) then return false end
                    if (tags.carrot and tags.carrot > 2) then return false end
                    if (tags.tomato and tags.tomato > 1) then return false end
                    if (tags.turnip and tags.turnip > 2) then return false end
                    if (tags.onion and tags.onion > 2) then return false end
                    if (tags.spicy and tags.spicy > 1) then return false end
                    if (tags.mushroom and tags.mushroom > 2) then return false end
                    if (tags.carrot and tags.carrot >= 2 and tags.spicy) then return false end
                    if (tags.potato and tags.potato >= 2 and tags.spicy) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"snack", "soup", "veggie"},
        dish = "bowl",
        cookingtime = 19,
        burningtime = 7,
    },
    -- 04 Jelly Sandwich
    quagmire_food_004 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = names.quagmire_flour and tags.sweet and not tags.inedible and not tags.herbal and not tags.veggie and not tags.spicy and not tags.meat and not names.quagmire_goatmilk and not names.quagmire_sap
                 if result then
                    if (names.quagmire_flour > 2) then return false end
                    if (names.quagmire_flour > tags.sweet) then return false end
                    if (names.quagmire_syrup and names.quagmire_syrup > 1) then return false end
                    if (names.quagmire_syrup and tags.berries and tags.berries >= 2) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"snack", "bread"},
        cookingtime = 12,
        burningtime = 5,
    },
    -- 05 Fish Stew
    quagmire_food_005 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in garlic, how much? (currently algorithm is impossible)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 return tags.fish and not tags.inedible and not names.quagmire_flour and not tags.spicy and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
               end,
        stations = {"pot"},
        cravings = {"fish", "soup"},
        dish = "bowl",
        cookingtime = 21,
        burningtime = 7,
    },
    -- 06 Turnip Cake
    quagmire_food_006 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we put in garlic, how much? (currently algorithm is impossible)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 --                  can we put in mushroom, how much? (currently algorithm is impossible)
                 --                  can we put in potato, how much? (currently algorithm is impossible)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.turnip and tags.turnip >= 2 and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.mushroom and
                 not tags.potato and not tags.tomato and not tags.spicy and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.turnip < count - 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"snack", "veggie"},
        cookingtime = 23,
        burningtime = 6,
    },
    -- 07 Potato Pancakes
    quagmire_food_007 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.potato and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.mushroom and not tags.carrot and not tags.tomato and not tags.turnip and not tags.spicy and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.potato > 3) then return false end
                    if (tags.onion and tags.onion > 1) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"snack", "veggie"},
        cookingtime = 13,
        burningtime = 5,
    },
    -- 08 Potato Soup
    quagmire_food_008 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.potato and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.mushroom and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.garlic and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"veggie", "snack", "soup"},
        dish = "bowl",
        cookingtime = 17,
        burningtime = 7,
    },
    -- 09 Fishball Skewers
    quagmire_food_009 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in mushroom? (currently algorithm can)
                 --                  can we put in tomato? (currently algorithm is impossible)
                 --                  can we put in garlic? (currently algorithm can)
                 --                  can we put in spotspice_ground? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 return tags.fish and names.twigs and names.twigs == 1 and not names.rocks and not names.quagmire_flour and not tags.herbal and not tags.tomato and not names.quagmire_spotspice_ground and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
               end,
        stations = {"grill"},
        cravings = {"snack", "fish"},
        cookingtime = 14,
        burningtime = 5,
    },
    -- 10 Meatballs
    quagmire_food_010 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in mushroom, how much? (currently algorithm is impossible)
                 --                  can we put in tomato, how much? (currently algorithm is impossible)
                 --                  can we put in garlic, how much? (currently algorithm is impossible)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 return tags.tendermeat and not tags.inedible and not names.quagmire_flour and not tags.mushroom and not tags.tomato and not tags.spicy and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
               end,
        stations = {"pot"},
        cravings = {"meat", "snack"},
        cookingtime = 26,
        burningtime = 7,
    },
    -- 11 Meat Skewers
    quagmire_food_011 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we put in potato, how much? (currently algorithm is impossible)
                 --                  can we put in carrot, how much? (currently algorithm is impossible)
                 --                  can we put in tomato, how much? (currently algorithm is impossible)
                 --                  can we put in turnip, how much? (currently algorithm is can)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 if (count < 3 or count > 4) then return false end
                 local result = names.twigs and names.twigs == 1 and tags.tendermeat and tags.tendermeat >= 2 and not names.rocks and not names.quagmire_flour and not tags.herbal and not tags.potato and not tags.carrot and not tags.tomato and not names.quagmire_spotspice_ground and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.veggie and tags.veggie > 1) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"snack", "meat"},
        cookingtime = 13,
        burningtime = 5,
    },
    -- 12 Stone Soup
    quagmire_food_012 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in carrot, how much? (currently algorithm can only 1)
                 --                  can we put in tomato, how much? (currently algorithm can only 1)
                 --                  can we put in turnip, how much? (currently algorithm can only 1)
                 --                  can we put in onion, how much? (currently algorithm can only 1)
                 --                  can we put in garlic, how much? (currently algorithm can only 1)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 local result = names.rocks and tags.veggie and not names.twigs and not names.quagmire_flour and not names.quagmire_spotspice_ground and not tags.meat and not names.quagmire_goatmilk and not names.quagmire_sap and not names.quagmire_syrup
                 if result then
                    if (names.rocks > 1) then return false end
                    if (tags.herbal and tags.herbal > 1) then return false end
                    if (tags.mushroom and tags.mushroom > 1) then return false end
                    if (tags.potato and tags.potato > 1) then return false end
                    if (tags.carrot and tags.carrot > 1) then return false end
                    if (tags.tomato and tags.tomato > 1) then return false end
                    if (tags.turnip and tags.turnip > 1) then return false end
                    if (tags.onion and tags.onion > 1) then return false end
                    if (tags.garlic and tags.garlic > 1) then return false end
                    if (tags.berries and tags.berries > 1) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"snack", "soup"},
        dish = "bowl",
        cookingtime = 19,
        burningtime = 7,
    },
    -- 13 Croquette
    quagmire_food_013 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in tomato, how much? (currently algorithm can only 1)
                 --                  can we put in garlic, how much? (currently algorithm can only 1)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 local result = names.quagmire_flour and tags.veggie and tags.potato and
                                not tags.inedible and
                                not tags.herbal and
                                not names.quagmire_spotspice_ground and
                                not tags.meat and
                                not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"snack", "veggie"},
        cookingtime = 13,
        burningtime = 6,
    },
    -- 14 Roast Vegetables
    quagmire_food_014 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in herbal, how much? (currently algorithm is impossible)
                 --                  can we put in tomato, how much? (currently algorithm can)
                 if (count ~= 3) then return false end
                 local result = tags.veggie and not tags.inedible and not names.quagmire_flour and not tags.herbal and not names.quagmire_spotspice_ground and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.mushroom and tags.mushroom > 2) then return false end
                    if (tags.potato and tags.potato > 2) then return false end
                    if (tags.carrot and tags.carrot > 2) then return false end
                    if (tags.onion and tags.onion > 2) then return false end
					if (tags.turnip and tags.turnip > 1) then return false end
                    if (tags.tomato and tags.tomato > 1) then return false end                    
                    if (tags.garlic and tags.garlic > 1) then return false end
					if (tags.garlic and tags.mushroom and tags.onion) then return false end 
                    if (tags.onion and tags.potato and tags.potato > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven", "grill"},
        cravings = {"veggie"},
        cookingtime = {oven = 23, grill = 13},
        burningtime = {oven = 6, grill = 5},
    },
    -- 15 Meatloaf
    quagmire_food_015 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in carrot, how much? (currently algorithm can)
                 --                  can we put in tomato, how much? (currently algorithm can)
                 --                  can we put in turnip, how much? (currently algorithm can)
                 --                  can we put in onion, how much? (currently algorithm can)
                 --                  can we put in garlic, how much? (currently algorithm can only 1)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 local result = tags.tendermeat and tags.veggie and not tags.inedible and not names.quagmire_flour and not names.quagmire_spotspice_ground and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.garlic and tags.garlic > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"meat"},
        cookingtime = 26,
        burningtime = 6,
    },
    -- 16 Carrot Soup
    quagmire_food_016 =
    {
        test = function(names, tags, count)

                 if (count < 3 or count > 4) then return false end
                 local result = tags.carrot and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.mushroom and not tags.potato and not tags.tomato and not tags.turnip and not tags.onion and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.spicy and tags.spicy > 1) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"veggie", "snack", "soup"},
        dish = "bowl",
        cookingtime = 17,
        burningtime = 7,
    },
    -- 17 Fish Pie
    quagmire_food_017 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in 2 fish (currently algorithm can only 1)
                 --                  can we put in herbal, how much? (currently algorithm is impossible)
                 --                  can we put in garlic, how much? (currently algorithm is impossible)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 local result = names.quagmire_flour and tags.fish and tags.veggie and not tags.inedible and not tags.herbal and not tags.potato and not tags.spicy and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 1) then return false end
                    if (tags.fish > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"fish"},
        cookingtime = 26,
        burningtime = 6,
    },
    -- 18 Fish and Chips
    quagmire_food_018 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = names.quagmire_flour and tags.potato and tags.fish and not tags.inedible and not tags.herbal and not tags.mushroom and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.spicy and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 2) then return false end
                    if (tags.potato > 2) then return false end
                    if (tags.fish > 2) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"fish"},
        cookingtime = 26,
        burningtime = 6,
    },
    -- 19 Meat Pie
    quagmire_food_019 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in herbal, how much? (currently algorithm is impossible)
                 --                  can we put in tomato, how much? (currently algorithm can)
                 --                  can we put in garlic, how much? (currently algorithm is impossible)
                 --                  can we put in spotspice_ground, how much? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 return names.quagmire_flour and tags.tendermeat and tags.veggie and not tags.inedible and not tags.herbal and not tags.garlic and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
               end,
        stations = {"oven"},
        cravings = {"meat"},
        cookingtime = 26,
        burningtime = 6,
    },
    -- 20 Sliders
    quagmire_food_020 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in mushroom, potato, carrot, turnip, onion? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 local result = names.quagmire_flour and tags.tendermeat and not tags.inedible and not tags.mushroom and not tags.potato and not tags.carrot and not tags.turnip and not tags.onion and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.herbal and tags.herbal > 1) then return false end
                    if (tags.tomato and tags.tomato > 1) then return false end
                    if (tags.spicy and tags.spicy > 1) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"bread", "snack", "meat"},
        cookingtime = 16,
        burningtime = 5,
    },
    -- 21 Fist Full of Jam
    quagmire_food_021 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.sweet and tags.berries and not tags.inedible and not names.quagmire_flour and not tags.veggie and not tags.spicy and not tags.meat and not names.quagmire_goatmilk and not names.quagmire_sap
                 if result then
                    if (names.quagmire_syrup and names.quagmire_syrup > tags.berries) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"snack", "sweet"},
        cookingtime = 21,
        burningtime = 7,
    },
    -- 22 Jelly Roll
    quagmire_food_022 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = names.quagmire_flour and tags.berries and not tags.inedible and not tags.herbal and not tags.veggie and not tags.spicy and not tags.meat and not names.quagmire_goatmilk and not names.quagmire_sap and not names.quagmire_syrup
                 if result then
                    if (names.quagmire_flour < 1) then return false end
                    if (names.quagmire_flour > tags.berries) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"sweet"},
        cookingtime = 23,
        burningtime = 6,
    },
    -- 23 Carrot Cake
    quagmire_food_023 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = names.quagmire_flour and tags.carrot and not tags.inedible and not tags.herbal and not tags.potato and not tags.tomato and not tags.turnip and not tags.onion and not tags.mushroom and not tags.spicy and not tags.meat and not tags.berries and not names.quagmire_sap
                 if result then
                    if (tags.carrot > 2) then return false end
                    if (names.quagmire_flour ~= 2) then return false end
                    if (names.quagmire_goatmilk and names.quagmire_goatmilk > 1) then return false end
                    if (names.quagmire_syrup and names.quagmire_syrup > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"sweet"},
        cookingtime = 23,
        burningtime = 6,
    },
    -- 24 Garlic Mashed Potatoes
    quagmire_food_024 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.potato and tags.garlic and not tags.inedible and not tags.herbal and not names.quagmire_flour and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not names.quagmire_spotspice_ground and not tags.mushroom and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.garlic > 1) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"snack", "veggie"},
        dish = "bowl",
        cookingtime = 19,
        burningtime = 7,
    },
    -- 25 Garlic Bread
    quagmire_food_025 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = names.quagmire_flour and tags.garlic and not tags.inedible and not tags.herbal and not tags.veggie and not names.quagmire_spotspice_ground and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.garlic > 2) then return false end
                    if (names.quagmire_flour < 2) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"bread", "snack"},
        cookingtime = 23,
        burningtime = 6,
    },
    -- 26 Tomato Soup
    quagmire_food_026 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.tomato and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.mushroom and not tags.potato and not tags.carrot and not tags.turnip and not tags.onion and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.spicy and tags.spicy > 1) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"soup", "veggie", "snack"},
        dish = "bowl",
        cookingtime = 16,
        burningtime = 7,
    },
    -- 27 Sausage
    quagmire_food_027 =
    {
        test = function(names, tags, count)
                 --Surg: ToDo check, can we use more 3 slots? (currently algorithm can only 3)
                 --                  can we put in mushroom, how much? (currently algorithm is impossible)
                 --                  can we put in turnip, how much? (currently algorithm can)
                 --                  can we put in onion, how much? (currently algorithm can)
                 --                  can we put in garlic, how much? (currently algorithm is impossible)
                 if (count ~= 3) then return false end
                 local result = tags.tendermeat and names.quagmire_spotspice_ground and names.quagmire_spotspice_ground == 1 and not tags.inedible and not names.quagmire_flour and not tags.mushroom and not tags.garlic and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.veggie and tags.veggie > 1) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"snack", "meat"},
        cookingtime = 13,
        burningtime = 5,
    },
    -- 28 Candied Fish
    quagmire_food_028 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.fish and names.quagmire_syrup and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.veggie and not tags.spicy and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.berries and not names.quagmire_sap
                 if result then
                    if (names.quagmire_syrup > 2) then return false end
                    if (tags.fish > 2) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"snack", "fish"},
        cookingtime = 26,
        burningtime = 6,
    },
    -- 29 Stuffed Mushroom
    quagmire_food_029 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 return tags.mushroom  and tags.onion and tags.onion == 1 and tags.garlic and tags.garlic == 1 and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.potato and not tags.carrot and not tags.tomato and not tags.turnip and not names.quagmire_spotspice_ground and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
               end,
        stations = {"oven"},
        cravings = {"snack", "veggie"},
        cookingtime = 23,
        burningtime = 6,
    },
    -- 30 Ratatouille
    quagmire_food_030 =
    {
        --Surg: ToDo check, can we put in herbal, how much? (currently algorithm is impossible)
        --                  can we put in garlic, how much? (currently algorithm can)
        --                  can we put in more 2 veggie? (currently algorithm is impossible)
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.veggie and not tags.inedible and not names.quagmire_flour and not tags.herbal and not names.quagmire_spotspice_ground and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                     if (tags.mushroom and tags.mushroom > 1) then return false end
                     if (tags.potato and tags.potato > 1) then return false end
                     if (tags.carrot and tags.carrot > 1) then return false end
                     if (tags.tomato and tags.tomato > 1) then return false end
                     if (tags.turnip and tags.turnip > 1) then return false end
                     if (tags.onion and tags.onion > 1) then return false end
                     if (tags.garlic and tags.garlic > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"veggie"},
        dish = "bowl",
        cookingtime = 28,
        burningtime = 6,
    },
    -- 31 Bruschetta
    quagmire_food_031 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.tomato and names.quagmire_flour and names.quagmire_flour == 1 and not tags.inedible and not tags.mushroom and not tags.potato and not tags.carrot and not tags.turnip and not tags.onion and not tags.meat and not tags.sweet
                 if result then
                     if (tags.tomato > 2) then return false end
                     if (tags.herbal and tags.herbal > 1) then return false end
                     if (tags.garlic and tags.garlic > 1) then return false end
                     if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                     if (names.quagmire_goatmilk and names.quagmire_goatmilk > 1) then return false end
                     if (tags.garlic and names.quagmire_spotspice_ground) then return false end
                     if (tags.herbal and tags.spicy) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"snack", "bread", "veggie"},
        cookingtime = 13,
        burningtime = 5,
    },
    -- 32 Meat Stew
    quagmire_food_032 =
    {
        --Surg: ToDo check, can we put in herbal, how much? (currently algorithm is impossible)
        --                  can we put in garlic, how much? (currently algorithm can)
        --                  can we put in mushroom, how much? (currently algorithm can)
        --                  can we put in tomato, how much? (currently algorithm can)
        --                  can we put in turnip, how much? (currently algorithm can)
        --                  can we put in more 2 spotspice_ground? (currently algorithm is impossible)
        --                  can we put in more 2 garlic? (currently algorithm can 2)
        --                  can we put in more 2 onion? (currently algorithm can 2)
        --                  can we put together spotspice_ground and garlic? (currently algorithm is impossible)
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.tendermeat and tags.tendermeat >= 2 and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                     if (tags.garlic and names.quagmire_spotspice_ground) then return false end
                     if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"meat", "soup"},
        dish = "bowl",
        cookingtime = 21,
        burningtime = 7,
    },
    -- 33 Hamburger
    quagmire_food_033 =
    {
        --Surg: ToDo check, can we put in garlic? (currently algorithm can only 1)
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.tendermeat and names.quagmire_flour and not tags.inedible and not tags.mushroom and not tags.potato and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                     if (tags.garlic and names.quagmire_spotspice_ground) then return false end
                     if (names.quagmire_flour > 2) then return false end
                     if (tags.garlic and tags.garlic > 1) then return false end
                     if (tags.garlic and tags.garlic > 1) then return false end
                     if (tags.herbal and tags.herbal > 1) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"bread", "meat"},
        cookingtime = 16,
        burningtime = 5,
    },
    -- 34 Fish Burger
    quagmire_food_034 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.fish and names.quagmire_flour and not tags.inedible and not tags.mushroom and not tags.potato and not tags.carrot and not tags.turnip and not tags.onion and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                     if (tags.fish > 2) then return false end
                     if (names.quagmire_flour > 2) then return false end
                     if (tags.veggie and tags.veggie > 1) then return false end
                     if (tags.spicy and tags.spicy > 1) then return false end
                     if (tags.garlic and names.quagmire_spotspice_ground) then return false end
                     if (tags.veggie and tags.spicy) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"bread", "fish"},
        cookingtime = 16,
        burningtime = 5,
    },
    -- 35 Mushroom Burger
    quagmire_food_035 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.mushroom and names.quagmire_flour and not tags.inedible and not tags.herbal and not tags.potato and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.meat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                     if (names.quagmire_flour > 2) then return false end
                     if (tags.spicy and tags.spicy > 1) then return false end
                     if (tags.garlic and names.quagmire_spotspice_ground) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"bread", "veggie"},
        cookingtime = 13,
        burningtime = 5,
    },
    -- 36 Fish Steak
    quagmire_food_036 =
    {
        --Surg: ToDo check, can we put in garlic, how much? (currently algorithm is impossible)
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return tags.fish and tags.fish == 1 and tags.veggie and tags.herbal and tags.herbal == 1 and names.quagmire_spotspice_ground and names.quagmire_spotspice_ground == 1 and not tags.inedible and not names.quagmire_flour and not tags.garlic and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 
               end,
        stations = {"grill"},
        cravings = {"fish"},
        cookingtime = 17,
        burningtime = 5,
    },
    -- 37 Curry
    quagmire_food_037 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return tags.tendermeat and tags.tendermeat == 1 and names.quagmire_spotspice_ground and names.quagmire_spotspice_ground == 2 and not tags.inedible and not tags.herbal and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
               end,
        stations = {"pot"},
        cravings = {"soup", "meat"},
        dish = "bowl",
        cookingtime = 23,
        burningtime = 7,
    },
    -- 38 Spaghetti and Meatball
    quagmire_food_038 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = names.quagmire_flour and tags.tomato and tags.tendermeat and not tags.inedible and not tags.herbal and not tags.potato and not tags.carrot and not tags.turnip and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then                    
                    if (names.quagmire_flour > 1) then return false end
                    if (tags.tomato > 1) then return false end
                    if (tags.tendermeat > 1) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"pasta", "meat"},
        cookingtime = 19,
        burningtime = 7,
    },
    -- 39 Lasagna
    quagmire_food_039 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = names.quagmire_flour and tags.tomato and tags.tendermeat and not tags.inedible and not tags.herbal and not tags.potato and not tags.carrot and not tags.turnip and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 1) then return false end
                    if (tags.tomato > 1) then return false end
                    if (tags.tendermeat > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"pasta", "meat"},
        cookingtime = 28,
        burningtime = 6,
    },
    -- 40 Poached Fish
    quagmire_food_040 =
    {
        --Surg: ToDo check, can we put in garlic? (currently algorithm is impossible)
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.fish and tags.veggie and tags.herbal and names.quagmire_spotspice_ground and not tags.inedible and not names.quagmire_flour and not tags.garlic and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.fish > 1) then return false end
                    if (tags.herbal > 1) then return false end
                    if (names.quagmire_spotspice_ground > 1) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"fish"},
        cookingtime = 24,
        burningtime = 7,
    },
    -- 41 Shepherd's Pie
    quagmire_food_041 =
    {
        --Surg: ToDo check, can we put in herbal, how much? (currently algorithm is impossible)
        --                  can we put in mushroom, how much? (currently algorithm can)
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.tendermeat and tags.veggie and tags.potato and tags.spicy and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.fish and not tags.crabmeat and not tags.toughmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.tendermeat > 1) then return false end
                    if (tags.potato > 1) then return false end
                    if (tags.garlic and tags.garlic > 1) then return false end
                    if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"meat"},
        cookingtime = 29,
        burningtime = 6,
    },
    -- 42 Candy
    quagmire_food_042 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 return names.quagmire_syrup and names.quagmire_syrup >= 3 and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.veggie and not tags.spicy and not tags.meat and not names.quagmire_goatmilk and not tags.berries and not names.quagmire_sap
               end,
        stations = {"pot"},
        cravings = {"sweet"},
        cookingtime = 5,
        burningtime = 7,
    },
    -- 43 Bread Pudding
    quagmire_food_043 =
    {
        --Surg: ToDo check, can we put in garlic? (currently algorithm is impossible)
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = names.quagmire_flour and names.quagmire_syrup and not tags.inedible and not tags.veggie and not tags.garlic and not tags.meat and not names.quagmire_goatmilk and not names.quagmire_sap
                 if result then
                    if (names.quagmire_flour < 2) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"sweet"},
        cookingtime = 11,
        burningtime = 6,
    },
    -- 44 Waffles
    quagmire_food_044 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 return names.quagmire_syrup and names.quagmire_flour and names.quagmire_flour >= 2 and not tags.inedible and not tags.veggie and not tags.spicy and not tags.meat and not tags.berries and not names.quagmire_goatmilk and not names.quagmire_sap
               end,
        stations = {"grill"},
        cravings = {"sweet"},
        cookingtime = 5,
        burningtime = 5,
    },
    -- 45 Berry Tart
    quagmire_food_045 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.berries and names.quagmire_flour and names.quagmire_syrup and not tags.inedible and not tags.veggie and not tags.spicy and not tags.meat and not names.quagmire_goatmilk and not names.quagmire_sap
                 if result then
                    if (names.quagmire_flour > 1) then return false end
                    if (names.quagmire_syrup > 2) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"sweet"},
        cookingtime = 24,
        burningtime = 6,
    },
    -- 46 Macaroni and Cheese
    quagmire_food_046 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = names.quagmire_flour and names.quagmire_goatmilk and not tags.inedible and not tags.veggie and not tags.spicy and not tags.meat and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 2) then return false end
                    if (names.quagmire_goatmilk > 2) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"cheese", "pasta"},
        dish = "bowl",
        cookingtime = 9,
        burningtime = 7,
    },
    -- 47 Bagel and Fish
    quagmire_food_047 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return names.quagmire_flour and names.quagmire_flour == 1 and names.quagmire_goatmilk and names.quagmire_goatmilk == 1 and tags.fish and tags.fish == 1 and not tags.inedible and not tags.herbal and not tags.mushroom and not tags.potato and not tags.carrot and not tags.tomato and not tags.turnip and not tags.garlic and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not tags.sweet
               end,
        stations = {"grill"},
        cravings = {"fish", "snack", "bread"},
        cookingtime = 14,
        burningtime = 5,
    },
    -- 48 grilled Cheese
    quagmire_food_048 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = names.quagmire_flour and names.quagmire_goatmilk and not tags.inedible and not tags.veggie and not tags.spicy and not tags.meat and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 2) then return false end
                    if (names.quagmire_goatmilk > 2) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"snack", "bread", "cheese"},
        cookingtime = 5,
        burningtime = 5,
    },
    -- 49 Cream Of Mushroom Soup
    quagmire_food_049 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = tags.mushroom and names.quagmire_goatmilk and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.potato and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.spicy and not tags.meat and not tags.sweet
                 if result then
                    if (tags.mushroom > 2) then return false end
                    if (names.quagmire_goatmilk > 2) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"snack", "soup", "cheese", "veggie"},
        dish = "bowl",
        cookingtime = 16,
        burningtime = 7,
    },
    -- 50 Pierogi
    quagmire_food_050 =
    {
        --Surg: ToDo check, can we put in garlic? (currently algorithm can)
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 return names.quagmire_flour and names.quagmire_flour == 1 and names.quagmire_goatmilk and tags.potato and not tags.inedible and not tags.herbal and not tags.mushroom and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.fish and not tags.crabmeat and not tags.toughmeat and not tags.sweet
               end,
        stations = {"pot"},
        cravings = {"veggie", "cheese"},
        cookingtime = 16,
        burningtime = 7,
    },
    -- 51 Manicotti
    quagmire_food_051 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = names.quagmire_flour and names.quagmire_goatmilk and tags.tomato and not tags.inedible and not tags.mushroom and not tags.potato and not tags.carrot and not tags.turnip and not tags.onion and not tags.meat and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 1) then return false end
                    if (names.quagmire_goatmilk > 2) then return false end
                    if (tags.tomato > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"pasta", "cheese"},
        cookingtime = 26,
        burningtime = 6,
    },
    -- 52 Cheeseburger
    quagmire_food_052 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.tendermeat and names.quagmire_flour and names.quagmire_goatmilk and not tags.inedible and not tags.mushroom and not tags.potato and not tags.carrot and not tags.turnip and not tags.fish and not tags.crabmeat and not tags.toughmeat and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 1) then return false end
                    if (names.quagmire_goatmilk > 1) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"bread", "meat", "cheese"},
        cookingtime = 17,
        burningtime = 5,
    },
    -- 53 Creamy Fettuccine
    quagmire_food_053 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return names.quagmire_flour and tags.garlic and names.quagmire_goatmilk and names.quagmire_goatmilk == 2
               end,
        stations = {"pot"},
        cravings = {"pasta"},
        cookingtime = 19,
        burningtime = 7,
    },
    -- 54 Onion Soup
    quagmire_food_054 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return names.quagmire_flour and names.quagmire_goatmilk and tags.onion and tags.onion == 2
               end,
        stations = {"pot"},
        cravings = {"soup", "veggie", "snack"},
        dish = "bowl",
        cookingtime = 17,
        burningtime = 7,
    },
    -- 55 Breaded Cutlet
    quagmire_food_055 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return tags.toughmeat and names.quagmire_flour and names.quagmire_flour == 2 and not tags.inedible and not tags.herbal and not tags.veggie and not tags.garlic and not tags.fish and not tags.crabmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
               end,
        stations = {"oven"},
        cravings = {"meat"},
        cookingtime = 29,
        burningtime = 6,
    },
    -- 56 Creamy Fish
    quagmire_food_056 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return names.quagmire_goatmilk and tags.fish and tags.fish == 1 and names.quagmire_spotspice_ground and names.quagmire_spotspice_ground == 1 and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.mushroom and not tags.potato and not tags.carrot and not tags.tomato and not tags.turnip and not tags.crabmeat and not tags.toughmeat and not tags.tendermeat and not tags.sweet
               end,
        stations = {"oven"},
        cravings = {"fish"},
        cookingtime = 29,
        burningtime = 6,
    },
    -- 57 Pizza
    quagmire_food_057 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return tags.tendermeat and names.quagmire_flour and names.quagmire_goatmilk and tags.tomato
               end,
        stations = {"oven"},
        cravings = {"meat", "cheese"},
        cookingtime = 29,
        burningtime = 6,
    },
    -- 58 Pot Roast
    quagmire_food_058 =
    {
        --Surg: ToDo check, can we put in onion, how much? (currently algorithm can only 1)
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.toughmeat and tags.veggie and tags.spicy and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.fish and not tags.crabmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.toughmeat > 2) then return false end
                    if (tags.mushroom and tags.mushroom > 1) then return false end
                    if (tags.potato and tags.potato > 1) then return false end
                    if (tags.carrot and tags.carrot > 1) then return false end
                    if (tags.tomato and tags.tomato > 1) then return false end
                    if (tags.turnip and tags.turnip > 1) then return false end
                    if (tags.onion and tags.onion > 1) then return false end
                    if (tags.garlic and tags.garlic > 1) then return false end
                    if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"meat"},
        cookingtime = 32,
        burningtime = 6,
    },
    -- 59 Crab Cake
    quagmire_food_059 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.crabmeat and names.quagmire_flour and not tags.inedible and not tags.herbal and not tags.mushroom and not tags.carrot and not tags.tomato and not tags.turnip and not tags.fish and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.veggie and tags.veggie > 1) then return false end
                    if (tags.crabmeat > 2) then return false end
                    if (names.quagmire_flour > 1) then return false end
                    if (tags.potato and tags.potato > 1) then return false end
                    if (tags.onion and tags.onion > 1) then return false end
                    if (tags.garlic and tags.garlic > 1) then return false end
                    if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"snack"},
        cookingtime = 29,
        burningtime = 6,
    },
    -- 60 Steak Frites
    quagmire_food_060 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.toughmeat and tags.potato and not tags.inedible and not tags.herbal and not names.quagmire_flour and not tags.mushroom and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.garlic and not tags.fish and not tags.crabmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.toughmeat > 2) then return false end
                    if (tags.potato > 2) then return false end
                    if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"meat"},
        cookingtime = 21,
        burningtime = 5,
    },
    -- 61 Shooter Sandwich
    quagmire_food_061 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.toughmeat and names.quagmire_flour and names.quagmire_flour == 1 and not tags.inedible and not tags.herbal and not tags.potato and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.fish and not tags.crabmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.toughmeat > 2) then return false end
                    if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                    if (tags.garlic and tags.garlic > 1) then return false end
                    if (tags.mushroom and tags.mushroom > 1) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"bread", "meat"},
        cookingtime = 19,
        burningtime = 5,
    },
    -- 62 Bacon Wrapped Meat
    quagmire_food_062 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.toughmeat and tags.tendermeat and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.veggie and not tags.garlic and not tags.fish and not tags.crabmeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.toughmeat > 2) then return false end
                    if (tags.tendermeat > 2) then return false end
                    if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"meat"},
        cookingtime = 23,
        burningtime = 6,
    },
    -- 63 Crab Roll
    quagmire_food_063 =
    {
        --Surg: ToDo check, can we put in garlic? (currently algorithm can only 1)
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.crabmeat and names.quagmire_flour and not tags.inedible and not tags.potato and not tags.carrot and not tags.turnip and not names.quagmire_spotspice_ground and not tags.fish and not tags.toughmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 1) then return false end
                    if (tags.crabmeat > 2) then return false end
                    if (tags.herbal and tags.herbal > 1) then return false end
                    if (tags.mushroom and tags.mushroom > 1) then return false end
                    if (tags.tomato and tags.tomato > 1) then return false end
                    if (tags.onion and tags.onion > 1) then return false end
                    if (tags.garlic and tags.garlic > 1) then return false end
                    if (tags.veggie and not tags.herbal and tags.veggie > 1) then return false end
                    if (tags.veggie and not tags.herbal and tags.garlic) then return false end
                    if (tags.herbal and tags.garlic) then return false end
                 end
                 return result
               end,
        stations = {"grill"},
        cravings = {"bread"},
        cookingtime = 21,
        burningtime = 5,
    },
    -- 64 Meat Wellington
    quagmire_food_064 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.toughmeat and names.quagmire_flour and not tags.inedible and not tags.herbal and not tags.potato and not tags.carrot and not tags.tomato and not tags.turnip and not tags.onion and not tags.fish and not tags.crabmeat and not tags.tendermeat and not names.quagmire_goatmilk and not tags.sweet
                 if result then
                    if (tags.toughmeat > 2) then return false end
                    if (names.quagmire_flour > 1) then return false end
                    if (names.quagmire_spotspice_ground and names.quagmire_spotspice_ground > 1) then return false end
                    if (tags.garlic and tags.garlic > 1) then return false end
                 end
                 return result
               end,
        stations = {"oven"},
        cravings = {"meat"},
        cookingtime = 23,
        burningtime = 6,
    },
    -- 65 Crab Ravioli
    quagmire_food_065 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 local result = tags.crabmeat and names.quagmire_flour and names.quagmire_goatmilk and not tags.inedible and not tags.herbal and not tags.potato and not tags.carrot and not tags.tomato and not tags.turnip and not tags.fish and not tags.toughmeat and not tags.tendermeat and not tags.sweet
                 if result then
                    if (names.quagmire_flour > 1) then return false end
                    if (names.quagmire_goatmilk > 1) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"pasta", "cheese"},
        cookingtime = 21,
        burningtime = 7,
    },
    -- 66 Caramel Cube
    quagmire_food_066 =
    {
        test = function(names, tags, count)
                 if (count < 3 or count > 4) then return false end
                 local result = names.quagmire_goatmilk and names.quagmire_syrup and not tags.inedible and not names.quagmire_flour and not tags.herbal and not tags.veggie and not tags.spicy and not tags.meat and not tags.berries and not names.quagmire_sap
                 if result then
                    if (names.quagmire_syrup > 2) then return false end
                    if (names.quagmire_goatmilk > 2) then return false end
                 end
                 return result
               end,
        stations = {"pot"},
        cravings = {"sweet"},
        cookingtime = 5,
        burningtime = 7,
    },
    -- 67 Scone
    quagmire_food_067 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return tags.berries and names.quagmire_goatmilk and names.quagmire_flour and names.quagmire_flour == 2
               end,
        stations = {"grill"},
        cravings = {"sweet", "bread"},
        cookingtime = 13,
        burningtime = 5,
    },
    -- 68 Trifle
    quagmire_food_068 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return tags.berries and names.quagmire_goatmilk and names.quagmire_flour and names.quagmire_flour == 2
               end,
        stations = {"oven"},
        cravings = {"sweet"},
        cookingtime = 27,
        burningtime = 6,
    },
    -- 69 Cheesecake
    quagmire_food_069 =
    {
        test = function(names, tags, count)
                 if (count ~= 4) then return false end
                 return tags.berries and names.quagmire_flour and names.quagmire_goatmilk and names.quagmire_goatmilk == 2
               end,
        stations = {"oven"},
        cravings = {"sweet", "cheese"},
        cookingtime = 27,
        burningtime = 6,
    },
    -- 70 Syrup
    quagmire_syrup =
    {
        test = function(names, tags, count)
                 if (count ~= 3) then return false end
                 return names.quagmire_sap and names.quagmire_sap == 3
               end,
        stations = {"pot"},
        cookingtime = 11,
        burningtime = 7,
    },
}

for k, v in pairs(foods) do
    v.name = k
    v.cooktime = v.cooktime or 1
    v.dish = v.dish or "plate"

    --Surg: dish for quagmire_syrup must be nil (used in announcement cooked)
    if v.name == "quagmire_syrup" then
        v.dish = nil
    end

    v.stations = v.stations or {}
    v.cravings = v.cravings or {}
    v.cookingtime = v.cookingtime or 23
    v.burningtime = v.burningtime or 7
end

return foods
