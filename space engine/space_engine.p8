pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--space game

function _init()
	ship1=make_ship(8,8,0)
	ship2=make_ship(32,32,8)
	planets={}
	make_planet(32,12,13,"earth")
end

function _update()
	--ship1
	control_ship1(ship1)
	move_ship(ship1)
	move_bullets(ship1)
	
	control_ship2(ship2)
	move_ship(ship2)
	move_bullets(ship2)

end

function _draw()
	cls()
	draw_map()
	
	--ship1
	draw_ship(ship1)
	draw_bullets(ship1)
	
	--ship2
	draw_ship(ship2)
	draw_bullets(ship2)
end
-->8
--ship stuff

accel=0.3
decel=0.2
bullet_speed=3

function make_ship(x,y,sprite)
	ship={}
	ship.x=x ship.y=y
	ship.vx=0 ship.vy=0
	--ship.ax=0 ship.ay=0
	ship.health=5 ship.sprite=sprite
	ship.direction=0
	ship.bullets={}
	return ship
end

function make_bullet(s)
	if(#s.bullets<5) then
		bullet={}
		bullet.x=s.x bullet.y=s.y
		bullet.direction=s.direction
		bullet.sprite=17
		add(s.bullets,bullet)
	end
end

function control_ship1(s)
	if(btn(⬅️) and s.vx>-1.5) s.vx-=accel
	if(btn(➡️) and s.vx<1.5) s.vx+=accel
	if(btn(⬆️) and s.vy>-1.5) s.vy-=accel
	if(btn(⬇️) and s.vy<1.5) s.vy+=accel
	poke(0x5f5c, 255)
	if(btnp(🅾️)) make_bullet(s)
end

function control_ship2(s)
	if(btn(⬅️,1) and s.vx>-1.5) s.vx-=accel
	if(btn(➡️,1) and s.vx<1.5) s.vx+=accel
	if(btn(⬆️,1) and s.vy>-1.5) s.vy-=accel
	if(btn(⬇️,1) and s.vy<1.5) s.vy+=accel
	poke(0x5f5c, 255)
	if(btnp(🅾️)) make_bullet(s)
end

function move_ship(s)
	s.x+=s.vx
	s.y+=s.vy
	if(s.vx==0 and s.vy<0) s.direction=0
	if(s.vx<0 and s.vy<0 and s.vx==s.vy) s.direction=1
	if(s.vx<0 and s.vy==0) s.direction=2
	if(s.vx<0 and s.vy>0 and s.vx==-s.vy) s.direction=3
	if(s.vx==0 and s.vy>0) s.direction=4
	if(s.vx>0 and s.vy>0 and s.vx==s.vy) s.direction=5
	if(s.vx>0 and s.vy==0) s.direction=6
	if(s.vx>0 and s.vy<0 and s.vx==-s.vy) s.direction=7
end

function move_bullet(b)
	if(b.direction==0) b.y-=bullet_speed
	if(b.direction==1) b.x-=bullet_speed b.y-=bullet_speed
	if(b.direction==2) b.x-=bullet_speed
	if(b.direction==3) b.x-=bullet_speed b.y+=bullet_speed
	if(b.direction==4) b.y+=bullet_speed
	if(b.direction==5) b.x+=bullet_speed b.y+=bullet_speed
	if(b.direction==6) b.x+=bullet_speed
	if(b.direction==7) b.x+=bullet_speed b.y-=bullet_speed
end

function move_bullets(s)
	foreach(s.bullets,move_bullet)
end

function draw_bullet(b)
	spr(b.sprite,b.x,b.y)
end

function draw_bullets(s)
	foreach(s.bullets,draw_bullet)
end

function draw_ship(s)
	spr(s.sprite+s.direction,s.x,s.y)
end
-->8
--{} [] #
-->8
--map and planets

function make_planet(sprite,x,y,name)
	planet={}
	planet.sprite=sprite
	planet.x=x planet.y=y
	planet.name=name
	add(planets,planet)
end

function draw_map()
	map()
	for p in all(planets) do spr(p.sprite,p.x,p.y) end
end
__gfx__
0000a000aa0000000000000000090000090090090000900000000000000000aa0000c000cc0000000000000000010000010010010000100000000000000000cc
000aaa00aaaa000000000999009900900990909909009900999000000000aaaa000ccc00cccc000000000111001100100110101101001100111000000000cccc
000aaa000aaaa990000aaa90009aa90009aa9aa9009aa90009aaa000099aaaa0000ccc000cccc110000ccc10001cc10001cc1cc1001cc10001ccc000011cccc0
00aaaaa00aaaaa990aaaaa0000aa9a0000aaaaa000a9aa0000aaaaa099aaaaa000ccccc00ccccc110ccccc0000cc1c0000ccccc000c1cc0000ccccc011ccccc0
00aaaaa000aa9a00aaaaa9990aaaaa9900aaaaa099aaaaa0999aaaaa00a9aa0000ccccc000cc1c00ccccc1110ccccc1100ccccc011ccccc0111ccccc00c1cc00
09aa9aa9009aa9000aaaaa000aaaa990000aaa00099aaaa000aaaaa0009aa90001cc1cc1001cc1000ccccc000cccc110000ccc00011cccc000ccccc0001cc100
0990909900990090000aaa90aaaa0000000aaa000000aaaa09aaa000090099000110101100110010000ccc10cccc0000000ccc000000cccc01ccc00001001100
090090090009000000000999aa0000000000a000000000aa9990000000009000010010010001000000000111cc0000000000c000000000cc1110000000001000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000990000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c77c00005560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbcccc0005566000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cbcccbbb055556600555000000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cbccbbbb555555550000000000055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccbccbcb555555550000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccbbcbcc055555550600055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cbcccc0005555505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c77c00000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000005000005600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0101010101010101010101010101010100000000000000000000000000000000000202020000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013002100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000002100000000222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000323300000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000120000000000000000120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
