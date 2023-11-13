pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
px=4.5
py=10.5
pa=0

x=0
y=0
vx=0
vy=0
ox=0
oy=0
dx=0
dy=0
ix=0
iy=0
h=40
cs={13,4,12}

function _draw()
	
	// player control
	if btn(0) then
		pa+=0.01
		if pa>1 then
			pa-=1
		end
	end
	if btn(1) then
		pa-=0.01
		if pa<0 then
			pa+=1
		end
	end
	if btn(2) then
		px+=cos(pa)*0.1
		py+=sin(pa)*0.1
	end
	if btn(3) then
		px-=cos(pa)*0.1
		py-=sin(pa)*0.1
	end
	
	// background
	cls(5)
	rectfill(0,64,128,128,6)
	
	// for each x position
	for i=0,127 do
		
		// find starting tile
		x=px
		y=py
		
		// find ray direction
		vx=cos(pa-(i-64)/512)
		vy=sin(pa-(i-64)/512)
		
 	// find standard distance
		dx=abs(1/vx)
		dy=abs(1/vy)
		
		// find increment value
		ix=vx>0 and 1 or -1
		iy=vy>0 and 1 or -1
		
		// find initial offset
		if vx>0 then
			ox=(flr(x)-x+1)/vx
		else
			ox=abs((x-flr(x))/vx)
		end
		if vy>0 then
			oy=(flr(y)-y+1)/vy
		else
			oy=abs((y-flr(y))/vy)
		end
		
		while true do
			// horizontal intersection
			if ox<oy then
				x+=ix
				d=ox
				ox+=dx
			else // vertical intersection
				y+=iy
				d=oy
				oy+=dy
			end
			// check for collsion
			if mget(x,y)>0 or x<0 or x>15 or y<0 or y>15 then
				line(i,64-h/d,i,64+h/d,cs[mget(x,y)])
				break
			end
		end
	end
