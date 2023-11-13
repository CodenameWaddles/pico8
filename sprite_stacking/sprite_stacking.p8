pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
 
---------------- constants ----------------
accel=0.1
drag=0.05
max_speed=2.5
min_speed=0.05
wheel_dist = 10
player_length=16
player_width=8
player_angle_offset=0.25
player_collsion_size=2
delay_threshold1=0.6
delay_threshold2=0.85
building_distance_ratio=1/35
car_distance_ratio=1/80
render_y=25
render_distance=100
pavement_flag=0
solid_flag=1
road_flag=2
classic_car_sprite_x=0
classic_car_sprite_y=40
car_trans_color=4
car_default_color1=12
car_default_color2=1
max_npc_road_dist=5
car_speed=1
car_total_turn_delay=9
collision_impulse=1
car_drag=0.05
min_car_speed=0.06
car_returning_threshold=4
car_move_delay=400
delivery_time=60
delivery_amount=4
building_colors={1, 2, 3, 4, 5, 9}
building_min_height=2
building_max_height=5
building_styles={'residential', 'store', 'glass'}
classic_total_time=300
delivery_points=10
player_move=false
transition_speed=1/30
car_colors={4, 8, 9, 10, 11, 12, 14}

----- delivery lane coords -----
x_delivery_lanes={{54, 80, 1, 's'}, {66, 73, 19, 's'}, {60, 62, 19, 's'}, {60, 73, 6, 'n'}, {43, 51, 22, 'n'}, {43, 51, 40, 's'}, {60, 67, 24, 'n'}, {60, 67, 40, 's'},
{75, 79, 32, 's'}, {81, 88, 12, 'n'}, {81, 88, 19, 's'}, {81, 93, 7, 's'}, {87, 94, 24, 'n'}, {75, 85, 37, 'n'}, {49, 73, 45, 'n'}, {36, 42, 45, 'n'}, {37, 52, 17, 's'},
{20, 32, 29, 's'}, {22, 34, 34, 'n'}, {35, 51, 60, 'n'}}
y_delivery_lanes={{8, 18, 58, 'w'}, {8, 18, 74, 'e'}, {1, 6, 79, 'w'}, {1, 15, 53, 'e'}, {25, 35, 53, 'e'}, {25, 38, 41, 'w'}, {27, 38, 68, 'e'}, {27, 38, 58, 'w'},
{27, 30, 80, 'e'}, {27, 30, 73, 'w'}, {14, 17, 89, 'e'}, {14, 18, 79, 'w'}, {7, 25, 94, 'w'}, {27, 38, 85, 'w'}, {39, 46, 73, 'w'}, {36, 46, 36, 'e'}, {17, 29, 36, 'e'},
{49, 60, 48, 'w'}}
n_houses={{20, 22}, {25, 22}, {3, 22}, {11, 8}, {15, 8}, {18, 8}, {20, 62}}
s_houses={{3, -1}, {10, -1}, {14, -1}, {19, -1}, {25, -1}, {10, 13}, {14, 13}, {17, 13}, {27, 53}}
w_houses={{8, 10}, {30, 3}, {30, 7}, {30, 11}, {30, 14}, {30, 18}, {23, 39}, {23, 44}, {23, 48}}
e_houses={{21, 10}, {-1, 2}, {-1, 6}, {-1, 9}, {-1, 14}, {-1, 17}, {8, 25}, {8, 31}, {14, 40}, {14, 46}, {14, 51}, {14, 56}}

cars_coords={{41, 30}, {55, 30}, {66, 24}, {58, 33}, {70, 37}, {77, 24}, {77, 34}, {85, 12}, {84, 21}, {58, 15}, {69, 6}, {38, 29}, {60, 45}, {85, 30}, {94, 14}, {79, 5}, {55, 8}, {25, 12}, {35, 57}}

---------------- player ----------------

function make_player()
    player={}
    player.angle=0 player.dir=player.angle+0.5 player.drift_delay=1 player.dirs={}
    player.dirs[1]=player.angle+0.5 player.dirs[2]=player.angle+0.5 player.dirs[3]=player.angle+0.5 player.dirs[4]=player.angle+0.5
    player.speed=0 player.dx=0 player.dy=0 player.rotation_speed=1
    player.x=65*8+4 player.y=19*8+6 player.fwheel={x=0,y=0} player.bwheel={x=0,y=0}
    player.collision_points={}
    --corner points, eg. cfr = corner front right
    player.cfr={x=0,y=0} player.cfl={x=0,y=0} player.cbr={x=0,y=0} player.cbl={x=0,y=0}
    add(player.collision_points, player.cfr) add(player.collision_points, player.cfl) add(player.collision_points, player.cbr) add(player.collision_points, player.cbl)
    player.element='player'
    return player
end

function update_player(player)
    local frx= player.cfr.x + cos(player.angle + 0.25)*player_collsion_size
    local fry= player.cfr.y + sin(player.angle + 0.25)*player_collsion_size
    local flx= player.cfl.x + cos(player.angle - 0.25)*player_collsion_size
    local fly= player.cfl.y + sin(player.angle - 0.25)*player_collsion_size
    local brx= player.cbr.x + cos(player.angle + 0.25)*player_collsion_size/2
    local bry= player.cbr.y + sin(player.angle + 0.25)*player_collsion_size/2
    local blx= player.cbl.x + cos(player.angle - 0.25)*player_collsion_size/2
    local bly= player.cbl.y + sin(player.angle - 0.25)*player_collsion_size/2

    local fr2x= player.cfr.x + cos(player.angle - 0.25)*player_collsion_size
    local fr2y= player.cfr.y + sin(player.angle - 0.25)*player_collsion_size
    local fl2x= player.cfl.x + cos(player.angle + 0.25)*player_collsion_size
    local fl2y= player.cfl.y + sin(player.angle + 0.25)*player_collsion_size
    local br2x= player.cbr.x + cos(player.angle - 0.25)*player_collsion_size
    local br2y= player.cbr.y + sin(player.angle - 0.25)*player_collsion_size
    local bl2x= player.cbl.x + cos(player.angle + 0.25)*player_collsion_size
    local bl2y= player.cbl.y + sin(player.angle + 0.25)*player_collsion_size

    --turn van
    if(player.speed != 0 and player_move) then
        player.rotation_speed=player.speed/max_speed
        if(player.speed>0) then
            if (btn(0) and (not is_solid(flx, fly)) and (not is_solid(fr2x, fr2y)) and (not is_solid(brx, bry)) and (not is_solid(bl2x, bl2y))) player.angle+=0.015*player.rotation_speed --left
            if (btn(1) and (not is_solid(frx, fry)) and (not is_solid(fl2x, fl2y)) and (not is_solid(blx, bly)) and (not is_solid(br2x, br2y))) player.angle-=0.015*player.rotation_speed --right
        elseif(player.speed<0) then
            if (btn(0) and (not is_solid(frx, fry)) and (not is_solid(fl2x, fl2y)) and (not is_solid(blx, bly)) and (not is_solid(br2x, br2y))) player.angle+=0.015*player.rotation_speed --left
            if (btn(1) and (not is_solid(flx, fly)) and (not is_solid(fr2x, fr2y)) and (not is_solid(brx, bry)) and (not is_solid(bl2x, bl2y))) player.angle-=0.015*player.rotation_speed --right
        end
        if(player.angle > 1) player.angle -=1
        if(player.angle < 0) player.angle +=1
    else
        local a = player.angle
        if(a>0.24 and a<0.26) player.angle = 0.25
        if(a>0.49 and a<0.51) player.angle = 0.5
        if(a>0.74 and a<0.76) player.angle = 0.75
        if(a>0.99 or a<0.01) player.angle = 0
    end

    update_collision_points()

    --move forward and backward
    if((btn(2) or btn(4)) and player.speed <= max_speed and player_move) then
        player.speed+=accel sfx(26)
    end
    if((btn(3) or btn(5)) and player.speed >= -max_speed and player_move) then
        player.speed-=accel sfx(26)
    end

    --apply drag
    if(player.speed > 0) player.speed-=drag
    if(player.speed < 0) player.speed+=drag

    --clamp speed and steering angle when speed low
    if(player.speed < min_speed and player.speed > -min_speed) player.speed=0 player.dir=player.angle-0.5 player.dirs[1]=player.angle-0.5 player.dirs[2]=player.angle-0.5 player.dirs[3]=player.angle-0.5

    --set drift delay frame amount
    if(player.speed < delay_threshold1*max_speed and player.speed > -delay_threshold1*max_speed) player.drift_delay = 1
    if((player.speed < delay_threshold2*max_speed and player.speed > delay_threshold1*max_speed) or (player.speed > -delay_threshold2*max_speed and player.speed < -delay_threshold1*max_speed)) player.drift_delay = 2
    if(check_car_speed(delay_threshold2*max_speed)) player.drift_delay = 3

    if(player.speed != 0) then
        --determine movement in x and y for front and back wheels
        fdx = player.speed * cos(player.angle + 0.5)
        fdy = player.speed * sin(player.angle + 0.5)
        bdx = player.speed * cos(player.dir)
        bdy = player.speed * sin(player.dir)

        --find wheel positions depending on speed sign
        player.fwheel.x = player.x + sgn(player.speed) * (wheel_dist/2 * cos(player.dir))
        player.fwheel.y = player.y + sgn(player.speed) * (wheel_dist/2 * sin(player.dir))
        player.bwheel.x = player.x - sgn(player.speed) * (wheel_dist/2 * cos(player.dir))
        player.bwheel.y = player.y - sgn(player.speed) * (wheel_dist/2 * sin(player.dir))
        
        if(not check_player_collision_points(solid_flag, fdx, fdy) and not check_player_collision_points(solid_flag, bdx, bdy)) then
            player.fwheel.x += fdx
            player.fwheel.y += fdy
            player.bwheel.x += bdx
            player.bwheel.y += bdy
            
            --update position
            player.x = (player.fwheel.x + player.bwheel.x)/2
            player.y = (player.fwheel.y + player.bwheel.y)/2
        else
            if(check_car_speed(0.5)) sfx(9)
            player.speed = 0
        end
        
        player.dir=player.dirs[1]
        player.dirs[player.drift_delay] = atan2(sgn(player.speed) * (player.fwheel.x - player.bwheel.x), sgn(player.speed) * (player.fwheel.y - player.bwheel.y))
    end
    for i=1, player.drift_delay - 1 do
        player.dirs[i] = player.dirs[i+1]
    end
    update_collision_points()
