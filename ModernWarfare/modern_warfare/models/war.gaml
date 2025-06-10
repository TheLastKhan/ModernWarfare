model modern_warfare

global {
    // Simulation configuration
    int nb_friendlies <- 5;
    int nb_enemies <- 5;
    int world_size <- 100;
    int turn <- 0;
    
    // Weather variables
    string current_weather <- "clear"; // clear, rain, fog, storm
    int weather_change_freq <- 500;  // Weather changes every 500 turns
    float visibility_multiplier <- 1.0; // Default visibility
    string current_terrain <- "plain"; // plain, mountain, forest, sea
    
    // Day/Night cycle variables
    string current_time <- "day"; // day, night, dawn, dusk
    int time_change_freq <- 500;  // Her 500 turda zaman değişimi
    float day_visibility <- 1.0;
    float night_visibility <- 0.3;
    float dawn_visibility <- 0.7;
    float dusk_visibility <- 0.5;
    float time_visibility_multiplier <- 1.0;
    
    // Terrain grid
	grid terrain_cell width: world_size height: world_size {
    	string terrain_type <- "plain"; // Başlangıç değeri
    	rgb terrain_color <- #lightyellow; // Başlangıç rengi
    	//string terrain_type <- world.current_terrain; // All cells are same terrain
    	/* 
    	rgb terrain_color <- terrain_type = "plain" ? #lightyellow :
                       (terrain_type = "mountain" ? #gray :
                       (terrain_type = "forest" ? #lightgreen :
                       (terrain_type = "desert" ? #sandybrown :
                       (terrain_type = "snow" ? #snow : #lightblue)))); // sea rengi korundu ama kullanılmıyor    
        */
	}
    
    init {
    // Initialize terrain
    list<string> terrain_types <- ["plain", "mountain", "forest", "desert", "snow"]; // sea kaldırıldı
    // list<string> terrain_types <- ["plain", "mountain", "forest", "desert", "snow", "sea"]; // sea'yı tekrar aktif etmek için bu satırı kullan
    
    current_terrain <- one_of(terrain_types);
    
    // Update all terrain cells
    ask terrain_cell {
        terrain_type <- world.current_terrain;
        color <- (world.current_time = "night") ? 
                (terrain_type = "plain" ? rgb(139, 139, 95) :  // Darker yellow
                (terrain_type = "mountain" ? rgb(105, 105, 105) : // Darker gray
                (terrain_type = "forest" ? rgb(85, 107, 47) :     // Dark olive green
                (terrain_type = "desert" ? rgb(139, 115, 85) :    // Darker sandy brown
                (terrain_type = "snow" ? rgb(200, 200, 200) : rgb(72, 61, 139)))))) : // Darker colors for night
                (terrain_type = "plain" ? #lightyellow :
                (terrain_type = "mountain" ? #lightgray :
                (terrain_type = "forest" ? #lightgreen :
                (terrain_type = "desert" ? #sandybrown :
                (terrain_type = "snow" ? #snow : #lightblue)))));
    }
    /*
    
    switch current_terrain {
        match "plain" {
            write "🗺️ Arazi Değişti: Ova - Normal hareket.";
        }
        match "mountain" {
            write "🗺️ Arazi Değişti: Dağlık - Hareket yavaş, menzil artışı.";
        }
        match "forest" {
            write "🗺️ Arazi Değişti: Orman - Gizlilik artışı, görüş azalması.";
        }
        match "desert" {
            write "🗺️ Arazi Değişti: Çöl - Su tüketimi artışı, sıcaklık etkisi.";
        }
        match "snow" {
            write "🗺️ Arazi Değişti: Kar - Hareket zorlaşması, soğuk etkisi.";
        }
        match "sea" {
            write "🗺️ Arazi Değişti: Deniz - Sadece gemiler etkili.";
        } // Sea terrain etkisiz hale getirildi, gerektiğinde aktif edilebilir
    }
    
    */
    
    write "🗺️ Arazi Tipi: " + current_terrain;
        // Create friendly units
        do create_military_units(false);

        // Create enemy units
        do create_military_units(true);

        // Create logistics convoys
        create logistics number: 3 {
            is_enemy <- false;
            location <- {rnd(20) + 10, rnd(20) + 10};
            supplies <- 100.0;
        }

        create logistics number: 3 {
            is_enemy <- true;
            location <- {world_size - rnd(20) - 10, world_size - rnd(20) - 10};
            supplies <- 100.0;
        }

        // Create command centers
        create command_center number: 1 {
            is_enemy <- false;
            location <- {rnd(20) + 10, rnd(20) + 10};
            health <- 1000.0;
        }

        create command_center number: 1 {
            is_enemy <- true;
            location <- {world_size - rnd(20) - 10, world_size - rnd(20) - 10};
            health <- 1000.0;
        }
    }

    action create_military_units(bool enemy_status) {
        // Base position for deployment
        point base_pos <- enemy_status ? {world_size - 20, world_size - 20} : {20, 20};
        float spawn_radius <- 15.0;
        
        // Create units
        create infantry number: 10 {
            is_enemy <- enemy_status;
            location <- {base_pos.x + rnd(-spawn_radius, spawn_radius), 
                        base_pos.y + rnd(-spawn_radius, spawn_radius)};
        }
        create tank number: 5 {
            is_enemy <- enemy_status;
            location <- {base_pos.x + rnd(-spawn_radius, spawn_radius), 
                        base_pos.y + rnd(-spawn_radius, spawn_radius)};
        }
        create artillery number: 5 {
            is_enemy <- enemy_status;
            location <- {base_pos.x + rnd(-spawn_radius, spawn_radius), 
                        base_pos.y + rnd(-spawn_radius, spawn_radius)};
        }
        create jet number: 5 {
            is_enemy <- enemy_status;
            location <- {base_pos.x + rnd(-spawn_radius, spawn_radius), 
                        base_pos.y + rnd(-spawn_radius, spawn_radius)};
        }
        create drone number: 5 {
            is_enemy <- enemy_status;
            location <- {base_pos.x + rnd(-spawn_radius, spawn_radius), 
                        base_pos.y + rnd(-spawn_radius, spawn_radius)};
        }
        create warship number: 1 {
            is_enemy <- enemy_status;
            location <- {base_pos.x + rnd(-spawn_radius, spawn_radius), 
                        base_pos.y + rnd(-spawn_radius, spawn_radius)};
        }
        create defence number: 3 {
            is_enemy <- enemy_status;
            location <- {base_pos.x + rnd(-spawn_radius, spawn_radius), 
                        base_pos.y + rnd(-spawn_radius, spawn_radius)};
        }
    }

    reflex weather_changes when: (turn mod weather_change_freq = 0) {
        list<string> weather_types <- ["clear", "rain", "fog", "storm"];
        current_weather <- one_of(weather_types);
        
        // Update visibility based on weather
        switch current_weather {
            match "clear" {
                visibility_multiplier <- 1.0;
                write "🌞 Hava Durumu: Açık - Görüş mesafesi normal.";
            }
            match "rain" {
                visibility_multiplier <- 0.7;
                write "🌧️ Hava Durumu: Yağmur - Görüş mesafesi azaldı. Hareket yavaşladı.";
            }
            match "fog" {
                visibility_multiplier <- 0.5;
                write "🌫️ Hava Durumu: Sis - Görüş mesafesi ciddi şekilde azaldı.";
            }
            match "storm" {
                visibility_multiplier <- 0.3;
                write "⛈️ Hava Durumu: Fırtına - Hava operasyonları tehlikeli, görüş mesafesi çok düşük.";
            }
        }
    }
    
    reflex time_cycle when: (turn mod time_change_freq = 0) {
        list<string> time_periods <- ["day", "dawn", "night", "dusk"];
        
        int current_index <- 0;
    	loop i from: 0 to: length(time_periods) - 1 {
        if (time_periods[i] = current_time) {
            current_index <- i;
            break;
        }
    	}
    	
    	current_index <- (current_index + 1) mod length(time_periods);
    	current_time <- time_periods[current_index];
    	
        // Update visibility based on time of day
	    switch current_time {
	        match "day" {
	            time_visibility_multiplier <- day_visibility;
	            write "☀️ Zaman: Gündüz - Maksimum görüş mesafesi.";
	        }
	        match "dawn" {
	            time_visibility_multiplier <- dawn_visibility;
	            write "🌅 Zaman: Şafak - Görüş mesafesi iyileşiyor.";
	        }
	        match "night" {
	            time_visibility_multiplier <- night_visibility;
	            write "🌙 Zaman: Gece - Görüş mesafesi ciddi şekilde azaldı. Gece görüş avantajları aktif.";
	        }
	        match "dusk" {
	            time_visibility_multiplier <- dusk_visibility;
	            write "🌆 Zaman: Alacakaranlık - Görüş mesafesi azalıyor.";
	        }
	    }
    }

    reflex simulation_step {
        turn <- turn + 1;

        // Process logistics first
        ask logistics {
            do take_action;
        }

        // Process each unit type
        ask infantry {
            do check_supplies;
            do take_action;
        }
        ask tank {
            do check_supplies;
            do take_action;
        }
        ask artillery {
            do check_supplies;
            do take_action;
        }
        ask jet {
            do check_supplies;
            do take_action;
        }
        ask drone {
            do check_supplies;
            do take_action;
        }
        ask warship {
            do check_supplies;
            do take_action;
        }
        ask defence {
            do take_action;
        }
        ask command_center {
            do take_action;
        }

		    // DÜZELTME: Durgun ajanları harekete geçir
    	ask base_unit {
        // Eğer ajan çok uzun süre aynı yerdeyse, patrol moduna zorla
        if (current_action = "attack" and find_closest_enemy(attack_range) = nil) {
            current_action <- "patrol";
        }
        
        // Minimum hareket garantisi
        if (speed <= 0.0) {
            speed <- 0.1;
        }
        }
		
        // Count units and check for victory
        do check_victory_conditions;
    }
    
    action check_victory_conditions {
        // Count command centers
        list<command_center> friendly_command <- command_center where (!each.is_enemy);
        list<command_center> enemy_command <- command_center where (each.is_enemy);
        
        // Count combat units
        int friendly_count <- count_units(false);
        int enemy_count <- count_units(true);

        // Check victory conditions
        if (length(friendly_command) = 0 or friendly_count = 0) {
            write "💀 DOST BİRLİKLER YOK EDİLDİ! DÜŞMAN KAZANDI!";
            do pause;
        } else if (length(enemy_command) = 0 or enemy_count = 0) {
            write "🎉 DÜŞMANLAR TEMİZLENDİ! ZAFER KAZANILDI!";
            do pause;
        }
        
        // Display current status every 10 turns
        if (turn mod 10 = 0) {
            write "📊 Durum Raporu (Tur " + turn + "): ";
            write "   Dost Kuvvetler: " + friendly_count + " birim, " + 
                  length(friendly_command) + " komuta merkezi";
            write "   Düşman Kuvvetler: " + enemy_count + " birim, " + 
                  length(enemy_command) + " komuta merkezi";
        }
        if (turn > 35000) {
        write "⏰ ZAMAN AŞIMI! SAVAŞ BERABERE BİTTİ!";
        do pause;
    	}
    }
    
    int count_units(bool enemy_status) {
        return length(infantry where (each.is_enemy = enemy_status)) +
               length(tank where (each.is_enemy = enemy_status)) +
               length(artillery where (each.is_enemy = enemy_status)) +
               length(jet where (each.is_enemy = enemy_status)) +
               length(drone where (each.is_enemy = enemy_status)) +
               length(warship where (each.is_enemy = enemy_status)) +
               length(defence where (each.is_enemy = enemy_status));
    }
}

// Base unit that all military units inherit from
species base_unit skills: [moving] {
    bool is_enemy <- false;
    float health <- 100.0;
    float max_health <- 100.0;
    float speed <- 1.0;
    float base_speed <- 1.0;
    float attack_range <- 5.0;
    float base_attack_range <- 5.0;
    float attack_power <- 10.0;
    float ammunition <- 100.0;
    float fuel <- 1000.0;
    float morale <- 100.0;
    string current_action <- "patrol"; // patrol, attack, retreat, resupply
    point target_location <- nil;
    bool needs_resupply <- false;
    float max_ammunition <- 100.0;
    float max_fuel <- 100.0;
    float elevation <- 0.0; // 0-100 arası
    
    action calculate_elevation_advantage(base_unit target) {
    terrain_cell my_cell <- terrain_cell(location);
    terrain_cell target_cell <- terrain_cell(target.location);
    
    float my_elevation <- my_cell.terrain_type = "mountain" ? 50.0 : 0.0;
    float target_elevation <- target_cell.terrain_type = "mountain" ? 50.0 : 0.0;
    
    if (my_elevation > target_elevation) {
        attack_power <- attack_power * 1.2; // Yükseklik avantajı
        attack_range <- attack_range * 1.3;
    }
	}
    
    // Check if the unit needs supplies
    action check_supplies {
        if (ammunition < 30.0 or fuel < 30.0) {
            needs_resupply <- true;
            current_action <- "resupply";
            
            // Find nearest logistics unit of same faction
            logistics nearest_logistics <- nil;
            float min_dist <- 999999.0;
            
            loop l over: logistics where (each.is_enemy = self.is_enemy) {
                float dist <- self distance_to l;
                if (dist < min_dist) {
                    min_dist <- dist;
                    nearest_logistics <- l;
                }
            }
            
            if (nearest_logistics != nil) {
                target_location <- nearest_logistics.location;
            }
        }
    }
    
    // Resupply from logistics unit
    action get_resupplied {
        list<logistics> nearby_logistics <- logistics where (each.is_enemy = self.is_enemy) at_distance 3.0;
        if (!empty(nearby_logistics)) {
            ask nearby_logistics closest_to self {
                if (self.supplies > 20.0) {
                    self.supplies <- self.supplies - 20.0;
                    myself.ammunition <- myself.max_ammunition;
                    myself.fuel <- myself.max_fuel;
                    myself.needs_resupply <- false;
                    myself.current_action <- "patrol";
                    write myself.name + " yeniden ikmal edildi!";
                }
            }
        }
    }

    // Base unit take_action
    action take_action {
        // Apply terrain effects to speed
        terrain_cell current_cell <- terrain_cell(location);
        do apply_terrain_effects(current_cell);

        // Apply weather effects
        do apply_weather_effects;
        
        // Apply damage effects
    	do apply_damage_effects; 
        
        // Resupply if fuel runs out
    	if (fuel <= 0.0 and !needs_resupply) {
        	needs_resupply <- true;
        	current_action <- "resupply";
    	}

    // Handle different actions
	switch current_action {
	        match "retreat" {
	            // Find command center and retreat to it
	            command_center base <- (command_center where (each.is_enemy = self.is_enemy)) closest_to self;
	            if (base != nil) {
	                do goto target: base.location speed: speed;
	                // If reached safe distance to base, resume patrol
	                if (self distance_to base < 10) {
	                    current_action <- "patrol";
	                    morale <- min(morale + 10, 100.0);
	                }
	            } else {
	                current_action <- "patrol";
	            }
	        }
	        match "attack" {
	            // Find and attack targets
	            do find_and_attack_target();
	
	            // Low morale can cause retreat
	            if (health < 30.0 or morale < 20.0) {
	                current_action <- "retreat";
	            }
	            
	            // DÜZELTME: Eğer hedef bulunamazsa patrol moduna geç
	            if (find_closest_enemy(attack_range) = nil) {
	                current_action <- "patrol";
	            }
	        }
	        default { // patrol
	            // Random patrol movement - HER ZAMAN hareket et
	            do wander amplitude: 120.0 speed: max(speed, 0.1); // Minimum hız garantisi
	
	            // Check for enemies to engage
	            if (!needs_resupply) {
	                base_unit nearby_enemy <- find_closest_enemy(attack_range);
	                if (nearby_enemy != nil) {
	                    current_action <- "attack";
	                }
	            }
	
	            // Consume fuel while moving
	            fuel <- max(0.0, fuel - 0.1);
	        }
	    }
	}
    
	action apply_terrain_effects(terrain_cell cell) {
	    switch cell.terrain_type {
	        match "mountain" {
	            speed <- base_speed * 0.5;
	            attack_range <- base_attack_range * 1.2; // Higher vantage point
	        }
	        match "forest" {
	            speed <- base_speed * 0.7;
	            attack_range <- base_attack_range * 0.7; // Limited visibility
	        }
	        match "desert" {
	            speed <- base_speed * 0.8; // Heat and sand slow movement
	            // Desert provides clear sight lines
	            attack_range <- base_attack_range * 1.1;
	            // Increase water/fuel consumption (if you have resource system)
	        }
	        match "snow" {
	            speed <- base_speed * 0.6; // Snow significantly slows movement
	            attack_range <- base_attack_range * 0.9; // Snow reduces visibility slightly
	            // Cold weather affects equipment performance
	        }
	        match "tundra" {
            	speed <- base_speed * 0.5; // Extremely difficult movement on frozen ground
            	attack_range <- base_attack_range * 1.4; // Excellent visibility across flat tundra
            // Extreme cold causes equipment malfunction risk
            // Fuel consumption increases dramatically
        	}
	        match "sea" {
	            // Only warships can move normally on sea
	            if (species(self) != warship) {
	                speed <- base_speed * 0.1;
	            }
	        }
	        default { // plain
	            speed <- base_speed;
	            attack_range <- base_attack_range;
	        }
	    }
	}
	    
	action apply_weather_effects {
	    // Apply global weather effects
	    attack_range <- attack_range * world.visibility_multiplier;
	
	    // Specific weather effects
	    switch world.current_weather {
	        match "rain" {
	            speed <- speed * 0.9;
	            // Rain reduces visibility and accuracy
	            world.visibility_multiplier <- 0.8;
	        }
	        match "storm" {
	            speed <- speed * 0.7;
	            world.visibility_multiplier <- 0.6;
	            // Jets struggle in storms
	            if (species(self) = jet) {
	                speed <- speed * 0.5;
	                attack_power <- attack_power * 0.7;
	            }
	        }
	        match "fog" {
	            // Fog mainly affects visibility
	            world.visibility_multiplier <- 0.5;
	            speed <- speed * 0.95; // Slight speed reduction due to caution
	        }
	        match "snowy" {
	            speed <- speed * 0.8; // Snow slows all movement
	            world.visibility_multiplier <- 0.7; // Falling snow reduces visibility
	            // Ground units affected more than air units
	            if (species(self) = tank or species(self) = infantry) {
	                speed <- speed * 0.7; // Additional penalty for ground units
	            }
	        }
	        match "clear" {
	            world.visibility_multiplier <- 1.0; // Perfect visibility
	        }
	    }
	    // Apply time of day effects (mevcut action'ın sonuna ekle)
    	attack_range <- attack_range * world.time_visibility_multiplier;
    
    	// Special night effects
    	if (world.current_time = "night") {
        // Drones and jets have night vision advantage
        if (species(self) = drone or species(self) = jet) {
            attack_range <- attack_range * 1.3; // Night vision bonus
        }
        // Infantry gets stealth bonus at night
        if (species(self) = infantry) {
            speed <- speed * 1.1; // Stealth movement bonus
        }
    	}
	}
    
    action find_and_attack_target {
        // Set effective range based on terrain, weather, and unit type
        float effective_range <- attack_range;
        
        // Find closest enemy target
        base_unit target <- find_closest_enemy(effective_range);
        
        if (target != nil) {
            // Found target, set to attack mode
            current_action <- "attack";
            
            // Attack if in range
            float dist <- self distance_to target;
            if (dist <= effective_range) {
                // Use ammunition
                if (ammunition > 0) {
                    ammunition <- ammunition - 1.0;
                    float hit_chance <- calculate_hit_chance(target, dist);
                    
                    // Random hit based on hit chance
                    if (flip(hit_chance)) {
                        float damage <- attack_power;
                        
                        // Critical hit chance
                        if (flip(0.1)) {
                            damage <- damage * 1.5;
                            write name + " kritik vuruş yaptı!";
                        }
                        
                        ask target {
                            health <- health - damage;
                            morale <- morale - 5.0;
                            
                            if (health <= 0.0) {
                                write myself.name + " " + name + " birimini imha etti!";
                                do die;
                            }
                        }
                    } else {
                        write name + " hedefi ıskaladı.";
                    }
                } else {
                    // Out of ammo
                    needs_resupply <- true;
                    current_action <- "resupply";
                }
            } else {
                // Move towards target
                do goto target: target.location speed: speed;
            }
            } else {
	        // DÜZELTME: Hedef bulunamazsa patrol moduna geç
	        current_action <- "patrol";
	        do wander amplitude: 120.0 speed: max(speed, 0.1);
        	}
    }
    
    action apply_damage_effects {
    float health_ratio <- health / max_health;
    
    if (health_ratio < 0.7) {
        // Sağlık düşünce performans azalsın
        speed <- base_speed * (0.5 + health_ratio * 0.5);
        attack_range <- base_attack_range * (0.6 + health_ratio * 0.4);
        morale <- morale - 2.0; // Her tur morale düşer
    }
    
    if (health_ratio < 0.3) {
        // Kritik durum
        attack_power <- attack_power * 0.7;
        morale <- morale - 5.0;
    }
	}
    
	float calculate_hit_chance(base_unit target, float distance) {
	    // Base hit chance
	    float chance <- 0.9;
	
	    // Adjust for distance
	    chance <- chance * (1.0 - (distance / (attack_range * 2.0)));
	
	    // Adjust for weather
	    chance <- chance * world.visibility_multiplier;
	
	    // Adjust for terrain
	    terrain_cell target_cell <- terrain_cell(target.location);
	    if (target_cell.terrain_type = "forest") {
	        chance <- chance * 0.7; // Trees provide cover
	    } else if (target_cell.terrain_type = "mountain") {
	        chance <- chance * 0.7; // Rocky terrain provides cover
	    } else if (target_cell.terrain_type = "desert") {
	        chance <- chance * 1.1; // Clear sight lines in desert
	    } else if (target_cell.terrain_type = "snow") {
	        chance <- chance * 0.8; // Snow provides some concealment
		} else if (target_cell.terrain_type = "tundra") {
		     chance <- chance * 1.2; // Excellent visibility, nowhere to hide
		} else if (target_cell.terrain_type = "plain") {
		     chance <- chance * 1.0; // No terrain modifier
		}
	    // Sea terrain doesn't affect hit chance as units shouldn't be there unless they're ships
	
	    return max(0.1, min(0.95, chance)); // Clamp between 10% and 95%
	}
    
base_unit find_closest_enemy(float range) {
    // Find closest target across all unit types
    base_unit target <- nil;
    float min_dist <- range;

    // Create a list of all potential targets
    list<base_unit> potential_targets <- [];

    // Eğer bu unit jet veya drone ise
    if (species(self) = jet or species(self) = drone) {
        // Hava birimleri herkesi hedef alabilir
        potential_targets <- potential_targets + jet where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + drone where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + tank where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + artillery where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + warship where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + defence where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + infantry where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + command_center where (each.is_enemy != self.is_enemy);
    }
    else {
        // Kara/deniz birimleri - temel hedefler (herkes bunları vurabilir)
        potential_targets <- potential_targets + infantry where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + tank where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + artillery where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + warship where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + command_center where (each.is_enemy != self.is_enemy);
        potential_targets <- potential_targets + defence where (each.is_enemy != self.is_enemy);

        // Sadece warship ve defence hava birimlerini vurabilir
        if (species(self) = warship or species(self) = defence) {
            potential_targets <- potential_targets + jet where (each.is_enemy != self.is_enemy);
            potential_targets <- potential_targets + drone where (each.is_enemy != self.is_enemy);
        }
    }

    loop unit over: potential_targets {
        float dist <- self distance_to unit;
        if (dist <= min_dist) {
            min_dist <- dist;
            target <- unit;
        }
    }

    return target;
}
    
    aspect default {
        // Default visualization
        draw circle(1.0) color: is_enemy ? #red : #green;
        
        // Show health bar
        draw line([{location.x - 1, location.y - 1.5}, {location.x - 1 + (2 * health/max_health), location.y - 1.5}]) 
            color: health > 50 ? #green : (health > 25 ? #yellow : #red) width: 0.2;
            
        // Show current action icon
        string status_icon <- "";
        switch current_action {
            match "attack" {
                status_icon <- "⚔️";
            }
            match "retreat" {
                status_icon <- "🏃";
            }
            match "resupply" {
                status_icon <- "🔄";
            }
            default {
                status_icon <- "";
            }
        }
        
        if (status_icon != "") {
            draw status_icon at: {location.x, location.y - 1} color: #black size: 1.0;
        }
    }
}

species infantry parent: base_unit {
    init {
        max_ammunition <- 100.0;
        max_fuel <- 1000.0;
        base_speed <- 1.2;
        speed <- base_speed;
        base_attack_range <- 5.0;
        attack_range <- base_attack_range;
        attack_power <- 15.0;
    }
    
    aspect default {
        draw "👤" at: location size: 10 color: is_enemy ? #red : #green; // Piyade ikonu değiştirildi
        
        // Show health bar
        draw line([{location.x - 1, location.y - 1.5}, {location.x - 1 + (2 * health/max_health), location.y - 1.5}]) 
            color: health > 50 ? #green : (health > 25 ? #yellow : #red) width: 0.2;
    }
}

species tank parent: base_unit {
    init {
        max_ammunition <- 70.0;
        max_fuel <- 1000.0;
        base_speed <- 0.7;
        speed <- base_speed;
        base_attack_range <- 10.0;
        attack_range <- base_attack_range;
        attack_power <- 35.0;
        ammunition <- max_ammunition;
        fuel <- max_fuel;
    }
    
    aspect default {
        draw "🚗" at: location size: 10 color: is_enemy ? #red : #green; // Tank ikonu düzeltildi
        
        // Show health bar
        draw line([{location.x - 1.5, location.y - 2}, {location.x - 1.5 + (3 * health/max_health), location.y - 2}]) 
            color: health > 50 ? #green : (health > 25 ? #yellow : #red) width: 0.2;
    }
}

species artillery parent: base_unit {
    init {
        max_ammunition <- 50.0;
        max_fuel <- 100.0;
        base_speed <- 0.3;
        speed <- base_speed;
        base_attack_range <- 30.0;
        attack_range <- base_attack_range;
        attack_power <- 35.0;
        ammunition <- max_ammunition;
        fuel <- max_fuel;
    }
    
    aspect default {
    	draw "🎯" at: location size: 10 color: is_enemy ? #red : #green; // Topçu
        
        // Show health bar
        draw line([{location.x - 1.8, location.y - 2.3}, {location.x - 1.8 + (3.6 * health/max_health), location.y - 2.3}]) 
            color: health > 50 ? #green : (health > 25 ? #yellow : #red) width: 0.2;
    }
}

species jet parent: base_unit {
    init {
        max_ammunition <- 50.0;
        max_fuel <- 1000.0;
        base_speed <- 5.0;
        speed <- base_speed;
        base_attack_range <- 10.0;
        attack_range <- base_attack_range;
        attack_power <- 50.0;
        ammunition <- max_ammunition;
        fuel <- max_fuel;
    }
    
    aspect default {
    	draw "✈️" at: location size: 10 color: is_enemy ? #red : #green; // Jet
        
        // Show health bar
        draw line([{location.x - 1.2, location.y - 1.7}, {location.x - 1.2 + (2.4 * health/max_health), location.y - 1.7}]) 
            color: health > 50 ? #green : (health > 25 ? #yellow : #red) width: 0.2;
    }
    
    // Jets consume fuel faster
    reflex consume_fuel {
        fuel <- max(0.0, fuel - 0.1);
        if (fuel <= 0.0) {
            needs_resupply <- true;
            current_action <- "resupply";
        }
    }
}

species drone parent: base_unit {
    bool recon_mode <- true;
    float recon_range <- 10.0;
    
    init {
        max_ammunition <- 50.0;
        max_fuel <- 1000.0;
        base_speed <- 3.0;
        speed <- base_speed;
        base_attack_range <- 10.0;
        attack_range <- base_attack_range;
        attack_power <- 50.0;
        ammunition <- max_ammunition;
        fuel <- max_fuel;
    }
    
    // Drones can spot enemies from further away
    reflex recon when: recon_mode {
        list<base_unit> spotted_enemies <- [];
        
        // Add all enemy units within recon range
        spotted_enemies <- spotted_enemies + infantry where ((each.is_enemy != self.is_enemy) and (each distance_to self <= recon_range));
        spotted_enemies <- spotted_enemies + tank where ((each.is_enemy != self.is_enemy) and (each distance_to self <= recon_range));
        spotted_enemies <- spotted_enemies + artillery where ((each.is_enemy != self.is_enemy) and (each distance_to self <= recon_range));
        spotted_enemies <- spotted_enemies + jet where ((each.is_enemy != self.is_enemy) and (each distance_to self <= recon_range));
        spotted_enemies <- spotted_enemies + drone where ((each.is_enemy != self.is_enemy) and (each distance_to self <= recon_range));
        spotted_enemies <- spotted_enemies + warship where ((each.is_enemy != self.is_enemy) and (each distance_to self <= recon_range));
        spotted_enemies <- spotted_enemies + defence where ((each.is_enemy != self.is_enemy) and (each distance_to self <= recon_range));
        
        if (!empty(spotted_enemies)) {
            write name + " düşman tespit etti: " + length(spotted_enemies) + " birim.";
            recon_mode <- false;
            current_action <- "attack";
        }
    }
    
    aspect default {
    	draw "🚁" at: location size: 10 color: is_enemy ? #red : #green;
        
    	// Show recon radius only when alive and in recon mode
    	if (health > 0 and recon_mode) {
    		draw circle(recon_range) color: is_enemy ? rgb(255,0,0,50) : rgb(0,255,0,50);	
        }
        
        // Show health bar
    	draw line([{location.x - 1, location.y - 1.5}, {location.x - 1 + (2 * health/max_health), location.y - 1.5}]) 
        	color: health > 50 ? #green : (health > 25 ? #yellow : #red) width: 0.2;
    }
}

species warship parent: base_unit {
    init {
        max_ammunition <- 70.0;
        max_fuel <- 1000.0;
        base_speed <- 0.7;
        speed <- base_speed;
        base_attack_range <- 15.0;
        attack_range <- base_attack_range;
        attack_power <- 25.0;
        ammunition <- max_ammunition;
        fuel <- max_fuel;
    }
    
    // FIX: Override without using "as" syntax that can cause recursion
    action take_action {
        // Warships can only move effectively on sea
        terrain_cell current_cell <- terrain_cell(location);
        if (current_cell.terrain_type != "sea") {
            speed <- base_speed * 0.1;
        } else {
            speed <- base_speed;
        }

        // Apply weather effects
        do apply_weather_effects;

        // Handle different actions
        switch current_action {
            match "resupply" {
                if (needs_resupply) {
                    if (target_location != nil) {
                        do goto target: target_location speed: speed;
                        do get_resupplied();
                    }
                } else {
                    current_action <- "patrol";
                }
            }
            match "retreat" {
                // Find command center and retreat to it
                command_center base <- (command_center where (each.is_enemy = self.is_enemy)) closest_to self;
                if (base != nil) {
                    do goto target: base.location speed: speed;
                    // If reached safe distance to base, resume patrol
                    if (self distance_to base < 10) {
                        current_action <- "patrol";
                        morale <- min(morale + 10, 100.0);
                    }
                } else {
                    current_action <- "patrol";
                }
            }
            match "attack" {
                // Find and attack targets
                do find_and_attack_target();

                // Low morale can cause retreat
                if (health < 30.0 or morale < 20.0) {
                    current_action <- "retreat";
                }
            }
            default { // patrol
                // Random patrol movement
                do wander amplitude: 120.0 speed: speed;

                // Check for enemies to engage
                if (!needs_resupply) {
                    do find_and_attack_target();
                }

                // Consume fuel while moving
                fuel <- max(0.0, fuel - 0.1);
            }
        }
    }
    
    aspect default {
    	draw "🛥️" at: location size: 10 color: is_enemy ? #red : #green; // Gemi  
        
        // Show health bar
        draw line([{location.x - 1.7, location.y - 2.2}, {location.x - 1.7 + (3.4 * health/max_health), location.y - 2.2}]) 
            color: health > 50 ? #green : (health > 25 ? #yellow : #red) width: 0.2;
    }
}

species defence parent: base_unit {
    float detection_range <- 10.0; // 5'den 10'ye çıkarıldı (2 katına yakın)
    
    init {
        max_ammunition <- 100.0;
        base_speed <- 0.1;
        speed <- 0.1;
        base_attack_range <- 15.0; // 5'ten 15'e çıkarıldı
        attack_range <- base_attack_range;
        attack_power <- 25.0; // 15'ten 25'e çıkarıldı
        ammunition <- max_ammunition;
        fuel <- 1000.0;
    }
    
    // Defensive structures automatically detect and engage enemies
    reflex detect_enemies {
        list<base_unit> enemies_in_range <- [];
        
        // Add all enemy units within detection range
        enemies_in_range <- enemies_in_range + infantry where ((each.is_enemy != self.is_enemy) and (each distance_to self <= detection_range));
        enemies_in_range <- enemies_in_range + tank where ((each.is_enemy != self.is_enemy) and (each distance_to self <= detection_range));
        enemies_in_range <- enemies_in_range + artillery where ((each.is_enemy != self.is_enemy) and (each distance_to self <= detection_range));
        enemies_in_range <- enemies_in_range + jet where ((each.is_enemy != self.is_enemy) and (each distance_to self <= detection_range));
        enemies_in_range <- enemies_in_range + drone where ((each.is_enemy != self.is_enemy) and (each distance_to self <= detection_range));
        enemies_in_range <- enemies_in_range + warship where ((each.is_enemy != self.is_enemy) and (each distance_to self <= detection_range));
        
        if (!empty(enemies_in_range)) {
            current_action <- "attack";
        }
    }
    
    aspect default {
        draw "🚀" at: location size: 10 color: is_enemy ? #red : #green; // Roket
        
    	// Show detection radius only when alive
    	if (health > 0) {
        	draw circle(detection_range) color: is_enemy ? rgb(255,0,0,50) : rgb(0,255,0,50);
    	}
        
    	// Show health bar
    	draw line([{location.x - 1.5, location.y - 2}, {location.x - 1.5 + (3 * health/max_health), location.y - 2}]) 
        	color: health > 50 ? #green : (health > 25 ? #yellow : #red) width: 0.2;
    	}
}

// Command Center acts as headquarters and supply base
species command_center parent: base_unit {
    float production_rate <- 0.1;
    float supply_production <- 0.1;
    int reinforcement_counter <- 0;
    int max_reinforcements <- 0; // Maksimum takviye sayısı
    int reinforcements_produced <- 0;
    float speed <- 0.0;        // Hız sıfır
    bool can_move <- false;    // Hareket edemez bayrağı
    
    init {
        base_speed <- 0.0;
        speed <- 0.0;
        health <- 1000.0;
        max_health <- 500.0;
        attack_range <- 10.0;
        attack_power <- 15.0;
    }
    
    reflex produce_supplies {
        // Command centers produce supplies
        list<logistics> nearby_logistics <- logistics where (each.is_enemy = self.is_enemy) at_distance 5.0;
        if (!empty(nearby_logistics)) {
            ask nearby_logistics {
                supplies <- min(supplies + 1.0, 200.0);
            }
        }
        
        // Sadece belirli sayıda takviye üret
        if (reinforcements_produced < max_reinforcements) {
            reinforcement_counter <- reinforcement_counter + 1;
            if (reinforcement_counter >= 150) { // Üretim hızını yavaşlat (150 turda 1)
                reinforcement_counter <- 0;
                reinforcements_produced <- reinforcements_produced + 1;
                
                // Choose a random unit type to produce
                list<string> unit_types <- ["infantry", "tank", "artillery", "drone"];
                string unit_to_produce <- one_of(unit_types);
                
                write "🏭 " + (is_enemy ? "Düşman" : "Dost") + " komuta merkezi yeni bir " + unit_to_produce + " üretti!";
                
                switch unit_to_produce {
                    match "infantry" {
                        create infantry {
                            is_enemy <- myself.is_enemy;
                            location <- myself.location + {rnd(-5.0, 5.0), rnd(-5.0, 5.0)};
                        }
                    }
                    match "tank" {
                        create tank {
                            is_enemy <- myself.is_enemy;
                            location <- myself.location + {rnd(-5.0, 5.0), rnd(-5.0, 5.0)};
                        }
                    }
                    match "artillery" {
                        create artillery {
                            is_enemy <- myself.is_enemy;
                            location <- myself.location + {rnd(-5.0, 5.0), rnd(-5.0, 5.0)};
                        }
                    }
                    match "drone" {
                        create drone {
                            is_enemy <- myself.is_enemy;
                            location <- myself.location + {rnd(-5.0, 5.0), rnd(-5.0, 5.0)};
                        }
                    }
                }
            }
        }
    }
    
    action take_action {
        // Sadece savunma, hareket YOK
        current_action <- "defend";
        
         // Yakındaki düşmanları kontrol et ve alarm ver
        base_unit nearby_enemy <- (base_unit where (each.is_enemy != self.is_enemy)) 
                                   closest_to self;
        if (nearby_enemy != nil and (self distance_to nearby_enemy) < 15) {
            // Yakındaki dostları uyar
            ask base_unit where (each.is_enemy = self.is_enemy and 
                               (each distance_to self) < 20) {
                if (current_action = "patrol") {
                    current_action <- "attack";
                }
            }
        }
    }
    
    aspect default {
		draw "🏰" at: location size: 15 color: is_enemy ? #red : #green; // Kale
        draw line([{location.x - 2, location.y - 2}, {location.x - 2 + (4 * health/max_health), location.y - 2}]) 
            color: health > 200 ? #green : (health > 100 ? #yellow : #red) width: 0.3;
    }
}

// Logistics unit for resupplying combat units
species logistics skills: [moving] {
    bool is_enemy <- false;
    float supplies <- 100.0;
    float max_supplies <- 200.0;
    float health <- 70.0;
    float max_health <- 70.0;
    float speed <- 0.7;
    string current_status <- "idle"; // idle, moving, resupplying
    point target_location <- nil;
    float medical_supplies <- 50.0;
    
    action provide_medical_aid(base_unit unit) {
        if (medical_supplies > 10.0 and unit.health < unit.max_health) {
            medical_supplies <- medical_supplies - 10.0;
            ask unit {
                health <- min(health + 30.0, max_health);
                morale <- min(morale + 15.0, 100.0);
            }
        }
    }
    
    action take_action {
        // Apply terrain effects
        terrain_cell current_cell <- terrain_cell(location);
        switch current_cell.terrain_type {
            match "mountain" {
                speed <- 0.3;
            }
            match "forest" {
                speed <- 0.5;
            }
            match "desert" {
                speed <- 0.5;
            }
            match "snow" {
                speed <- 0.5;
            }
            match "sea" {
                speed <- 0.1; // Logistics can barely move on water
            }
            default { // plain
                speed <- 0.7;
            }
        }
        
        // Apply weather effects
        switch world.current_weather {
            match "rain" {
                speed <- speed * 0.8;
            }
            match "storm" {
                speed <- speed * 0.5;
            }
        }
        
        // Check for nearby units that need resupply
        list<base_unit> units_needing_supply <- infantry where (each.is_enemy = self.is_enemy and each.needs_resupply and each distance_to self <= 25.0) +
                                              tank where (each.is_enemy = self.is_enemy and each.needs_resupply and each distance_to self <= 25.0) +
                                              artillery where (each.is_enemy = self.is_enemy and each.needs_resupply and each distance_to self <= 25.0) +
                                              jet where (each.is_enemy = self.is_enemy and each.needs_resupply and each distance_to self <= 25.0) +
                                              drone where (each.is_enemy = self.is_enemy and each.needs_resupply and each distance_to self <= 25.0) +
                                              warship where (each.is_enemy = self.is_enemy and each.needs_resupply and each distance_to self <= 25.0);
        
        // If we have units to supply and enough supplies
        if (!empty(units_needing_supply) and supplies > 20.0) {
            // Find closest unit needing supply
            base_unit closest_unit <- units_needing_supply closest_to self;
            
            if (closest_unit != nil) {
                if (self distance_to closest_unit > 3.0) {
                    // Move toward unit
                    do goto target: closest_unit.location speed: speed;
                    current_status <- "moving";
                } else {
                    // Close enough to resupply
                    current_status <- "resupplying";
                    
                    if (supplies >= 20.0) {
                        // Resupply the unit
                        ask closest_unit {
                            ammunition <- max_ammunition;
                            fuel <- max_fuel;
                            needs_resupply <- false;
                            current_action <- "patrol";
                        }
                        
                        supplies <- supplies - 20.0;
                        write "🔄 " + (is_enemy ? "Düşman" : "Dost") + " lojistik birimi ikmal sağladı. Kalan ikmal: " + supplies;
                    }
                }
            }
        } else {
            // If low on supplies, go to command center
            if (supplies < 50.0) {
                command_center base <- (command_center where (each.is_enemy = self.is_enemy)) closest_to self;
                if (base != nil and self distance_to base > 5.0) {
                    do goto target: base.location speed: speed;
                    current_status <- "moving";
                } else if (base != nil) {
                    current_status <- "idle";
                    supplies <- min(supplies + 1.0, max_supplies);
                }
            } else {
                // Patrol near command center
                command_center base <- (command_center where (each.is_enemy = self.is_enemy)) closest_to self;
                if (base != nil and self distance_to base > 20.0) {
                    do goto target: base.location speed: speed;
                } else {
                    do wander amplitude: 90.0 speed: speed;
                }
                current_status <- "idle";
            
            }
        
        }
        
        // Check for enemies that might attack logistics
        list<base_unit> nearby_enemies <- [];
        nearby_enemies <- nearby_enemies + infantry where ((each.is_enemy != self.is_enemy) and (each distance_to self <= 5.0));
        nearby_enemies <- nearby_enemies + tank where ((each.is_enemy != self.is_enemy) and (each distance_to self <= 5.0));
        nearby_enemies <- nearby_enemies + artillery where ((each.is_enemy != self.is_enemy) and (each distance_to self <= 5.0));
        
        if (!empty(nearby_enemies)) {
            // Logistics is under attack! Try to retreat
            command_center base <- (command_center where (each.is_enemy = self.is_enemy)) closest_to self;
            if (base != nil) {
                do goto target: base.location speed: speed * 1.2;
                write "🚨 " + (is_enemy ? "Düşman" : "Dost") + " lojistik birimi saldırı altında! Geri çekiliyor!";
            
            }
        
        }
    
    }
    
    aspect default {
    	draw "🚚" at: location size: 2 color: is_enemy ? #red : #green; // Lojistik
        
        // Show status
        string status_icon <- "";
        switch current_status {
            match "moving" {
                status_icon <- "🔄";
            }
            match "resupplying" {
                status_icon <- "📦";
            }
            default {
                status_icon <- "🔄";
            }
        }
        
        draw status_icon at: {location.x, location.y - 1.5} color: #black size: 1.0;
        
        // Show supply level
        draw line([{location.x - 2, location.y - 2.5}, {location.x - 2 + (4 * supplies/max_supplies), location.y - 2.5}]) 
            color: supplies > 100 ? #blue : (supplies > 50 ? #yellow : #red) width: 0.2;
    
    }

}

experiment modern_warfare_simulation type: gui {
    parameter "Friendly Units" var: nb_friendlies min: 3 max: 15 init: 5;
    parameter "Enemy Units" var: nb_enemies min: 3 max: 15 init: 5;
    parameter "World Size" var: world_size min: 100 max: 200 init: 100;
    parameter "Weather Change Frequency" var: weather_change_freq min: 100 max: 500 init: 50;
    
    output {
        display map_display {
            grid terrain_cell;
            
            species infantry aspect: default;
            species tank aspect: default;
            species artillery aspect: default;
            species jet aspect: default;
            species drone aspect: default;
            species warship aspect: default;
            species defence aspect: default;
            species command_center aspect: default;
            species logistics aspect: default;
            
            // Display the current weather in the corner
graphics "simulation_info" {
    string weather_symbol <- "";
    switch world.current_weather {
        match "clear" { weather_symbol <- "🌞"; }
        match "rain" { weather_symbol <- "🌧️"; }
        match "fog" { weather_symbol <- "🌫️"; }
        match "storm" { weather_symbol <- "⛈️"; }
        match "snow" { weather_symbol <- "❄️"; }
    }
    
    string terrain_symbol <- "";
    switch world.current_terrain {
        match "plain" { terrain_symbol <- "🗺️"; }
        match "mountain" { terrain_symbol <- "⛰️"; }
        match "forest" { terrain_symbol <- "🌲"; }
        match "desert" { terrain_symbol <- "🏜️"; }
    	match "snow" { terrain_symbol <- "🏔️"; }
	    match "tundra" { terrain_symbol <- "🧊"; }	    	
        match "sea" { terrain_symbol <- "🌊"; }
    }
    
    string time_symbol <- "";
    switch world.current_time {
        match "day" { time_symbol <- "☀️"; }
        match "night" { time_symbol <- "🌙"; }
        match "dawn" { time_symbol <- "🌅"; }
        match "dusk" { time_symbol <- "🌆"; }
    }
    
    draw "Time: " + world.current_time + " " + time_symbol at: {world_size - 20, 6} size: 25 color: #red;
    draw "Weather: " + world.current_weather + " " + weather_symbol at: {world_size - 20, 9} size: 25 color: #purple;
    draw "Terrain: " + world.current_terrain + " " + terrain_symbol at: {world_size - 20, 12} size: 25 color: #brown;
    draw "Round: " + world.turn at: {world_size - 20, 15} font: font("Arial", 12, #bold) color: #black;
	
	}
}
        
        // Display showing unit counts
        display unit_statistics refresh: every(10#cycles) {
            chart "Birlik Sayıları" type: series size: {0.9, 0.4} position: {0.05, 0.05} {
                data "Dost Kuvvetler" value: world.count_units(false) style: line color: #green;
                data "Düşman Kuvvetler" value: world.count_units(true) style: line color: #red;
            }
            
            chart "Birlik Dağılımı (Dost)" type: pie size: {0.5, 0.5} position: {0.01, 0.5} {
                data "Piyade" value: length(infantry where (!each.is_enemy)) color: #green;
                data "Tank" value: length(tank where (!each.is_enemy)) color: #darkgreen;
                data "Topçu" value: length(artillery where (!each.is_enemy)) color: #lightgreen;
                data "Jet" value: length(jet where (!each.is_enemy)) color: #limegreen;
                data "İHA" value: length(drone where (!each.is_enemy)) color: #mediumseagreen;
                data "Gemi" value: length(warship where (!each.is_enemy)) color: #forestgreen;
                data "Savunma" value: length(defence where (!each.is_enemy)) color: #springgreen;
            }
            
            chart "Birlik Dağılımı (Düşman)" type: pie size: {0.5, 0.5} position: {0.50, 0.5} {
                data "Piyade" value: length(infantry where (each.is_enemy)) color: #red;
                data "Tank" value: length(tank where (each.is_enemy)) color: #darkred;
                data "Topçu" value: length(artillery where (each.is_enemy)) color: #orangered;
                data "Jet" value: length(jet where (each.is_enemy)) color: #firebrick;
                data "İHA" value: length(drone where (each.is_enemy)) color: #indianred;
                data "Gemi" value: length(warship where (each.is_enemy)) color: #maroon;
                data "Savunma" value: length(defence where (each.is_enemy)) color: #crimson;
            }
        }   
    }
}