end
__gfx__
00000000dddddddd44444444cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd44444444cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd44444444cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd44444444cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd44444444cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd44444444cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd44444444cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd44444444cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000770000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000770000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000060000077000000006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000006669966666666666666667766666666666600000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000609050000000000060770000000000006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000609050000000000077000000000000006000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006090500000000077600000e0000000006000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006990500000007700eeeeeeeeeeee00006000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006090500000770000e0000000000e00006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000609050007700000065555555557899006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000609050770000000060000000770509006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000609987555555555560000077000509006000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006000e00000000000e0007700000509006000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006000eeeeeeeeeeeee0770000000509006000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000e0000077000000000509906000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000007760000000000509006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000770060000000000509006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000600000000077000060000000000509006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000006666666667766666666666666666699666600000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000600000770000000060000000000000006000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000077000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006111111161111111600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006111111161111111600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006111111161111111600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006111111161111111600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006111111161111111600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006111111e61177771600000000
000000000000000000000000000000060000000600000006000000060000000600000006000000060000000600000006000000061111911e7711111600000000
000000000000000000000000000000666666666666666666666666666666666666666666666666666666666666666666666666e666677976e666666660000000
0000000000000000000000000000000600000006000000060000000600000006000000060000000611111116111111161111111e777111960000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006111111161111111611117776e11111160000000600000000
0000000000000000000000000000000600000006000000060000000600000006000000060000000611111116111111e677771116111111160000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006111111161111777e11111116111111160000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006111111e617771116e1111116111111160000000600000000
000000000000000000000000000000060000000600000006000000060000000600000006000000061111177e7111111611111116111111160000000600000000
000000000000000000000000000000060000000600000006000000060000000600000006000000e691777116e111111611111116111111160000000600000000
0000000000000000000000000000006666666666666666666666666666666666666666666666667e796666666666666666666666666666666666666660000000
0000000000000000000000000000000600000006000000061111111611111116111111e611777716e19111160000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000611111116111111161111111e77111116111111160000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000611111116111111e611177776e1111116111111160000000600000006000000060000000600000000
000000000000000000000000000000060000000600000006111111161111111e7771111611111116111111160000000600000006000000060000000600000000
0000000000000000000000000000000600000006000000061111111611117776e111111611111116111111160000000600000006000000060000000600000000
000000000000000000000000000000060000000600000006111111e6777711161111111611111116111111160000000600000006000000060000000600000000
0000000000000000000000000000000600000006000000061911777e111111161111111611111116111111160000000600000006000000060000000600000000
0000000000000000000000000000006666666666666666e667976666e66666666666666666666666666666666666666666666666666666666666666660000000
00000000000000000000000000000006000000061111177e71191116000000060000000600000006000000060000000600000006000000060000000600000000
000000000000000000000000000000060000000688877116e1111116000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000068881111611111116000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000068881111611111116000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000061111111611111116000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000061111111611111116000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000061111111611111116000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
00000000000000000000000000000066666666666666666666666666666666666666666666666666666666666666666666666666666666666666666660000000
00000000000000000000000000000006000000060000000600000006000000060000000600000006000000060000000600000006000000060000000600000000
__label__
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
45555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
44555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
44455555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddddddddddddddddddddd
4444555555555555555555555555555555555555555555555555555ddddddddd5555555555555555555555555555555555555555dddddddddddddddddddddddd
444444555555555555555555555555555555555555555555555ddddddddddddddddddddddd555555555555555555555555555555dddddddddddddddddddddddd
444444455555555555555555555555555555555555555555dddddddddddddddddddddddddddd5555555555555555555555555555dddddddddddddddddddddddd
444444445555555555555555555555555555555555555555dddddddddddddddddddddddddddd5555555555555555555555555555dddddddddddddddddddddddd
444444444555555555555555555555555555555555555555dddddddddddddddddddddddddddd5555555555555555555555555555dddddddddddddddddddddddd
444444444455555555555555555555555555555555555555dddddddddddddddddddddddddddd555555555555555ddddddddddddddddddddddddddddddddddddd
4444444444c5555555555555555555555555dddddddddddddddddddddddddddddddddddddddd555555555555dddddddddddddddddddddddddddddddddddddddd
4444444444cc45555555555555555555555ddddddddddddddddddddddddddddddddddddddddddddd55555555dddddddddddddddddddddddddddddddddddddddd
4444444444cc445555555555555555dddddddddddddddddddddddddddddddddddddddddddddddddd55555554dddddddddddddddddddddddddddddddddddddddd
4444444444cc444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddd44444444dddddddddddddddddddddddddddddddddddddddd
4444444444cc444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddd44444444dddddddddddddddddddddddddddddddddddddddd
4444444444cc444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddd44444444dddddddddddddddddddddddddddddddddddddddd
4444444444cc444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddd44444444dddddddddddddddddddddddddddddddddddddddd
4444444444cc444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddd44444444dddddddddddddddddddddddddddddddddddddddd
4444444444cc444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddd44444444dddddddddddddddddddddddddddddddddddddddd
4444444444cc444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddd44444444dddddddddddddddddddddddddddddddddddddddd
4444444444cc444444444444444444dddddddddddddddddddddddddddddddddddddddddddddddddd44444444dddddddddddddddddddddddddddddddddddddddd
4444444444cc446666666666666666dddddddddddddddddddddddddddddddddddddddddddddddddd66666664dddddddddddddddddddddddddddddddddddddddd
4444444444cc46666666666666666666666ddddddddddddddddddddddddddddddddddddddddddddd66666666dddddddddddddddddddddddddddddddddddddddd
4444444444c6666666666666666666666666dddddddddddddddddddddddddddddddddddddddd666666666666dddddddddddddddddddddddddddddddddddddddd
444444444466666666666666666666666666666666666666dddddddddddddddddddddddddddd666666666666666ddddddddddddddddddddddddddddddddddddd
444444444666666666666666666666666666666666666666dddddddddddddddddddddddddddd6666666666666666666666666666dddddddddddddddddddddddd
444444446666666666666666666666666666666666666666dddddddddddddddddddddddddddd6666666666666666666666666666dddddddddddddddddddddddd
444444466666666666666666666666666666666666666666dddddddddddddddddddddddddddd6666666666666666666666666666dddddddddddddddddddddddd
444444666666666666666666666666666666666666666666666ddddddddddddddddddddddd666666666666666666666666666666dddddddddddddddddddddddd
4444666666666666666666666666666666666666666666666666666ddddddddd6666666666666666666666666666666666666666dddddddddddddddddddddddd
44466666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
44666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
46666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddddddddddddddd
6666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666ddddddddddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666dddddddddddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666ddd
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666

__map__
0101010101010102020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000100000200000200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000100000000000200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000300000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000100000000000002020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010100000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020302020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000100000100000100000100000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000100000100000100000100000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