end

function check_car_speed(threshold)
    if(player.speed>threshold or player.speed<-threshold) return true
end

function check_player_collision_points(flag, dx, dy)
    dx=dx or 0
    dy=dy or 0
    for i=1,#player.collision_points do
        for j=1,#rendered_cars do
            local other=rendered_cars[j]
            if(other.dir==0 or other.dir==2) then --up or down
                if(not (player.collision_points[i].x + dx > other.x + other.w/2
                    or player.collision_points[i].y + dy > other.y + other.l/2
                    or player.collision_points[i].x + dx < other.x - other.w/2
                    or player.collision_points[i].y + dy < other.y - other.l/2)) then
                        create_collision(other)
                        return true
                    end
            else
                if(not (player.collision_points[i].x + dx > other.x + other.l/2
                    or player.collision_points[i].y + dy > other.y + other.w/2
                    or player.collision_points[i].x + dx < other.x - other.l/2
                    or player.collision_points[i].y + dy < other.y - other.l/2)) then
                        create_collision(other)
                        return true
                    end
            end
        end
        if(fget(mget((player.collision_points[i].x + dx)/8, (player.collision_points[i].y + dy)/8), flag)) return true
    end
    --if(fget(mget(player.x/8, player.y/8), flag)) return true
    return false
end

function update_collision_points()
    player.cfr.x = player.x - cos(player.angle)*player_length/2 - cos(player.angle - 0.25)*player_width/2
    player.cfr.y = player.y - sin(player.angle)*player_length/2 - sin(player.angle - 0.25)*player_width/2

    player.cfl.x = player.x - cos(player.angle)*player_length/2 - cos(player.angle + 0.25)*player_width/2
    player.cfl.y = player.y - sin(player.angle)*player_length/2 - sin(player.angle + 0.25)*player_width/2

    player.cbr.x = player.x + cos(player.angle)*player_length/2 + cos(player.angle + 0.25)*player_width/2
    player.cbr.y = player.y + sin(player.angle)*player_length/2 + sin(player.angle + 0.25)*player_width/2
    
    player.cbl.x = player.x + cos(player.angle)*player_length/2 + cos(player.angle - 0.25)*player_width/2
    player.cbl.y = player.y + sin(player.angle)*player_length/2 + sin(player.angle - 0.25)*player_width/2
end

function create_collision(other)
    if(player.speed>1.5) then 
        sfx(8)
    elseif(player.speed>0.5) then
        sfx(9)
    end
    other.colliding=true
    other.returning=false
    other.move=false
    local sgn = sgn(player.speed)
    local col_angle=atan2(sgn*(other.x - player.x), sgn*(other.y - player.y))
    other.dx=cos(col_angle)*collision_impulse*player.speed
    other.dy=sin(col_angle)*collision_impulse*player.speed
end

---------------- deliveries ----------------

function make_random_deliveries(n)
    local buildings_with_deliveries={}
    for i=1,n do
        local building = rnd(buildings)
        while(building.element == 'pizzeria' or contains(buildings_with_deliveries, building)) do
            building = rnd(buildings)
        end
        add(buildings_with_deliveries, building)
        if(building.orientation == 's') make_delivery(building.x, building.y+16)
        if(building.orientation == 'e') make_delivery(building.x+16, building.y)
        if(building.orientation == 'w') make_delivery(building.x-16, building.y)
        if(building.orientation == 'n') make_delivery(building.x, building.y-16)
    end
end

function make_delivery(x, y)
    local delivery={} delivery.x=x delivery.y=y delivery.time=delivery_time
    add(deliveries, delivery)
end

function draw_delivery_zones()
    foreach(deliveries, function (delivery)
        local x = world_to_screen_x(delivery.x) y = world_to_screen_y(delivery.y)
        rect(x, y, x+16, y+16, 8)
    end)
    if(#deliveries==0) then
        local x = world_to_screen_x(pizzeria.x) y = world_to_screen_y(pizzeria.y+16)
        rect(x, y, x+24, y+15, 8)
    end
end

function update_deliveries()
    local px = player.x py = player.y
    foreach(deliveries, function (delivery)
        local dx = delivery.x dy = delivery.y
        if(px > dx and px < dx + 15 and py > dy and py < dy + 15) then
            if(delivery.time>0) then
                sfx(0)
                delivery.time-=1
            elseif(delivery.time==0) then
                finish_delivery(delivery)
            end
        else
            if(delivery.time<delivery_time) delivery.time+=1 sfx(1)
        end
    end)
    if(#deliveries==0) then
        local dx = pizzeria.x dy = pizzeria.y+16
        if(px > dx and px < dx + 23 and py > dy and py < dy + 15) then
            if(pizzeria.time>0) then
                sfx(0)
                pizzeria.time-=1
            elseif(pizzeria.time==0) then
                make_random_deliveries(delivery_amount)
                pizzeria.time=delivery_time
            end
        else
            if(pizzeria.time<delivery_time) pizzeria.time+=1 sfx(1)
        end
    end
end

function finish_delivery(delivery)
    sfx(4)
    del(deliveries, delivery)
    display_added_score(delivery_points)
end

function draw_delivery_ui()
    foreach(deliveries, function (delivery)
        local x = world_to_screen_x(delivery.x) y = world_to_screen_y(delivery.y)
        if(delivery.time<delivery_time) then
            rect(x+2, y-6, x+14, y-2, 2)
            local filled=((delivery_time-delivery.time)/delivery_time)
            rectfill(x+3, y-5, x+3+(filled*10) , y-3, 8)
        end
        if(x<0 or x>128 or y<0 or y>128) then
            local angle=atan2(64-x, 64-y) dx=cos(angle) dy=sin(angle)
            while(x<0 or x>121 or y<0 or y>121) x+=dx y+=dy
            rspr(80,16,
                x, y,
                -angle + 0.25, 1)
        end
    end)
    if(#deliveries==0) then
        local x = world_to_screen_x(pizzeria.x) y = world_to_screen_y(pizzeria.y)
        if(pizzeria.time<delivery_time) then
            rect(x+6, y+22, x+18, y+18, 2)
            local filled=((delivery_time-pizzeria.time)/delivery_time)
            rectfill(x+7, y+21, x+7+(filled*10) , y+19, 8)
        end
        if(x<0 or x>128 or y<0 or y>128) then
            local angle=atan2(64-x, 64-y) dx=cos(angle) dy=sin(angle)
            while(x<0 or x>121 or y<0 or y>121) x+=dx y+=dy
            rspr(80,16,
                x, y,
                -angle + 0.25, 1)
        end
    end
end




---------------- npc's ----------------

function make_car(x, y, w, l, col1, col2, type)
    local car={} car.x=x car.y=y car.w=w car.l=l car.type=type car.dx=0 car.dy=0
    car.col1=col1 or car_default_color1 car.col2=col2 or car_default_color2
    local coords = find_nearest_road(car) car.x = coords[1] car.y = coords[2]
    find_car_dir(car) car.move=true car.turn_delay=car_total_turn_delay car.can_turn_delay=-1
    car.element='car'
    add(cars, car)
end

function draw_car(car)
    -- draw black pixels
    palt(0, false)
    -- don't draw transparent pixels
    palt(car_trans_color, true)

    local x = car.x y = car.y w = car.w/2 l = car.l/2 col1 = car.col1 col2 = car.col2

    --change palette to car colors
    pal(car_default_color1, car.col1)
    pal(car_default_color2, car.col2)

    --default is classic car, check type and set sprite coords accordingly
    local sx=classic_car_sprite_x sy=classic_car_sprite_y dist_x=(x - player.x)*car_distance_ratio dist_y=(y - player.y-render_y)*car_distance_ratio
    local rx = world_to_screen_x(x)
    local ry = world_to_screen_y(y)
    if(car.dir==0) then --down
        sy+=8
        for i=0,4 do
            sspr(sx, sy, 8, 16, rx - w, ry - l)
            rx+=dist_x ry+=dist_y
            sx+=8
        end
    elseif(car.dir==1) then --left
        for i=0,4 do
            sspr(sx, sy, 16, 8, rx - l, ry - w)
            rx+=dist_x ry+=dist_y
            sx+=16
        end
    elseif(car.dir==2) then --up
        sy+=8
        for i=0,4 do
            sspr(sx, sy, 8, 16, rx - w, ry - l, 8, 16, false, true)
            rx+=dist_x ry+=dist_y
            sx+=8
        end
    else --right
        for i=0,4 do
            sspr(sx, sy, 16, 8, rx - l, ry - w, 16, 8, true)
            rx+=dist_x ry+=dist_y
            sx+=16
        end
    end
    pal()
end

function find_nearest_road(car)
    local roadx=car.x
    local roady=car.y
    local dx=1 dy=1
    local newx=0 newy=0
    --find road
    for i=0,max_npc_road_dist do
        if(is_road(roadx+dx*8, roady+dy*8)) roadx=roadx+dx*8 roady=roady+dy*8 break
        if(is_road(roadx-dx*8, roady+dy*8)) roadx=roadx-dx*8 roady=roady+dy*8 break
        if(is_road(roadx-dx*8, roady-dy*8)) roadx=roadx-dx*8 roady=roady-dy*8 break
        if(is_road(roadx+dx*8, roady-dy*8)) roadx=roadx+dx*8 roady=roady-dy*8 break
        dx+=1 dy+=1
    end
    if(is_road(roadx+8, roady)) newx=flr((roadx+8)/8)*8
    if(is_road(roadx-8, roady)) newx=flr((roadx-8)/8)*8
    if(is_road(roadx, roady+8)) newy=flr((roady+8)/8)*8
    if(is_road(roadx, roady-8)) newy=flr((roady-8)/8)*8
    return {newx, newy}
end

function find_car_dir(car)
    if(car.move or car.returning) then
        if(is_pavement(car.x+9, car.y) and not is_pavement(car.x, car.y-9)) car.dir=2 return nil
        if(is_pavement(car.x-10, car.y) and not is_pavement(car.x, car.y+9)) car.dir=0 return nil
        if(is_pavement(car.x, car.y-9) and not is_pavement(car.x-9, car.y)) car.dir=1 return nil
        if(is_pavement(car.x, car.y+10) and not is_pavement(car.x+9, car.y)) car.dir=3 return nil
        car.turn_delay-=1
        if(car.turn_delay==0) then
            car.turn_delay=car_total_turn_delay
            car.dir+=1
            if(car.dir>3) car.dir=0
            car.can_turn_delay=car_total_turn_delay
        end
    elseif(car.colliding) then
        local dx=car.objective[1] - car.x
        local dy = car.objective[2] - car.y
        if(dx<0 and dx>dy) car.dir=1
        if(dy<0 and dy>dx) car.dir=0
        if(dx>0 and dx>dy) car.dir=3
        if(dy>0 and dy>dx) car.dir=2
    end 
end

function update_car(car)
    if(car.move) then
        if(car.can_turn_delay>0) then
            car.can_turn_delay-=1
        else
            find_car_dir(car)
        end
        if(not(check_player_position(car))) then
            if(car.dir==0) car.y+=car_speed
            if(car.dir==2) car.y-=car_speed
            if(car.dir==1) car.x-=car_speed
            if(car.dir==3) car.x+=car_speed
        end
    elseif(car.colliding) then
        if(not is_solid(car.x+car.w/2+car.dx, car.y) and not is_solid(car.x-car.w/2+car.dx, car.y))car.x+=car.dx
        if(not is_solid(car.x, car.y+car.w/2+car.dy) and not is_solid(car.x, car.y-car.w/2+car.dy))car.y+=car.dy
        if(car.dx>0) car.dx-=car_drag
        if(car.dx<0) car.dx+=car_drag
        if(car.dy>0) car.dy-=car_drag
        if(car.dy<0) car.dy+=car_drag
        if((car.dx<min_car_speed and car.dx>0) or (car.dx> - min_car_speed and car.dx<0)) car.dx=0
        if((car.dy<min_car_speed and car.dy>0) or (car.dy> - min_car_speed and car.dy<0)) car.dy=0
        if(car.dx==0 and car.dy==0) then
            car.colliding=false
            car.returning=true
            car.move=false
            car.objective=find_nearest_road(car)
            car.original_position={}
            car.original_position.x=car.x
            car.original_position.y=car.y
            car.returning_t=0
            find_car_dir(car)
        end
    elseif(car.returning) then
        if(distance(car.x, player.x, car.y, player.y) > 20 and not check_other_cars(car)) then
            car.x=lerp(car.original_position.x, car.objective[1], car.returning_t)
            car.y=lerp(car.original_position.y, car.objective[2], car.returning_t)
            car.returning_t+=0.05
        end
        if(car.returning_t>=1) then
            car.x = car.objective[1]
            car.y = car.objective[2]
            car.colliding=false
            car.returning=false
            car.move=true
            find_car_dir(car)
        end
    end
end

function check_player_position(car)
    if(car.dir==0) then
        if(player.x < car.x - 10 or player.x > car.x + 10 or player.y < car.y or player.y > car.y + 20) return false
        return true
    elseif(car.dir==1) then
        if(player.x < car.x - 20 or player.x > car.x or player.y < car.y -10 or player.y > car.y + 10) return false
        return true
    elseif(car.dir==2) then
        if(player.x < car.x - 10 or player.x > car.x + 10 or player.y < car.y - 20 or player.y > car.y) return false
        return true
    else
        if(player.x < car.x or player.x > car.x + 20 or player.y < car.y -10 or player.y > car.y + 10) return false
        return true
    end
end

function check_other_cars(car)
    local x1=0 x2=20 y1=-10 y2=10
    if(car.dir==0) x1=-10 x2=10 y2=20
    if(car.dir==1) x1=-20 y1=-10 y2=10
    if(car.dir==2) x1=-10 x2=10 y1=-20
    for i=1,#rendered_cars do
        local other = rendered_cars[i]
        if(other.x < car.x + x1 or other.x > car.x + x2 or other.y < car.y + y1 or other.y > car.y + y2) return false
    end
    return true
end

function update_cars()
    foreach(cars, function (car)
        update_car(car)
    end)
end


---------------- sprite stacking ----------------

function draw_van(x,y,a)
    for i=0,12 do
    local sx = 16 * (i%8)
    local sy = 16 * flr(i/8)
    rspr(sx,sy,
        x, y-i*1,
        a, 2)
    end
end

function rspr(sx,sy,x,y,a,w)
	local ca,sa=cos(a),sin(a)
	local srcx,srcy
	local ddx0,ddy0=ca,sa
	local mask=shl(0xfff8,(w-1))
	w*=4
	ca*=w-0.5
	sa*=w-0.5
	local dx0,dy0=sa-ca+w,-ca-sa+w
	w=2*w-1
	for ix=0,w do
		srcx,srcy=dx0,dy0
		for iy=0,w do
			if band(bor(srcx,srcy),mask)==0 then
				local c=sget(sx+srcx,sy+srcy)
    -- set transparent color here
				if (c!=11) pset(x+ix,y+iy,c)
			end
			srcx-=ddy0
			srcy+=ddx0
		end
		dx0+=ddx0
		dy0+=ddy0
	end
end



---------------- buildings ----------------

function make_building(x, y, w, l, h, col1, col2, col3, door, orientation, style)
    local building={}
    building.x=x building.y=y building.w=w building.l=l building.h=h
    building.col1=col1 building.col2=col2 building.col3=col3
    building.door=door building.orientation=orientation building.style=style
    building.element='building'
    add(buildings, building)
end

function draw_elements()
    foreach(rendered_elements, function(element)
        if(element.element=='player') draw_van(64 - player_length/2, 64 - player_width/2, -player.angle)
        if(element.element=='car') draw_car(element)
        if(element.element=='building') draw_building(element)
    end)
end

function draw_building(building)
    local w=building.w local l=building.l local h=building.h local x=building.x+w/2 local y=building.y+l/2
    local col1=building.col1 local col2=building.col2 local col3=building.col3
    local door=building.door local orientation=building.orientation local style=building.style
    local dist_x=(x - player.x)*building_distance_ratio
    local dist_y=(y - player.y-render_y)*building_distance_ratio
    local rx = world_to_screen_x(x-w/2)
    local ry = world_to_screen_y(y-l/2)

    --bottom floor
    if(style=='residential' or style=='house') then
        local j = 0
        while(j < 2) do
            rectfill(rx, ry, rx + w, ry + l, col1)
            draw_door(rx, ry, w, l, orientation, col3, true)
            rx+=dist_x ry+=dist_y
            j+=1
        end
        rectfill(rx, ry, rx + w, ry + l, col1)
        rx+=dist_x ry+=dist_y
    elseif(style=='store') then
        rectfill(rx, ry, rx + w, ry + l, col1)
        draw_door(rx, ry, w, l, orientation, col3, false)
        rx+=dist_x ry+=dist_y
        rectfill(rx, ry, rx + w, ry + l, col1)
        draw_door(rx, ry, w, l, orientation, col3, false)
        if(orientation=='n') rectfill(rx+7, ry, rx + w-2, ry+2, col3) rx+=dist_x ry+=dist_y rectfill(rx, ry, rx + w, ry + l, col1) rectfill(rx+7, ry, rx + w-2, ry+1, col3)
        if(orientation=='s') rectfill(rx+7, ry+l, rx + w-2, ry+l-2, col3) rx+=dist_x ry+=dist_y rectfill(rx, ry, rx + w, ry + l, col1) rectfill(rx+7, ry+l, rx + w-2, ry+l-1, col3)
        if(orientation=='w') rectfill(rx, ry+7, rx+2, ry + l -2, col3) rx+=dist_x ry+=dist_y rectfill(rx, ry, rx + w, ry + l, col1) rectfill(rx, ry+7, rx+1, ry + l -2, col3)
        if(orientation=='e') rectfill(rx+w, ry+7, rx+w-2, ry + l -2, col3) rx+=dist_x ry+=dist_y rectfill(rx, ry, rx + w, ry + l, col1) rectfill(rx+w, ry+7, rx+w-1, ry + l -2, col3)
        rx+=dist_x ry+=dist_y
        rectfill(rx, ry, rx + w, ry + l, col1)
        rx+=dist_x ry+=dist_y
    end
    
    --other floors
    for i=1,h do
        rectfill(rx, ry, rx + w, ry + l, col1)
        draw_windows(rx, ry, w, l, orientation, col3, 6, 3)
        rx+=dist_x ry+=dist_y
        rectfill(rx, ry, rx + w, ry + l, col1)
        if(style=='glass') then
            local j = 0
            while(j < 2) do
                draw_windows(rx, ry, w, l, orientation, col3, 6, 3) rx+=dist_x ry+=dist_y
                rectfill(rx, ry, rx + w, ry + l, col1)
                j+=1
            end
        end
        rx+=dist_x ry+=dist_y
    end

    --roof
    if(style=='house') then
        local roof_h = min(w, l)
        roof_h/=2
        for i=0,roof_h do
            rectfill(rx+i, ry+i, rx + w - i, ry + l - i, col2)
            rx+=dist_x ry+=dist_y
        end
    else
        rectfill(rx + 3, ry + 3, rx + w - 3, ry + l - 3, col2)
        local j = 0
        while(j < 2) do
            rect(rx, ry, rx + w, ry + l, col1)
            rect(rx + 1, ry + 1, rx + w - 1, ry + l - 1, col1)
            rect(rx + 2, ry + 2, rx + w - 2, ry + l - 2, col1)
            rx+=dist_x ry+=dist_y
            j+=1
        end
    end
end

function draw_door(x, y, w, l, orientation, col, middle)
    local door_x = x + 3
    if(middle) door_x = (x + x + w)/2
    local door_y = y + 3
    if(middle) door_y = (y + y + l)/2
    if(orientation == 'n') then
        rectfill(door_x-1, y, door_x+1, y + 2, col)
    elseif(orientation == 's') then
        rectfill(door_x-1, y + l, door_x+1, y + l - 2, col)
    elseif(orientation == 'w') then
        rectfill(x, door_y-1, x + 2, door_y+1, col)
    elseif(orientation == 'e') then
        rectfill(x + w, door_y-1, x + w - 2, door_y+1, col)
    end
end

function draw_windows(x, y, w, l, orientation, col, wind_sep, wind_w)
    if(orientation == 'n') local n = w/wind_sep x+=wind_sep/wind_w for i=0,n-1 do rectfill(x+i*wind_sep, y, x+i*wind_sep+wind_w, y+2, col) end
    if(orientation == 's') local n = w/wind_sep x+=wind_sep/wind_w for i=0,n-1 do rectfill(x+i*wind_sep, y+l, x+i*wind_sep+wind_w, y+l-2, col) end
    if(orientation == 'w') local n = l/wind_sep y+=wind_sep/wind_w for i=0,n-1 do rectfill(x, y+i*wind_sep, x+2, y+i*wind_sep+wind_w, col) end
    if(orientation == 'e') local n = l/wind_sep y+=wind_sep/wind_w for i=0,n-1 do rectfill(x+w, y+i*wind_sep, x+w-2, y+i*wind_sep+wind_w, col) end
end

function sort_elements()
    qsort(rendered_elements, render_dist_comparator)
end

function update_rendered_elements()
    rendered_elements={}
    rendered_cars={}
    add(rendered_elements, player)
    foreach(buildings, function(building)
        if(is_on_screen(building)) add(rendered_elements, building)
    end)
    foreach(cars, function(car)
        if(dist_player(car) < render_distance) then
            add(rendered_elements, car)
            add(rendered_cars, car)
        end
    end)
    if(dist_player(pizzeria) < render_distance) add(rendered_elements, pizzeria)
end

function make_pizzeria(x, y, orientation)
    pizzeria={} pizzeria.x=x pizzeria.y=y pizzeria.orientation=orientation pizzeria.element='pizzeria' pizzeria.time=delivery_time
    make_building(x, y, 24, 16, 2, 8, 13, 7, true, 's', 'store')
end







---------------- utils ----------------

function is_solid(x, y)
    if(fget(mget(x/8, y/8), solid_flag)) return true
end

function is_pavement(x,y)
    if(fget(mget(x/8, y/8), pavement_flag)) return true
end

function is_road(x, y)
    if(fget(mget(x/8, y/8), road_flag)) return true
end

function distance(x1,x2,y1,y2)
    return sqrt((x1-x2)^2 + (y1-y2)^2)
end

function world_to_screen_x(x)
    return 64 - player.x + x
end

function world_to_screen_y(y)
    return 64 - player.y + y
end

function render_dist_comparator(a,b)
	return render_dist_player(a) > render_dist_player(b)
end

function render_dist_player(a)
	return distance(player.x,a.x,player.y+render_y+5,a.y)
end

function dist_comparator(a,b)
	return dist_player(a) > dist_player(b)
end

function dist_player(a)
	return distance(player.x,a.x,player.y,a.y)
end

function is_on_screen(e)
    local sx= world_to_screen_x(e.x) sy = world_to_screen_y(e.y)
    if(sx > -32 and sx<128 and sy>-24 and sy < 128) return true
    return false
end

function contains(t, a)
    for i=1,#t do
        if(t[i]==a) return true
    end
    return false
end

function lerp(a, b, t)
    return a + (b-a) * t
end

function easeinquad(t)
    return t*t
end

function easeoutquad(t)
    t-=1
    return 1-t*t
end

function quad_in_lerp(a, b, t)
    return a + (b-a) * easeinquad(t)
end

function quad_out_lerp(a, b, t)
    if(t>0.95) return b
    return a + (b-a) * easeoutquad(t)
end

function easeOutBounce(t)
    local n1=7.5625
    local d1=2.75

    if (t<1/d1) then
        return n1*t*t;
    elseif(t<2/d1) then
        t-=1.5/d1
        return n1*t*t+.75;
    elseif(t<2.5/d1) then
        t-=2.25/d1
        return n1*t*t+.9375;
    else
        t-=2.625/d1
        return n1*t*t+.984375;
    end
end

function bounce_lerp(a, b, t)
    if(t>0.9) return b
    return a + (b-a) * easeOutBounce(t)
end

function easeOutBack(t)
    t-=1
    return 1+2.7*t*t*t+1.7*t*t
end

function overshoot_lerp(a, b, t)
    return a + (b-a) * easeOutBack(t)
end

function p4bonus(s,x,y,c,o) -- 34 tokens, 5.7 seconds
    color(o)
    ?'\-f'..s..'\^g\-h'..s..'\^g\|f'..s..'\^g\|h'..s,x,y
    ?s,x,y,c
end

--sorting algorithm
function qsort(a,c,l,r)
	c,l,r=c or function(a,b) return a<b end,l or 1,r or #a
	if l<r then
		if c(a[r],a[l]) then
			a[l],a[r]=a[r],a[l]
		end
		local lp,k,rp,p,q=l+1,l+1,r-1,a[l],a[r]
		while k<=rp do
			local swaplp=c(a[k],p)
			-- "if a or b then else"
			-- saves a token versus
			-- "if not (a or b) then"
			if swaplp or c(a[k],q) then
			else
				while c(q,a[rp]) and k<rp do
					rp-=1
				end
				a[k],a[rp],swaplp=a[rp],a[k],c(a[rp],p)
				rp-=1
			end
			if swaplp then
				a[k],a[lp]=a[lp],a[k]
				lp+=1
			end
			k+=1
		end
		lp-=1
		rp+=1
		-- sometimes lp==rp, so 
		-- these two lines *must*
		-- occur in sequence;
		-- don't combine them to
		-- save a token!
		a[l],a[lp]=a[lp],a[l]
		a[r],a[rp]=a[rp],a[r]
		qsort(a,c,l,lp-1       )
		qsort(a,c,  lp+1,rp-1  )
		qsort(a,c,       rp+1,r)
	end
end

function make_houses(houses, dir)
    if(dir=='n' or dir=='s') w=20 l=16
    if(dir=='w' or dir=='e') w=16 l=20
    foreach(houses, function (house)
        make_building(house[1]*8, house[2]*8, w, l, rnd({1, 2}), rnd(building_colors), 13, rnd({13, 7}), true, dir, 'house')
    end)
end

function make_buildings()
    
    make_pizzeria(63*8, 17*8, 's')

    make_houses(n_houses, 'n')
    make_houses(s_houses, 's')
    make_houses(w_houses, 'w')
    make_houses(e_houses, 'e')

    foreach(x_delivery_lanes, function (lane)
        local bx=lane[1]*8 bx_max=lane[2]*8+8 by=lane[3]*8
        if(lane[4]=='s') by-=16
        if(lane[4]=='n') by+=16 bx+=16 bx_max-=16
        while(bx<=bx_max-40) do
            local w = rnd({16, 24})
            --(x, y, w, l, h, col1, col2, col3, door, orientation, style)
            make_random_building_not_title(bx, by, w, 16, lane[4])
            --make_building(bx, by, w, 16, building_min_height + flr(rnd(building_max_height-building_min_height)), rnd(building_colors), 13, rnd({13, 7}), true, lane[4], rnd(building_styles))
            bx+=w
        end
        make_random_building_not_title(bx, by, bx_max-bx, 16, lane[4])
        --make_building(bx, by, bx_max-bx, 16, building_min_height + flr(rnd(building_max_height-building_min_height)), rnd(building_colors), 13, rnd({13, 7}), true, lane[4], rnd(building_styles))
    end)
    foreach(y_delivery_lanes, function (lane)
        local by=lane[1]*8 by_max=lane[2]*8-8 bx=lane[3]*8
        if(lane[4]=='e') bx-=16
        if(lane[4]=='w') bx+=16
        while(by<=by_max-40) do
            local w = rnd({16, 24})
            --(x, y, w, l, h, col1, col2, col3, door, orientation, style)
            make_random_building_not_title(bx, by, 16, w, lane[4])
            --make_building(bx, by, 16, w, building_min_height + flr(rnd(building_max_height-building_min_height)), rnd(building_colors), 13, rnd({13, 7}), true, lane[4], rnd(building_styles))
            by+=w
        end
        make_random_building_not_title(bx, by, 16, by_max-by, lane[4])
        --make_building(bx, by, 16, by_max-by, building_min_height + flr(rnd(building_max_height-building_min_height)), rnd(building_colors), 13, rnd({13, 7}), true, lane[4], rnd(building_styles))
    end)
end

function make_random_building_not_title(bx, by, w, l, dir)
    make_building(bx, by, w, l, building_min_height + flr(rnd(building_max_height-building_min_height)), rnd(building_colors), 13, rnd({13, 7}), true, dir, rnd(building_styles))
end

function make_cars()
    --(x, y, w, l, col1, col2, type)
    foreach(cars_coords, function (car)
        make_car(car[1]*8, car[2]*8, 8, 16, rnd(car_colors))
    end)
end

function save_highscore()
    dset(0, highscore)
end

function get_highscore()
    highscore = dget(0)
end


---------------- game state functions ----------------

---------------- game screen ----------------

function init_classic()
    sort=false
    started=false
    counter=90
    timer=false
    transition=1
    render_y=25
    reset_map()
    player_move=true
    deliveries={}
    make_random_deliveries(delivery_amount)
    coroutines={}

    score=0
    time_left=classic_total_time

    _update=update_classic
    _draw=draw_classic
end

function update_classic()
    --if(btnp(5)) time_left=2
    update_cars()
    if(started)update_player(player)
    update_rendered_elements()
    sort_elements()
    update_deliveries()
    if(transition>0) transition-=transition_speed
    if(transition<=0 and not started) timer=true
    if(counter%30==0 and counter!=0 and timer) sfx(5)
    if(timer and not started) counter-=1
    if(counter==0 and not started) sfx(6)
    if(counter <= 0 and not started) timer=false started=true music(0)
    if(started and time_left>0)time_left-=1/30
    if(time_left<=0) score+=#coroutines*10 init_game_end()
end

function draw_classic()
    cls(3)
    map(player.x/8 - 8, player.y/8 - 8, -player.x%8 - 8, -player.y%8 - 8, 17, 17)
    draw_delivery_zones()
    draw_elements()
    draw_ui()
    if(timer) print_text("\^w \^t"..flr(counter/30) + 1, 54, 48, 10)
    foreach(coroutines, function (cor)
        if(costatus(cor) != 'dead') then 
            coresume(cor)
        else 
            del(coroutines, cor)
        end
    end)

    transition_before(transition)
    --print(stat(1), 0, 0, 7)
end

function draw_ui()
    draw_delivery_ui()

    --time
    local m = flr(time_left/60)
    local s = flr(time_left-(m*60))
    print("tIME", 3, 3, 0)
    local x = print("tIME", 2, 2, 10) + 2
    print(m.."'", x+1, 3, 0)
    local x1 = print(m.."'", x, 2, 10)
    print(s..'"', x1+1, 3, 0)
    print(s..'"', x1, 2, 10)

    --score
    local x = 104-#tostring(score)*4
    print("sCORE", x+1, 3, 0)
    local x1 = print("sCORE", x, 2, 10) +2
    print(score, x1+1, 3, 0)
    print(score, x1, 2, 10)
end

function display_added_score(added)
    local cor = cocreate( function ()
        local dist=122-(#tostring(added)*4)
        local x = 128
        local y = 10
        for i=0,5 do
            print_score(added, x, y)
            x-=(128-dist)/6
            yield()
        end
        for i=0,50 do
            print_score(added, x, y)
            yield()
        end
        for i=0,7 do
            print_score(added, x, y)
            y-=1
            yield()
        end
        score+=delivery_points
    end)
    add(coroutines, cor)
end

function print_score(added, x, y)
    print("+"..added, x+1, y+1, 0)
    print("+"..added, x, y, 10)
end

function _init()
    cartdata("codenamewaddles_pizzapanic_1")
    get_highscore()
    reset_map()
    init_title()
end




---------------- title screen ----------------

function init_title()
    next=false
    start_next=false
    final_move_x=0
    pizza_x_end=37
    pizza_x=-16
    title_counter=0
    title_counter1=0
    title_counter2=0
    title_y=-35
    title_y_end=15
    title_graphics_y=128
    title_speed=1
    x1=-80 x2=0 x3=80
    pa=0 pa1=0.25
    player=make_player()
    render_y=45
    player.x = 56
    player.y = 98
    buildings={}
    init_title_buildings()
    _update=update_title
    _draw=draw_title
end

function update_title()
    if(title_counter<1) title_counter+=0.013
    if(title_counter>=1 and title_counter1 < 1) title_counter1+=0.015
    if(title_counter1 > 0 and title_counter1 < 0.55) pa+=0.013
    if(title_counter1 > 0.6 and title_counter1 < 0.9) pa-=0.013
    if(start_next and title_counter2 < 1) title_counter2+=0.05
    if(title_counter2>=1) next=true
    final_move_x = quad_in_lerp(0, 128, title_counter2)
    title_y=bounce_lerp(-35, title_y_end, title_counter)
    pizza_x=overshoot_lerp(-16, pizza_x_end, title_counter1) + final_move_x
    update_menu_world()
    if(btnp(4) and title_counter1 >= 1) start_next = true 
    if(next) init_menu(false)
end

function draw_title()
    draw_menu_world()
    local x = 20 + final_move_x

    rspr(88, 16, pizza_x, 29, pa, 2)

    p4bonus("\^w \^t pizza", x, title_y+2, 7, 7)
    p4bonus("\^w \^t pizza", x, title_y+1, 7, 7)
    p4bonus("\^w \^t panic", x+20, title_y+17, 7, 7)
    p4bonus("\^w \^t panic", x+20, title_y+16, 7, 7)
    display_title(x, title_y+2, 8)
    display_title(x, title_y+1, 3)
end

function display_title(x, y, col)
    ?"\^w \^t pizza", x, y, col
    ?"\^w \^t panic", x+20, y+15, col
end

function init_title_buildings()
    local x=-24
    while x < 120 do
        local w = rnd({16, 24})
        make_random_building(x, w)
        x+=w
    end
    if(x<136) make_random_building(x, 136-x)
end

function make_random_building(x, w)
    make_building(x, title_graphics_y+40, w, 16, building_min_height + flr(rnd(building_max_height-building_min_height)), rnd(building_colors), 13, rnd({13, 7}), true, 's', rnd(building_styles))
end

function update_menu_world()
    if(title_graphics_y > 64) title_graphics_y-=title_speed
    foreach(buildings, function (building)
        building.x+=car_speed
        if(title_graphics_y > 64) building.y-=title_speed
        if(building.x>128) make_random_building(-32, building.w) del(buildings, building)
    end)
    qsort(buildings, render_dist_comparator)
end

function draw_menu_world()
    cls(12)
    x1+=car_speed
    x2+=car_speed
    x3+=car_speed
    if(x1>=128)x1=-80
    if(x2>=128)x2=-80
    if(x3>=128)x3=-80
    map(60, 0, x1, title_graphics_y+16, 10, 8)
    map(60, 0, x2, title_graphics_y+16, 10, 8)
    map(60, 0, x3, title_graphics_y+16, 14, 8)

    foreach(buildings, function (building)
        draw_building(building)
    end)

    draw_van(56, title_graphics_y+34, 0)
end

---------------- menu screen ----------------

function init_menu(b)
    text_x=-128
    menu_counter=0
    before=b
    next=false
    if(before) buildings={} init_title_buildings() render_y=45 player.x = 56 player.y = 98 x1=-80 x2=0 x3=80
    transition=1
    transition1=0
    _update=update_menu
    _draw=draw_menu
end

function update_menu()
    update_menu_world()
    if(btnp(4) and not before and text_x==6 and not next) next=true sfx(2)
    if(menu_counter < 1) menu_counter+=0.025
    if(before) transition-=transition_speed menu_counter=1
    if(transition<=0) before=false
    text_x=quad_out_lerp(-128, 6, menu_counter)
    if(next) transition1+=transition_speed
    if(transition1>=1) init_classic()
end

function draw_menu()
    draw_menu_world()
    print_text("fOLLOW THE ARROWS AND DELIVER\nAS MANY PIZZAS AS POSSIBLE\nBEFORE TIME RUNS OUT\n\ncURRENT HIGHSCORE : "..highscore.."\n\n      pRESS 🅾️ TO START", text_x, 6, 7)
    if(before) transition_before(transition)
    if(next) rectfill(0, 0, 128, 128*transition1, 0)
end

function print_text(s, x, y, col)
    ?s, x+1, y+1, 0
    ?s, x, y, col
end

function transition_before(t)
    rectfill(0, 128, 128, 128 - 128*t, 0)
end


---------------- game end screen ----------------

function init_game_end()
    sfx(10)
    new = false
    if(score>highscore) highscore=score save_highscore() new = true
    display_score=30
    display_highscore=60
    player_move=false
    transition=0
    next=false
    _update=update_game_end
    _draw=draw_game_end
end

function update_game_end()
    update_world()
    if(display_score>0) display_score-=1
    if(display_highscore>0) display_highscore-=1
    if(btnp(4) and not next) next=true sfx(2)
    if(next) transition+=transition_speed
    if(transition>=1) reset_map() init_menu(true)
end

function draw_game_end()
    draw_map_elements()
    print_text("\^w \^ttime's up!", 20, 35, 10)
    if(display_score<=0) print_text("score : "..score, 45, 55, 10)
    if(display_highscore<=0 and new) print_text("new highscore!", 35, 75, 10)
    if(next) rectfill(0, 0, 128, 128*transition, 0)
end

function reset_map()
    player=make_player()
    buildings={}
    cars={}
    rendered_cars={}
    make_buildings()
    make_cars()
end

function draw_map_elements()
    cls()
    map(player.x/8 - 8, player.y/8 - 8, -player.x%8 - 8, -player.y%8 - 8, 17, 17)
    draw_elements()
end

function update_world()
    update_rendered_elements()
    update_cars()
    if(started)update_player(player)
    sort_elements()
end


__gfx__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
22b00b22222b00b6880000888770000788800887777700778888877777777777bb88777777777773bbb8ddd777777333bbb7ddd777733333bbb77dd773333333
2822222222266666888882222266666d8bbbbbbbbbbbbbb58888bbbbbbbbbbbdbb88bbbbbbbbbbb5bbbddbbbbbbbbbbdbbbdbbbbbbbbbbb5bbbdbbbbbbbbbbb3
1888882222266661888882222266666d8bbbbbbbbbbbbbb58888bbbbbbbbbbbdbb88bbbbbbbbbbb5bbbddbbbbbbbbbbdbbbdbbbbbbbbbbb5bbbdbbbbbbbbbbb3
1888882222266661888882222266666d8bbbbbbbbbbbbbb58888bbbbbbbbbbbdbb88bbbbbbbbbbb5bbbddbbbbbbbbbbdbbbdbbbbbbbbbbb5bbbdbbbbbbbbbbb3
1888882222266661888882222266666d8bbbbbbbbbbbbbb58888bbbbbbbbbbbdbb88bbbbbbbbbbb5bbbddbbbbbbbbbbdbbbdbbbbbbbbbbb5bbbdbbbbbbbbbbb3
1888882222266661888882222266666d8bbbbbbbbbbbbbb58888bbbbbbbbbbbdbb88bbbbbbbbbbb5bbbddbbbbbbbbbbdbbbdbbbbbbbbbbb5bbbdbbbbbbbbbbb3
2822222222266666888882222266666d8bbbbbbbbbbbbbb58888bbbbbbbbbbbdbb88bbbbbbbbbbb5bbbddbbbbbbbbbbdbbbdbbbbbbbbbbb5bbbdbbbbbbbbbbb3
22b00b22222b00b6880000888770000788800887777700778888877777777777bb88777777777773bbb8ddd777777333bbb7ddd777733333bbb77dd773333333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbffffffbbbbb66666666cccccccc00000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222228bbbbffffffffffbbb66666666cccccccc00000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb22222288bbfff888888fffbb66666666cccccccc00000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222288bbfff87788338fffb666dd666cccccccc00000000
bbb7777333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2288bbbff8877807788ffb666dd666cccccccc00000000
bbb7777333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb28bbbff888888888888ff66666666cccccccc00000000
bbb7777333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbff880888888838ff66666666cccccccc00000000
bbb7777333333333bbbbbf8488488fbbbbbbbff84884ffbbbbbbbbff884ffbbbbbbbbbbfffffbbbbbbbbbbbbff878887780773ff66666666cccccccc00000000
bbb7777333333333bbbbbf8488848fbbbbbbbff88488ffbbbbbbbbff488ffbbbbbbbbbbfffffbbbb33333333ff873877888778ff6666aaaaaaaaaaaaaaaacacc
bbb7777333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333ff838888888888ff666a6aaaaaaaaaaaaaaaaccc
bbb7777333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333ff888880883888ff6666aaaaaaaaaaaaaaaacacc
bbb7777333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bff8878887738ffb666a6aaaaaaaaaaaaaaaaccc
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bfff87788878fffb6666aaaaaaaaaaaaaaaacacc
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bbfff888888fffbb666a6aaaaaaaaaaaaaaaaccc
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bbbffffffffffbbb6666aaaaaaaaaaaaaaaacacc
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333bbbbbffffffbbbbb666a6aaaaaaaaaaaaaaaaccc
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555556666666666666656666666666666666
55555555555775555555555555577555555555555555555555577555555775555555555555577555555775555557755566666666666666666666666666666666
55555555555775555555555555577555555555555555555555577555555775555555555555577555555775555557755566666666666666666666666666666666
55555555555775555777777557777555577775555557777555577775577777755777777555577775577777755777755566666666666666666666666666666666
55555555555775555777777557777555577775555557777555577775577777755777777555577775577777755777755566666666666666666666666666666666
55555555555775555555555555555555555775555557755555555555555775555557755555577555555555555557755566666666666666666666666666666666
55555555555775555555555555555555555775555557755555555555555775555557755555577555555555555557755566666666666666666666666666666666
5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555556666666666666666666666666ddddddd
44440044444004444ccc00ccccc00cc444ccccccccccccc44444ccddcddcc44444444ccccccc4444555777777777755566666666666666666666666666666666
4444444444444444cccccccccccccccc44cccccccccccccc4444ddccccccc44444444ccccccc4444555555555555555566666666666666666666666666666666
4444444444444444cccccccccccccccc44cccccccccccccc4444ddcccccdd44444444ccccccc4444555555555555555566666666666666666666666666666666
4444444444444444cccccccccccccccc44cccccccccccccc4444ddcccccdd44444444ccccccc4444555555555555555566666666666666666666666666666666
4444444444444444cccccccccccccccc44cccccccccccccc4444ddcccccdd44444444ccccccc4444555555555555555566666666666666666666666666666666
4444444444444444cccccccccccccccc44cccccccccccccc4444ddcccccdd44444444ccccccc4444555555555555555566666666666666666666666666666666
4444444444444444cccccccccccccccc44cccccccccccccc4444ddccccccc44444444ccccccc44445555555555555555d6666666666666666666666d66666666
44440044444004444ccc00ccccc00cc444ccccccccccccc44444ccddcddcc44444444ccccccc444455555555555555555dddddddddddddddddddddd5ddddddd6
444444444cccccc44cccccc444444444444444440000000000000000000000000000000000000000555555553333333333344333333333333334433366666666
44444444cccccccccccccccc444444444444444400000000000000000000000000000000000000005555555533bb333333344333333333333334433366666666
44444444cccccccccccccccc444444444444444400000000000000000000000000000000000000005555555533bb333333344333333333333334433366666666
044444400cccccc0ccccccccccddddcc4444444400000000000000000000000000000000000000005555555533333bb344444333333344443334433366666666
044444400cccccc0ccccccccccddddcccccccccc00000000000000000000000000000000000000005555555533333bb344443333333444443334433366666666
44444444ccccccccccccccccdccccccdcccccccc0000000000000000000000000000000000000000555555553bb3333333333333333443333334433366666666
44444444ccccccccccccccccdccccccdcccccccc0000000000000000000000000000000000000000555555553bb3333333333333333443333334433366666666
44444444cccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000555555553333333333333333333443333334433366666666
44444444ccccccccccccccccdccccccdcccccccc0000000000000000000000000000000000000000000000003334433333344333333333333333333333383333
44444444ccccccccccccccccdccccccdcccccccc00000000000000000000000000000000000000000000000033344333333443333333333333333333338a8333
044444400cccccc0cccccccccddddddccccccccc00000000000000000000000000000000000000000000000033344333333443333333333333333333333833a3
044444400cccccc0cccccccccddddddc444444440000000000000000000000000000000000000000000000004444444433344444444433334444444433333a9a
44444444cccccccccccccccc44444444444444440000000000000000000000000000000000000000000000004444444433334444444443334444444433e333a3
44444444cccccccccccccccc4444444444444444000000000000000000000000000000000000000000000000333333333333333333344333333333333eae3333
44444444cccccccc4444444444444444444444440000000000000000000000000000000000000000000000003333333333333333333443333333333333e33333
444444444cccccc44444444444444444444444440000000000000000000000000000000000000000000000003333333333333333333443333333333333333333
a3a3a3a3a3a3a3a3a3e4f604046424242424248424242424242424242424242424242424242424b40404f6e4e4b5a5f6f6b5a5e4e4f60404140404f6e4e4e4e4
e4e4e4e4d20404140404c5d5d5d5d5d5e50404140404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3e4f604040404040404041404040424040404040404040404040424040404140404f6e4e4b5a5f6f6b5a5e4e4f60404140404f6e4e4e4e4
e4e4e4e4f60404140404042404040404040404140404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3e4f604040404040404041404040424040404040404040404040424040404140404d2e4e4b5a5f6f6b5a5e4e4f60404140404f6e4e4e4e4
e4e4e4e4f60404140404042404040404040404140404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3e4f6f6f6f6f6f6d40404140404c4f6f6f6f6f6f6f6f6f6f6f6e4e4d40404140404f6e4e4b5a5f6f6b5a5c5d5e51414141414f6e4e4e4e4
e4e4e4e4f60404942424242424242424242424340404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3f7a3a3e4e4e4e4e4e4e4f61414141414f6e4e4e4e4e4e4e4e4e4e4e4e4e4f60404140404f6e4e4b5a5c5e5b5040404a60404140404f6e4e4e4e4
e4e4e4e4f60404140404042404040404040404040404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3e4e4f60404140404f6e4e4b504040404040404a60404140404d2e4e4e4e4
e4e4e4e4f60404140404042404040404040404040404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3f7a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3e4e4f60404140404f6e4e4e4e4e4e4e4e4e4e4d40404140404f6e4e4e4e4
e4e4e4e4f60404140404c4f6f6f6f6f6f6f6f6f6f6f6f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3f7a3e4e4f61414141414f6e4e4e4e4e4e4e4e4e4e4f60404140404f6e4e4e4e4
e4e4e4e4f60404140404f6e4e4e4e4e4e4e4e4e4e4e4e4e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3f7a3a3a3a3a3a3a3e4e4f60404140404c5d5d5d5d5d5d5d5d5d5d5e50404140404c5d5d5d5d5
d5d5d5d5e50404140404f6e4e4e4e4e4e4e4e4e4e4e4e4e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3f7a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3e4e4f6040414040404240404040404042404040404041404040404040404
04040424040404140404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3e4e4f6040414040404240404040404042404040404041404040404040404
04040424040404140404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3e4e4f604046424242424242484242424242424242424a424242424242424
24242424242424340404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3f7a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3e4e4f6040404040404240404140404042404040404040404040404040404
04040424040404040404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3b6a3e4f60404140404f6e4a3b6a3a3a3f7a3a3a3a3e4e4f6040404040404240404140404042404040404040404040404040404
04040424040404040404f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3e4e4f6f6f6f6f6f6f6d40404140404c4f6f6f6f6f6f6f6f6f6f6f6f6f6f6
f6f6f6f6f6f6f6f6f6f6f6e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3e4e4e4e4e4e4e4e4e4f61414141414f6e4e4e4e4e4e4e4e4e4e4e4e4e4e4
e4e4e4e4e4e4e4e4e4e4e4e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3e4e4e4e4e4e4e4e4e4f60404140404f6e4e4e4e4e4e4e4e4e4e4e4e4e4e4
e4e4e4e4e4e4e4e4e4e4e4e4e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3f7a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a3a3a3a3a3a3a3a3a3b6a3a3a3e4f60404140404f6e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3f7a3a3a3a3a3a3a3a3a3a3a3a3f7a3e4f60404140404f6e4a3a3b6a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3f7a3a3a3a3a3a3e4f60404140404f6f6a3a3b6a3a3a3a3a3a3a3f7a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3f7a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6f6a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404f6f6f6f6e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4f60404140404f6e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3f7a3e4f60404140404c5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5e50404140404f6e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404040404040404040424040404040404040404040404040404140404f6e4a3b6a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404140404040404040404040424040404040404040404040404040404140404f6e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404642424242424242424242424242424242424242424242424242424340404f6e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f60404040404040404040404040424040404040404040404040404040404040404f6e4a3a3a3f7a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3f7a3a3a3e4f60404040404040404040404040424040404040404040404040404040404040404f6e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4a3a3a3a3a3a300000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3f7a3a3a3a3a3a3a3a3a3a3a3b6a3a3a3a3a3a3a3a3a3a3b6a3a3a3a3a3a3a3a300000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000003000003030304000000000000000000000001010301000000000000000000000400010101010000000000000000000001030303030100000000000000000000000303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e6f5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d6f4e3a6b3a3a3a3a3a7f3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d6f4e4e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e6f4040404040404040404042404040404040404040404040404040406f4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404040404040404042404040404040404040404040404040406f4e4e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e6f4040404040404040404042404040404040404040404040404040406f4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404040404040404042404040404040404040404040404040406f4e4e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e6f4040454242424242424242424242424242424242424242424440406f4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a7f3a3a3a3a3a4e4e6f40404542424242424242424242424242424242424242424440406f4e4e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e6f4040414040404040404042404040404040404040404040404140406f4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404140404040404042404040404040404040404040404140402d4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e000000000000000000000000000000000000000000000000000000000000
4e6f4040414040404040404042404040404040404040404040404140406f4e3a3a3a7f3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404140404040404042404040404040404040404040404140406f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e000000000000000000000000000000000000000000000000000000000000
4e6f40404140404c6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f4d40404140406f4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404140404c6f6f6f6f6f6f2d6f6f6f6f6f6f6f4d41414141415c5d5d5d5d5d5d5d5d5d5d5d5d5d5d6f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f40404140406f6f4e4e4e4e4e4e4e4e4e4e4e4e4e6f6f40404140406f4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f41414141416f4e4e4e4e4e4e4e4e4e4e4e4e4e4e6f40404140404042404040404040404040404040406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f40404140406f4e3a3a3a3a3a6e3a3a3a6b3a3a3a4e6f41414141416f4e3a3a3a3a3a3a3a3a3a3a3a3a7f3a3a3a3a3a3a3a4e4e2d40404140406f4e4e3a3a3a3a6e7f3a3a3a3a4e4e6f40404140404042404040404040404040404040406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f40404140406f4e3a3a7f3a6d7b7e7e7e7e7d3a3a4e6f40404140406f4e3a3a6b3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404140406f4e4e3a6b3a3a6e3a3a3a3a3a4e4e6f40404942424242424242424242424242424440406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f40404140406f4e3a3a3a3a6e3a6b3a3a3a6e3a3a4e6f40404140406f4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404140406f4e4e3a3a3a3a7c7d3a6b3a3a4e4e6f40404140404042404040404040404040404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f40404140406f4e3a3a3a6b6e3a3a3a3a7f7c7d3a4e6f40404140406f4e3a3a3a3a3a3a3a7f3a3a3a3a3a6b3a3a3a3a3a3a4e4e6f40404140406f4e4e3a3a3a3a3a6e3a3a3a3a4e4e6f40404140404042404040404040404040404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f40404140406f4e3a3a3a3a6e3a3a3a3a3a3a7c7e4e6f40404140406f4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404140406f4e4e3a3a3a6b3a6e3a7f6d7e4e4e6f40404140404c6f6f6f6f6f6f6f6f4d40404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f40404140406f6f4e4e4e4e4e4e4e4e4e4e4e4e4e6f6f40404140406f4e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404140406f4e4e3a3a3a6d7e7b7e7e6c3a4e4e6f40404140406f4e4e4e4e4e4e4e4e6f40404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f40404140405c5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5e40404140406f4e3a3a3a4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e6f40404140406f4e4e3a3a7f6e3a3a3a3a3a7f4e4e2d40404140406f4e4e4e4e4e4e4e4e6f41414141416f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f4040414040404042404040404040404040404040404040404140406f4e3a3a3a4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e6f40404140406f4e4e3a3a3a6e3a3a6b3a3a3a4e4e6f40404140406f4e4e4e4e4e4e4e4e6f40404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f4040414040404042404040404040404040404040404040404140406f4e3a3a3a4e4e6f5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5e41414141416f4e4e4e4e4e4e4e4e4e4e4e4e4e4e6f40404140406f4e4e4e4e4e4e4e4e6f40404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f4040464242424242424242484242424242424242424242424340406f4e3a6b3a4e4e6f404040404040404040404040404040424040404140406f4e4e4e4e4e4e4e4e4e4e4e4e4e4e6f40404140406f4e4e4e4e4e4e4e4e6f40404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f4040404040404042404040414040404040404040404040404040406f4e3a3a3a4e4e6f404040404040404040404040404040424040404140405c5d5d5d5d5d5d5d5d5d5d5d5d5d5d5e41414141415c5d5d5d5d5d5d5d5d5e40404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f4040404040404042404040414040404040404040404040404040406f4e3a3a3a4e4e6f404045424242424242424242424242424242424b40404042404040404040404040404040404240404140404240404040404040424040404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e6f6f6f6f6f6f6f6f6f4d40404140404c6f6f6f6f6f6f6f6f6f6f6f6f6f4e3a3a3a4e4e6f404041404040404040404040404040424040404140404042404040404040404040404040404240404140404240404040404040424040404140406f4e4e000000000000000000000000000000000000000000000000000000000000
4e4e4e4e4e4e4e4e6f6f6f40404140406f6f4e4e4e4e4e4e4e4e4e4e4e4e4e3a3a3a4e4e6f404041404040404040404040404040424040404942424242424242424242424242424842424242424a42424242424842424242424242424340406f4e4e000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a6f6f40404140406f6f3a3a3a3a3a3a3a3a3a3a6e3a3a3a3a3a4e4e6f40404140404c6f6f6f2d6f6f6f6f6f6f4d40404140404042404040404040404040404140404240404040404240404140404040424040404040406f4e4e000000000000000000000000000000000000000000000000000000000000
3a3a7f3a3a3a3a3a3a4e6f40404140406f6f3a3a3a3a7f3a3a3a3a3a6e3a3a3a3a3a4e4e2d40404140406f4e4e4e4e4e4e4e4e4e4e6f40404140404042404040404040404040404140404240404040404240404140404040424040404040406f4e4e000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a6b3a4e6f40404140406f6f7e7e7e7e7e7e7e7e7e7e6c3a3a3a3a3a4e4e6f40404140406f4e4e4e4e4e4e4e4e4e4e6f40404140404c6f6f6f2d6f6f6f6f4d41414141414c6f6f6f6f6f4d40404140404c6f6f6f6f6f6f6f6f6f4e4e000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a4e6f40404140406f6f3a7f3a3a6b3a3a3a3a3a7f3a3a6b3a3a4e4e6f40404140406f4e4e4040404040404e4e6f40404140406f4e4e4e4e4e4e4e4e6f40404140406f6f6f6f6f6f6f41414141416f4e4e4e4e4e4e4e4e4e4e4e000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a4e6f40404140406f6f3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a4e4e6f40404140406f4e4e5b404c4d405a4e4e2d40404140406f4e4e4e4e4e4e4e4e6f40404140402d4e4e4e4e4e6f40404140406f4e4e4e4e4e4e4e4e4e4e4e000000000000000000000000000000000000000000000000000000000000
3a3a3a3a7f3a3a3a3a4e6f40404140406f6f4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e6f41414141416f4e4e5b5a6f6f5b5a4e4e6f40404140406f4e4e4e4e4e4e4e4e6f40404140406f4e4e4e4e4e6f40404140406f4e4e000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a4e6f40404140405c5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5e40404140406f4e4e5b5a6f6f5b5a4e4e6f40404140406f4e4e4e4e4e4e4e4e6f40404140406f4e4e4e4e4e6f40404140406f4e4e000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a7f3a4e6f404041404040404040404040424040404040404040404040424040404140406f4e4e5b5a6f6f5b5a4e4e6f40404140402d4e4e4e4e4e4e4e4e6f40404140406f4e4e4e4e4e6f40404140406f4e4e000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a4e6f404041404040404040404040424040404040404040404040424040404140406f4e4e5b5a6f6f5b5a4e4e6f40404140406f4e4e4e4e4e4e4e4e6f40404140406f4e4e4e4e4e6f40404140402d4e4e000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000023030270302f0002e0002e0002d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001d030180302f0002e0002e0002d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000180251f535260452a55512604176011b6011f601226012560128601296012b601296012760124601216011f6011c601186011560113601116010f6010e60500500005000050000500005000050000500
010100001817218172181721817218162181621812218122181221812218122181221812218122181221812218122181221812218122181221812218122181221812218122181221812218122181221812218122
000400001d7401d7401d7402374023740237401f7401f7401f7401f7001f7001f7001f7001f700007000070031700317000070000700007000070000700007000070000700007000070000700007000070000700
000200002712027120271202712027120271202712027120271202712027120271202711027100271002710027100271002710027100271000010000100001000010000100001000010000100001000010000100
000200002e1202e1202e1202e1202e1202e1202e1202e1202e1202e1202e1202e1102e1102e1002e1002e1002e1002e1002e1002e1002e1000010000100001000010000100001000010000100001000010000100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002164021640216402164018630126300c630086200562003610036100760005600146001460014600146001560016600166001460012600106000e6000d6000d600006000060000600000000000000000
000100002162021620216102161018610126100c600086000560003600036000760005600146001460014600146001560016600166001460012600106000e6000d6000d600006000060000600000000000000000
3404000029000290002900023000200001d0001d0002e10029000290002600024000210001f0001d0002e10029000290002900023000200001e0001b000190001900000100001000010000100001000010000100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0128000000000000001505015050150501505010050100500e0500e0500e0500e0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012800000000000000180501805018050180501305013050120501205012050120500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0128000000000000001c0501c0501c0501c0501705017050150501505015050150500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b5000b0017b5015b5000b0015b5010b5015b500eb5013b5018b5017b5015b5000b001ab501cb501db50
0116000000b001cb501ab5000b0015b5018b501ab501cb5000b001ab5018b5000b0010b5015b5017b5018b5000b0017b5015b5000b0015b5010b5015b500eb5013b5018b5017b5015b5000b001ab501cb501db50
0116000000b001cb501ab5000b0015b5018b501ab501cb5000b001ab5018b5000b0015b5018b501ab5000b001ab5000b0018b5017b5013b5018b5017b5013b501cb5010b5017b5018b5015b5000b0000b0000b00
011600000c0630000030615000000c0630000030615306000c0630000030615000000c0630c063306150c0630c0630000030615000000c0630000030615306000c0630000030615000000c0630c063306150c063
1916000021b4023b4024b4023b4021b4000b0024b401cb4024b4023b4024b4026b4024b4021b4023b4000b0024b401cb4028b4000b0026b4023b401fb4000b0021b4021b4023b4024b4023b401cb4000b0000b00
0116000018721187211872518725187251872518721187211a7211a7211a7251a7251a7251a7251a7211a7211c7211c7211c7251c7251c7251c7251c7211c7211d7211d7211d7251d7251d7251d7251d7211d721
011600000c7000c7440c7400c7400c7400c7400c7450c7000c7000c7440c7400c7400c7400c7400c7450c7000c7000c7000c7000c7000c7000c7000c700000000000000000000000000000000000000000000000
a916000010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b50
a916000004b6009b600bb600cb6004b6009b600bb600cb6004b6009b600bb600cb6004b6009b600bb600cb6004b6009b600bb600cb6004b6009b600bb600cb6004b6009b600bb600cb6004b6009b600bb600cb60
a91600000000000000000000000010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b500000000000000000000010b5015b5017b5018b5010b5015b5017b5018b5010b5015b5017b5018b50
011600000c0630000030600000000c0630000030615306000c0630000030600000000c0630c000306150c0000c0630000030600000000c0630000030615306000c0630000030600000000c0630c000306150c000
000100000316003160031600316003160031600316003160031500314003130031300010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
__music__
00 18525344
00 18194344
01 0f121744
00 10121744
00 11121744
00 17121344
02 16121317

