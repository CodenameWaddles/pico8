pico-8 cartridge // http://www.pico-8.com
version 36
__lua__

gray_patterns={	 0b0.1000000000000000,
				 0b0.1000000000100000,
				 0b0.1000000010100000,
				 0b0.1010000010100000,
				 0b0.1010010010100000,
				 0b0.1010010010100001,
				 0b0.1010010010100101,
				 0b0.1010010110100101,
				 0b0.1110010110100101,
				 0b0.1110010110110101,
				 0b0.1110010111110101,
				 0b0.1111010111110101,
				 0b0.1111010111110111,
				 0b0.1111110111110111,
				 0b0.1111110111111111,
				 0b0.1111111111111111}

pico_palette={
{0,0,0},
{.11,.17,.33},
{.49,.15,.33},
{0,.53,.32},
{.67,.32,.21},
{.37,.34,.31},
{.76,.76,.78},
{1,.95,.91},
{1,0,.3},
{1,.64,0},
{1,.93,.15},
{0,.89,.21},
{.16,.68,1},
{.51,.46,.61},
{1,.47,.66},
{1,.80,.67}
}

pico_color_index={
{0,0},
{1,1},
{2,2},
{3,3},
{4,4},
{5,5},
{6,6},
{7,7},
{8,8},
{9,9},
{10,10},
{11,11},
{12,12},
{13,13},
{14,14},
{15,15}}


bayer={{ 0/64,32/64,8/64,40/64,2/64,34/64,10/64,42/64},
{48/64,16/64,56/64,24/64,50/64,18/64,58/64,26/64},
{12/64,44/64,4/64,36/64,14/64,46/64,6/64,38/64},
{60/64,28/64,52/64,20/64,62/64,30/64,54/64,22/64},
{ 3/64,35/64,11/64,43/64,1/64,33/64,9/64,41/64},
{51/64,19/64,59/64,27/64,49/64,17/64,57/64,25/64},
{15/64,47/64,7/64,39/64,13/64,45/64,5/64,37/64},
{63/64,31/64,55/64,23/64,61/64,29/64,53/64,21/64}}


function set_color_and_pattern(c1,c2,mix)
	local color = bor(0x1000,shl(c2,4))
	local color = bor(color,c1)
	return bor(color,gray_patterns[ flr(mix)])
end


function plot_color_mode3(x,y,color)
	--poke(0x5F34, 0)
	local threshold = .2
	local red_target = color[1] + bayer[x%8+1][y%8+1] * threshold
	local blue_target = color[2] + bayer[(x+0)%8+1][y%8+1] * threshold
	local green_target = color[3] + bayer[x%8+1][y%8+1] * threshold
	--local result_color = closest_color_lum({red_target,blue_target,green_target})
	--local pat = set_color_and_pattern(result_color,result_color,15)
	
	local closest_i=1
	local dist=100
	for i, palette_color in pairs(pico_palette) do
		local d = color_compare({red_target,green_target,blue_target},palette_color)--vec3_length(vec3_sub(rgb,))
		if(d<dist)then closest_i=i dist=d end
	end

	
	pset(x,y,pico_color_index[closest_i][1])
	sset(x,y,pico_color_index[closest_i][2])

end


function plot_color_mode2(x,y,color)
	--poke(0x5F34, 0)
	local threshold = .2
	local red_target = color[1] + bayer[x%8+1][y%8+1] * threshold
	local blue_target = color[2] + bayer[(x+0)%8+1][y%8+1] * threshold
	local green_target = color[3] + bayer[x%8+1][y%8+1] * threshold
	--local result_color = closest_color_lum({red_target,blue_target,green_target})
	--local pat = set_color_and_pattern(result_color,result_color,15)
	
	local closest_i=1
	local dist=100
	for i=1, 16 do
		palette_color=pico_palette[i]
		local d = color_compare({red_target,green_target,blue_target},palette_color)--vec3_length(vec3_sub(rgb,))
		if(d<dist)then closest_i=i dist=d end
	end

	
	pset(x,y,pico_color_index[closest_i][1])
	sset(x,y,pico_color_index[closest_i][1])

end


function closest_color_lum(rgb)
	local closest_i=1
	local dist=100
	for i, palette_color in pairs(pico_palette) do
		local d = color_compare(rgb,palette_color)--vec3_length(vec3_sub(rgb,))
		if(d<dist)then closest_i=i dist=d end
	end
	return closest_i-1
end

function add_new_colors()
	for c1=1,16 do
		for c2=c1,16 do
			
			if(color_compare(pico_palette[c1],pico_palette[c2])<.4)then
				new_color = vec3_scale(vec3_add(pico_palette[c1],pico_palette[c2]),.5)
				add(pico_palette,new_color)
				add(pico_color_index,{c1-1,c2-1})
			end
		end
	end
end


function closest_color_rgb(rgb)
	local closest_i=1
	local dist=100
	for i=1,16 do
		local d = vec3_length(vec3_sub(rgb,pico_palette[i]))
		if(d<dist)then closest_i=i dist=d end
	end
	return closest_i-1
	
end

function color_compare(rgb1,rgb2)
	--use ccir luminosity
	local luma1 = rgb1[1]*.299+rgb1[2]*.587+rgb1[3]*.114
	local luma2 = rgb2[1]*.299+rgb2[2]*.587+rgb2[3]*.114
	local lumadiff=luma1-luma2
	local diff = vec3_sub(rgb1,rgb2)
	return (diff[1]*diff[1]*0.299 + diff[2]*diff[2]*.587 + diff[3]*diff[3]*.114)*.75+lumadiff*lumadiff
end	



function stop()
	while(true)do flip() end
end

function init_color_ramp()
	poke(0x5f34, 1) -- set fill pattern mode
	color_ramp={}
	for i=1, #pico_palette do
		pico_palette[i][4]=(pico_palette[i][1]+pico_palette[i][2]+pico_palette[i][3])/3
	end
	shade_list={{0,1,1}          ,
				{0,1,1}           ,
				{0,1,2,2}         ,
				{0,1,3,11,7,7}     ,
				{0,1,2,4,9,7,7}     ,
				{0,1,5,6,7,7}       ,
				{0,1,5,13,6,7,7}    ,
				{0,1,5,13,6,7,7}  ,
				{0,1,2,8,14,7}   ,
				{0,1,2,4,9,7,7}     ,
				{0,1,2,4,9,10,7,7},
				{0,1,3,11,7,7}    ,
				{0,1,12,12,7}      ,
				{0,1,13,6,7,7}      ,
				{0,1,13,6,7,7}      ,
				{0,1,8,14,7,7}    ,
				{0,1,14,15,7,7}   }
	--shade_list={0,1,2,4,9,15,15}
	for c=0,15 do
			color_ramp[c]={}
		for n=0,127 do
			target_shade = n/128
			i=1
			local rr=pico_palette[shade_list[c+1][i]+1][4]
			while(rr<=target_shade and i<#shade_list[c+1])do
				i+=1
				rr=pico_palette[shade_list[c+1][i]+1][4]
			end
			local right_color=shade_list[c+1][i]
			local left_color=shade_list[c+1][i-1]
			local lr=pico_palette[left_color+1][4]
			local span=rr-lr
			local delta=target_shade-lr
			local bright= delta/span
			color = bor(0x1000,shl(right_color,4))
			color = bor(color,left_color)
			color_ramp[c][n] = bor(color,gray_patterns[ flr(bright*16)])
		end
	end
	
end

--------------------------------
function new_ray(o,d)
	nr={}
	nr.origin=o
	nr.direction=d
	return nr
end

function vec3_dot(a,b)
	return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]
end

function vec3_unit(v)
	local x1=shr(v[1],2)
	local y1=shr(v[2],2)
	local z1=shr(v[3],2)
	local inv_dist=1/sqrt(x1*x1+y1*y1+z1*z1)
	return {x1*inv_dist,y1*inv_dist,z1*inv_dist}
end

function vec3_length(v)
	local x1=shr(v[1],2)
	local y1=shr(v[2],2)
	local z1=shr(v[3],2)
	return sqrt(x1*x1+y1*y1+z1*z1)
end

function vec3_flip(a)
	return {-a[1],-a[2],-a[3]}
end

function vec3_sub(a,b)
	return {a[1]-b[1],a[2]-b[2],a[3]-b[3]}
end
function vec3_add(a,b)
	return {a[1]+b[1],a[2]+b[2],a[3]+b[3]}
end
function vec3_scale(a,s)
	return {a[1]*s,a[2]*s,a[3]*s}
end


function	vec3_cross(p,a,b)
	 a[1]-=p[1]
	 a[2]-=p[2]
	 a[3]-=p[3]
	 b[1]-=p[1]
	 b[2]-=p[2]
	 b[3]-=p[3]
	return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}
end

function hit_sphere(center,radius,ray)
	local oc = vec3_sub(ray.origin,center)
	local a = vec3_dot(ray.direction,ray.direction)
	local b= 2*vec3_dot(oc,ray.direction)
	local c= vec3_dot(oc,oc)-radius*radius
	local d = b*b - 4*a*c
	if(d <0)return false

	local t= (-b-sqrt(d))/2.0*a	
	local isect=vec3_scale(ray.direction,t)
	local normal = vec3_unit(vec3_sub(isect,center))
	
	return t,normal
end

k_small_number = .0001
function hit_plane(normal,d,ray)
	if( vec3_dot(ray.direction,normal)>0)return false
	local div=vec3_dot(ray.direction,normal)
	if(abs(div)<k_small_number)return false
	local t = -(vec3_dot(ray.origin,normal)+d)/div
	
	if(t<0)return false
	return t,normal
end


object_list={}
k_sphere=1
k_plane=2

function new_sphere(center,radius,color)
	s={}
	s.center=center or {0,0,0}
	s.radius=radius or 1
	s.color=color or {1,1,1}
	s.type=k_sphere
	s.texture=0
	s.reflect=0
	add(object_list,s)
	return s
end

function new_plane(normal,distance,color)
	p={}
	p.normal=normal or {0,1,0}
	p.distance=distance or 1
	p.type=k_plane
	p.color=color or {1,1,1}
	p.texture=0
	p.reflect=0
	add(object_list,p)
	return p
end

function intersect_object(object,ray)
	if(object.type==k_sphere)t,normal=hit_sphere(object.center,object.radius,ray)
	if(object.type==k_plane)t,normal=hit_plane(object.normal,object.distance,ray)
	return t,normal
end

k_infinity = 500
function intersect_objects(ray)
	local min_t = k_infinity
	local min_normal={}
	local hit_object
	--local color=8
	for k,object in pairs(object_list) do
		local t, n = intersect_object(object, ray)
		--return t,n
		if(t!=false)then

				if(t<min_t and t>0)then
					min_t=t
					min_normal=n
					color=object.color
					hit_object=object
				end

		end

	end
	--if(min_t<=0)return false
	if(min_t>=k_infinity)return false
	return min_t,min_normal,hit_object--color,object
	
end

function render_ray(iray)
	local t,inormal,object=intersect_objects(iray)
	local bright=.5
	local color
	
		if(t!=false)then
				color=object.color
				local intersect_point=vec3_add(iray.origin,vec3_scale(iray.direction,t))
				local shadow_ray = new_ray(intersect_point,light_dir)
				local shadow_t,shadow_normal = intersect_objects(shadow_ray)

				local diffuse = vec3_dot(inormal,light_dir)
				diffuse=mid(diffuse,0,1)
				local spec_reflect = vec3_sub(light_dir,vec3_scale(inormal, 2*vec3_dot(inormal,light_dir)))
				local specular = vec3_dot(spec_reflect,iray.direction)
				specular=mid(specular,0,1)
				specular=specular^3
				
				local ambient = 0
				bright = (diffuse*.5+specular*.5)

				if(object.texture==1)then
					u,v=intersect_point[1]*ca-intersect_point[3]*sa,intersect_point[3]*ca+intersect_point[1]*sa
					u=flr(u/1.5)
					v=flr(v/1.5)
					if( (u+v)%2==0)then
						color=texture_color1
					else
						color=texture_color2
					end
				end
				
				
				
				if(shadow_t!=false)then
					local occlusion = 0--mid(shadow_t/.4,0,1)*.5
					bright*=occlusion --pset(i-1,j-1,15)
				end
				bright = (1-ambient)*bright+ambient

				
				if(object.reflect>0)then --reflective
					local reflect_direction = vec3_sub(iray.direction,vec3_scale(inormal, 2*vec3_dot(inormal,iray.direction)))
					local reflect_origin=intersect_point
					local reflect_ray=new_ray(reflect_origin,reflect_direction)
		
					reflect_color,reflect_bright=render_ray(reflect_ray)
					--bright*=rbright
					--color=rcolor
					
					color=  vec3_add( vec3_scale(color,1-object.reflect),vec3_scale(reflect_color,object.reflect))
					bright= (bright*(1-object.reflect))+(reflect_bright*object.reflect)
				end
				
				--return color,bright
				--step=1
				--rectfill(i,j,i+step-1,j+step-1,color_ramp[color][flr(bright*127)])
				
		else
				--sky color
				color=sky_color
				bright=1-mid(iray.direction[2],0,1)
				--bright=.5
				--rectfill(i,j,i+step-1,j+step-1,color_ramp[4][j])
		end
	return color,bright
end


function rotate_point(point,centroid,a)
	local sa=sin(a)
	local ca=cos(a)
	

	local tp1=vec3_sub(point,centroid)
	tpr={tp1[1]*ca-tp1[3]*sa,tp1[2],tp1[3]*ca+tp1[1]*sa}
	tp1=vec3_add(tpr,centroid)
	return tp1
end

function pause(n)
	for i=1,n do flip() end
end

function _init()

	--init_rgb_array()

	cls()
	--init_color_ramp()
	cur_frame=0
	add_new_colors()
	--while(true)do
	--	
	--	pause(60)
	--end
	object_list={}
		
		for i=1,6 do
			local v=flr(rnd(3))
			ball_color={rnd(.8)+.2,rnd(.8)+.2,rnd(.8)+.2}
			ball=new_sphere({rnd(3)-1.5,rnd(2)-1,rnd(3)+2},rnd(.4)+.4,ball_color)
			ball.reflect=flr(rnd(4))/4
		end
		
		--new_sphere({-1,0,3},1,-2)
		--new_sphere({1,0,3},1,12)
		
		light_dir = vec3_unit({rnd(1)-.5,rnd(1),-rnd(1)+.25})
		ground=new_plane({0,1,0},1,{1,1,1})
		ground.texture=1
		ground.reflect=.15
		texture_color1={1,0,0}--{rnd(.8)+.2,rnd(.8)+.2,rnd(.8)+.2}
		texture_color2={1,1,1}--{rnd(.8),rnd(.8),rnd(.8)}
		sky_color={rnd(.8)+.5,rnd(.8)+.5,rnd(.8)+.5}
		
		pattern_angle=rnd(1)
		sa=sin(pattern_angle)
		ca=cos(pattern_angle)
	
	local step=1
		for j=0,127,step do
			for i=0,127,step do
				--computer primary ray direction
				local iray=new_ray({0,0,0},vec3_unit({(i-64)/64,(-j+64)/64,1}))
				color,bright=render_ray(iray)
				bright=mid(bright,0,1)
				--rectfill(i,j,i+step-1,j+step-1,color_ramp[color][flr(bright*127)])
				--b1=pico_palette[color][1]*bright
				--b2=pico_palette[color][2]*bright
				--b3=pico_palette[color][3]*bright
				color=vec3_scale(color,bright)
				if(not btn(4))then plot_color_mode3(i,j,color)else
				 plot_color_mode2(i,j,color)
				end
				--for sx=0,step-1 do
				--	for sy=0,step-1 do
				--		
				--	end
				--end
				--print(t,i,j,8)
			end
			--if(cur_frame==1 and j%127==0)flip()--not sure why this allows the display to partially update on all lines
			flip()
		end
		
	memcpy(  0x4300,0x6000, 4096 )
	memcpy(  0x2000,0x6000+4096, 4096 )
end


function _update60()

		
		
end

function _draw()
	--cls()
	cur_frame+=1
	if(cur_frame%2==0)then
		spr(0,0,0,16,16)
	else
		memcpy(0x6000,0x4300,4096)
		memcpy(0x6000+4096,0x2000,4096)
		
		
	end
	----light_dir[1]=sin(cur_frame/30)*.5
	----light_dir[2]=sin(cur_frame/45)*.25+.5
	----light_dir[3]=sin(cur_frame/80)*.4
	----light_dir=vec3_unit(light_dir)
	--
    --
	--cls()
	--spr(0,cur_frame%2,0,16,16)
	
	

end
__gfx__
11111111999999999999999999999999999999999999976656778777877788770000000000000000000000000000000000000000000000000000000000000000
17777777999999999999999999999999999799999999977656778777877788770000000000000000000000000000000000000000000000000000000000000000
177777779999999999999999999999955d9799999979976d56778777877788770000000000000000000000000000000000000000000000000000000000000000
1777777799999999999999999999995001d799999979976556778777877788770000000000000000000000000000000000000000000000000000000000000000
17777777999999999999999999979d1100d7997999799765d6778777877788770000000000000000000000000000000000000000000000000000000000000000
17777777999999999999999d5ddddd5001d7997997799765d7778777877788770000000000000000000000000000000000000000000000000000000000000000
17777777999999999999999d5d5ddd5100d79979977999d5d7778777877788770000000000000000000000000000000000000000000000000000000000000000
17777777999999999999999ddddd555510679979977999d587778777877788770000000000000000000000000000000000000000000000000000000000000000
999999999999999999999999dd5105d555679979977999dd87778777877788770000000000000000000000000000000000000000000000000000000000000000
99999999999999999999999ddd1015d5d55999777779995887778777877788770000000000000000000000000000000000000000000000000000000000000000
999999d9999999999999999ddd515d55dd5d997797799d5887778777877788770000000000000000000000000000000000000000000000000000000000000000
999999d9999999999d99999ddd555555d655d777979995d787778777877788770000000000000000000000000000000000000000000000000000000000000000
999999d9999999999999999dddd6d5556d1556799799d56787778777877788770000000000000000000000000000000000000000000000000000000000000000
99d99999999999999999999dd5566dd66d56667999995d7787778777877788770000000000000000000000000000000000000000000000000000000000000000
99d99999999999999999999d555ddd666d6677799999567787778777877788770000000000000000000000000000000000000000000000000000000000000000
9d9999d999d999999999999d5555dd6d666667799995877787778777877787770000000000000000000000000000000000000000000000000000000000000000
d99999d99999999999999999955ddddd6666676d99dd877787778777877787770000000000000000000000000000000000000000000000000000000000000000
99999999999999999999999776dddddddddd66dd9dd8877787778777877788770000000000000000000000000000000000000000000000000000000000000000
999999d9999999999999999766dddddddddd555dd588877787778777877788770000000000000000000000000000000000000000000000000000000000000000
99999dd99999999779999999ddddddd555555555dd87877787778777877788770000000000000000000000000000000000000000000000000000000000000000
d9999999999999997977797955dddd5555511155d677877787778777877788770000000000000000000000000000000000000000000000000000000000000000
dd99d99999999999999779795555dd55511111555677877787778777877788880000000000000000000000000000000000000000000000000000000000000000
99dd999999d999999997997d5515dd51110111555677877787778777887788880000000000000000000000000000000000000000000000000000000000000000
999d9999999999999997999d5515ddd5000015555d77877787778877888888880000000000000000000000000000000000000000000000000000000000000000
9999dd999d9999999997999d551ddddd5000566ddd77877788778877888888880000000000000000000000000000000000000000000000000000000000000000
99d999d99d9999999999999d515d6dddd55d67776d78877788778888888888880000000000000000000000000000000000000000000000000000000000000000
99999999dd99999999999999d15666ddddd666766d78877788788888888888880000000000000000000000000000000000000000000000000000000000000000
9999999799dd99d999979d5555d6666dddddd66d5588877788888888888888880000000000000000000000000000000000000000000000000000000000000000
999999999999ddd99999955555d6666dddd555511588878888888888888888880000000000000000000000000000000000000000000000000000000000000000
99999999999779999dd9d5dd99dd666ddd51100115d8888888888888888888880000000000000000000000000000000000000000000000000000000000000000
9999999999977977797799779795d66ddd5111111558888888888888888888880000000000000000000000000000000000000000000000000000000000000000
999999997997799779777977979dd66ddd5511111558888888888888888888880000000000000000000000000000000000000000000000000000000000000000
999999977997797779777977999dd666ddd55111155d888888888888888888880000000000000000000000000000000000000000000000000000000000000000
99d999d99999999999999999999dd666dddd5551115d888888888888888888880000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddd66666dddd555115dd8888888d888888888880000000000000000000000000000000000000000000000000000000000000000
66dddddddddddddddddddddddddd6666666ddd55515ddddd8888dddddddddddd0000000000000000000000000000000000000000000000000000000000000000
6dddddddddddddddddddddddddd666666666dd55555dddd88888d888888888880000000000000000000000000000000000000000000000000000000000000000
6666666666666666666666666dd666666666ddd5555dddd888888888dd88dd880000000000000000000000000000000000000000000000000000000000000000
6666666666666666666666666dd666666666ddd55558888888888888888888880000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666dddd666666666ddd5555dd88888888888888888880000000000000000000000000000000000000000000000000000000000000000
dddddddddddddd6d6ddddddddd6666666666ddd5555dd88888888888888888880000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddd666666666ddddd555ddd8888888888888888880000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddd66666666dddddd555ddd8888888888888888880000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddddddddddddd66666666ddddddd555ddd888d888888888888880000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddd8dddd6666666ddddddd5555ddddddd888888888888880000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddddd88d888ddd666666dddddddd555ddddddd8d8888888888870000000000000000000000000000000000000000000000000000000000000000
dddddddddddd8ddd888dd8885d66666ddddddddd555dddddddddddd8ddd888780000000000000000000000000000000000000000000000000000000000000000
dddddddddd88888d8888888855d666dddddddddd55d8dddddddddddddd8888880000000000000000000000000000000000000000000000000000000000000000
88d88dddd888888888888888d1d66ddddddddd5115d88ddddddddddd888888880000000000000000000000000000000000000000000000000000000000000000
88888dd888888d888888d888d15dddddddddd51115888dddd8888888888888870000000000000000000000000000000000000000000000000000000000000000
8888888888888888888888888115dddddddd51110d8888d888888888888888770000000000000000000000000000000000000000000000000000000000000000
8888888888888888888888ddd50155dddddd51111878888888888888888887770000000000000000000000000000000000000000000000000000000000000000
88888d888888888888888dd88d10015d66dd11105878888888888888888887780000000000000000000000000000000000000000000000000000000000000000
8888888888888888888888888885001d666d1110d888888888877888888888880000000000000000000000000000000000000000000000000000000000000000
8888888888888888888888888888501d666d11058888888888888888888888880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888d55666610188888888888888888888888880000000000000000000000000000000000000000000000000000000000000000
888888888888888888888888888888dd6666d15888888888888888888dd888880000000000000000000000000000000000000000000000000000000000000000
8888888888888888888888888888885d66666dd888888888888888888dd888880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888d5d66666dd8888888888888888888dd88880000000000000000000000000000000000000000000000000000000000000000
8888888888888888888888888888dd5d6dddddd88888888888888888888dd8880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888ddddd55555555d66dddddd888888888888888dd880000000000000000000000000000000000000000000000000000000000000000
888888888888888888888ddddddd55555555ddddddddddd88888888888888d880000000000000000000000000000000000000000000000000000000000000000
888888888888888888888888ddddddddddddd55dddd8888888888888888888880000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888880000000000000000000000000000000000000000000000000000000000000000
__label__
535553555353535353535353255325531513155315251523152515251525152515151525152515251525155d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
d5ddd5ddd5ddd5ddd5d5d5d555d555d555d555d55555555555555555555555555555555555555555555555d5555555d555d555d555d5d5ddd5ddd5ddd5dddddd
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
ddddddddddd5ddd5d5d5d5d5d5d5d5d5d555d5555555555555555555555555555555555555555555555555555555d5d5d5d5d5d5d5d5d5d5d5d5dddddddddddd
5ddd5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd
ddddddddddddd5ddd5ddd5ddd5d5d5d5d5d555d555d555d555d555d555d5555555d5555555d555d555d555d555d555d5d5d5d5ddd5ddd5ddd5ddd5dddddddddd
dd5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
ddddddddddddddddddddddd5ddd5d5d5d5d5d5d5d5d5d555d555d555d555555555555555d555d555d555d5d5d5d5d5d5d5d5d5d5ddd5dddddddddddddddddddd
5ddd5ddd5ddd5ddd5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5ddd
ddddddddddddddddddddddddd5ddd5ddd5d5d5ddd5d5d5d555d555d555d555d555d555d555d555d555d5d5d5d5d5d5ddd5ddd5ddd5dddddddddddddddddddddd
dddddddddd5ddd5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5ddddd
ddddddddddddddddddddddddddddddddddd5ddd5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5dddddddddddddddddddddddddddd
dddddddddddd5ddd5ddd5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5ddd5ddddddddddd
ddddddddddddddddddddddddddddddddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5d5d5ddd5d5d5ddd5ddd5ddd5ddd5ddd5dddddddddddddddddddddddddddddddddd
dddddddddddddddddddddd5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddd5ddd5ddd5ddd5d5d5ddd5d5d5ddd5ddd5dddddddddddddddddddddddddddddddddddddddddddddddd
ddd6ddd6dddddddddddd5ddd5ddd5ddd5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5ddd5ddd5dddddddddd6ddd6ddd6
ddddddddddddddddddddddddddddddddddddddddddddddddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dddddddddddddddddddddddddddddddddddddddddddddd
d6d6d6d6dddddddddddddddddddddddddd5ddd5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5dddddddddddddddddd6ddd6ddd6d6
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d6d6d6d6ddd6ddd6ddd6dddddddddddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5d5d5d5d5d5d5ddd5ddd5ddd5ddd5ddd5ddd5dddddddddd6ddd6ddd6ddd6d6d6d6d6
dd6ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd6d
d6d6d6d6d6d6d6d6d6ddd6dddddddddddddddddddddddd5ddd5ddd5ddd5d5d5ddd5d5d5ddd5ddd5dddddddddddddddddddddddddd6ddd6ddd6d6d6d6d6d6d6d6
6ddd6dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd55555dddddddddddddddddddddddddddddddddddddddd6ddd
d6d6d6d6d6d6d6d6ddd6ddd6ddd6ddd6ddddddd6dddddddd5ddddddd5ddd5ddd5ddd5ddd5ddd15151515155dddddddd6ddd6ddd6ddd6d6d6d6d6d6d6d6d6d6d6
dd6ddd6ddd6ddd6dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd55111111151515555dddddddddddddddddddd6ddd6ddd6ddd6ddd6d
d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6ddd6dddddddddddddddddddddddddddddddddd15111111151515151d5dd6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6
6d6d6d6d6d6d6d6d6ddd6ddddddddddddddddddddddddddddddddddddddddddddddddd5111111111111155555555dddddddddddddddd6ddd6ddd6d6d6d6d6d6d
d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6ddd6ddd6ddd6ddd6ddd6ddd6ddd6ddd6d515011501151515155d555d5dd6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6
6d666d666d6d6d6ddd6ddd6ddd6ddd6ddddddddddddddddddddddddddddddddddddd5111111111111155555555d5d5dddd6ddd6ddd6ddd6ddd6d6d6d6d666d66
d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6ddd6d515151515151515155d5d5d5d5d5dd6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6
6666666d666d6d6d6d6d6d6d6d6d6ddd6ddddddddddddddddddddddddddddddddd5151111111515155555555dddddddd6ddd6d6d6d6d6d6d6d6d6d6d66666666
d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6dd1515151515155d155d5d5d5ddd5dddd6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6
666666666d666d666d666d666d6d6d6ddd6ddd6ddd6ddd6ddd6ddd6ddd6ddd6dd55551555155555555d5d5dddddddddddd6d6d666d666d666d666d666d666666
d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d655151515555d5d5d5d5d5dddd6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6
666666666666666666666666666d666d6d6d6d6d6d6d6d6d6d6d6d6d6ddd6d6d555555555555d5dddddddddddddd6ddddd6d666d666d66666666666666666666
d666d666d666d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6dd5d5d5d5d5d5d5dddddd6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d666d666d666d666
66666666666666666666666666666d666d666d666d666d666d666d6d6d6d6d6555d5d5dddddddddddd6ddd666d666d666d666d66666666666666666666666666
66666666666666d666d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6dd5d5d5dddd6d6d6d6d6d6d6d6666666d6d6d6d6d6d6d6d6d666d666d666666666
66666666666666666666666666666666666666666666666d666d666d666d66dddddddddd6d6d6666666666666666666666666666666666666666666666666666
6666666666666666d666d666d666d666d6d6d666d6d6d6d6d6d6d6d6d6d6d6dd5dd6d6d6d6d6d666666f666f6f6f6666d6d6d666d666d666d666666666666666
666666666666666666666666666666666666666666666666666666666d6666dddd6d6d6666d5222552ddd2d2dd46666666666666666666666666666666666666
6666666666666666666666666666666666d666d6d6d666d6d6d6d6d6d6d6d6d6d6d666055d5d551d155d5424d4d4276f66d66666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666dd666625522255252255d2524dd44d646666666666666666666666666666666666
666f666f666f666f666f666666666666666666666666d666d666d666d666d6d6d61d1d55155d1555155d542624d4262666d66666666f666f666f666f666f666f
666666666666666666666666666666666666666666666666666666666666666662d2555225222555522dd2444d646d4266666666666666666666666666666666
6f6f6f6f6f6f6f6f6f666f666f666666666666666666666666666666666666d6651d5d555d525d5d15242dd6d426d42d266666666f666f666f6f6f6f6f6f6f6f
66666666666666666666666666666666666666666666666666666666666666d6155222255521222222224ddd644464d256666666666666666666666666666666
6f676f676f676f676f676f67666f666f666f666f666f666f666f666f666f6666115552151215121d5d242dd6d624d424566f6f67666f6f676f676f676f676f67
66f666f666f666f6666666f66666666666666666666666666666666666666666111551555121255555ddd244426d424d666666f6666666f666f666f666f666f6
6767676767676767676f6767676f676f6f6f676f6f6f6f6f6f6f6f6f6f6f6f66110515151512555d5d5dd42424d6d4556f6f676f676f67676767676767676767
f6f6f6f6f6f6f6f6f666f6f6f666f6666666f6666666666666666666666666662111255555555555d5ddd24244dddd266666f666f666f6f6f666f6f6f6f6f6f6
67676767676767676767676767676f676f676f15155d6f676f676f676f676f67d10101551515155d5d5d242424dd555767676767676767676767676767676767
f67ff67ff67ff676f676f676f67666f666f11151515555f666f666f666f666f6651111555121215555dd22424242d2f666766676f676f676f67ff67ff67ff67f
6767676767676767676767676767676767151515151d5d5d676767676767676767110515010215155d542424dd25566767676767676767676767676767676767
7f7f7f767f767f767f767f767f7676f6711151515555d511d6f6f6f6f6f6f6f6f615115011111122222dddddd222d6f676f676f67f767f767f767f767f7f7f7f
67676767676767676767676767676767151515151d5d010101676767676767676765115101151115125d5d5d1216676767676767676767676767676767676767
7f777f777f777f77767f7f77767f7f711151115555d11111117f767ff67f7655555511155011112225d555d5257f767f767f7f77767f7f7776777f777f777f77
67676767676767676767676767676765151515155d0101011117676767671515155d5d01551215125d5d5d1d1767676767676767676767676767676767676767
77777777777f7777777f7777777f77111111555551111111111f777f7f71111155ddddd5115555555555255f7f7f777f777f7777777f7777777f777777777777
67f767f767f767f767f767f767f767151515151d11150115151767f7670101151d5dd6dd57151515121567f767f767f767f767f767f767f767f767f767f767f7
777777777777777777777777777777511155515111511111111177777011111155dddd6dd5777777777777777777777777777777777777777777777777777777
f7f7f7f7f7f7f7f7f7f7f7f7f7f7f71101111511011111111501f7f7f10101151d5dd6d65df7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
7777777777777777777777777777771111111111111111111111777770101111555dddddd5555d77777777777777777777777777777777777777777777777777
f777f777f777f777f777f777f777f71101111111011511150107f77701010115155d5ddd5d551556f777f777f777f777f777f777f777f777f777f777f777f777
2d22d2d222dd2d2dd2d2d22ddd22dd111011111111111011111d2dd210101011115555ddd55155dd6dd22ddd2ddd22ddd22d2d2dddd2ddd22ddd22d2d2dd2d2d
dd2224dddd5d242ddd2dd422dd5d2dd1010101011501010101022ddd0101010115155d5d55155d5ddd5dd4dd222ddd22d222ddd22d5224ddd22d242ddd222d22
2ddddd2222dddd2ddddd2222ddddddd1111111111010101110222ddd10101011111155555555dddd66ddddddddd22222dddd2dddd22222ddddddddd22222dddd
5ddd5d242ddd222422dd5ddd22242dd40101010101010101012422245101010101151515155dd6d6d62422dd222422dd5ddd22242dd422242ddd5dd422242d24
dddd22222222ddddddd2dddddddd222221111011111110111dd222222011101110111151116d6666662dddddddddddddddd22222222ddddddddddddddd222222
2222225ddd5ddd5222222222dd5dd222220101010101010222222d5dd101010101011515151d26d6dd5ddd22222ddd5ddd5d22222222225ddd52222ddddddddd
2222222222ddddddddddd222dddddddd22221010101010dddddddd222d101010101111111122224242dddddd222dddddddd22222222222ddddddddddd2222ddd
5ddd5d242224222422dd5ddd5ddd522d5ddd5ddd01d42224222422245dd1010101010101121d56d6dd242224222422dd5ddd5ddd522d5ddd5ddd5dd422242224
2dddddddddddddd22222222222222ddddddddddddddddddddddddddddd221011101010155522d242dddddddddddddddddddd222222222222222ddddddddddddd
5d5ddd5d5d5d2222222ddd5d5d5d222222222222222d5d11015d6d5d5d522201010101051215242512222222222ddd5d5d5ddd5d5d522222222ddd5ddd222422
222222222ddddddddddddddddd22222222222222222d11111055551222222ddddddddd10112222212222222222222222ddddd222222222222ddddddddddddddd
222422dd5ddd5ddd5ddd5ddd22242ddd5ddd5ddd5d110101011515552221010d5ddd5dd10215121d522422dd5ddd5ddd5ddd2224222422242224222d5ddd5ddd
22ddddddd22222222222222ddddddddddddddddd211110111011115d10111011335111dd2222222222222dddddddddddddddddddd222222222222222222222dd
222222222222222222222d5d5d5d5d5d5d5d5d52dd1511010105150101055d3d3d3d010101222222222222225d5d5d5d5d5d5d5d5d5d5d222222222222222d5d
22222222222222222222ddddddddddddddddddddd55111101111551055555333d3d3d1111122222222222222222ddddddddddddddddddddddddddddddddddddd
22222224222222242215151515151104122222dd5515111501151115151d3d3b3b3b3d241222222412222224122222dd5d5d5ddd522222242224222d5ddd5ddd
222222222222215111111111111111111011116dd555555555d51151515533bbbbbbb3d2222222222222222222222222d222222222222222222222222222dddd
5d5d5d5d5d5515110101020101010201010105dd5d5d5d5d5d5d151515133b3bb6b6bb3d121212122222225d5d5d5d5d5d5d2222222222222222222222222422
ddddddddddd1111111111111111111111111126dddd5d5d5ddd111115553ddbbbb6bbbd3322225d5ddddddddddddddddddddddd2222222222222222222222222
5d5d5d5d5d5d0102010201020102010201020dd6dddd5dddddd10115155d3bb6b6b6bb3d321d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5dd422242224222422242224
dddddddddd2222222211111111111111111115266d6ddddddd111111515533bbbb66bbbd322225d5d5ddd5ddddddd5dddddddddddddddd222222222222222222
5d5d5d5d5222222222210101010101010101025266d6d6d6d601051515153d3bb6b6b6bb3d12125d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5222222222222222
ddddddd2222222222222111111111111111115522526666666111111515533bbbb6b6bb3d3222222d5dddddddddddddddddddddddddddddddddd222222222222
5d5d5d241222222412222222010105151115055d5d5512245101011515155d3bbbb6bbbb3d1212121d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5d5d5dd422242224
d5dd222222222222222dddddd5dd111111111555555555dd20111111115553ddbbbbbbb333222222212dd5ddd5ddddddd5dddddddddddddddddddddddd222222
5d2222222d5d5d5d5d5d5d5d5d5d5d5d151501555d5d5d552101011515151d3d3b3bbb3d3d12121212125d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd22
2dddddddddddddddddddddddddd5dddddd111155555555222010111111515553d3d3b3d335212222222222ddddd5dddddddddddddddddddddddddddddddddddd
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5101155d1225010101151515155d3d3d3d3d55121212122212225d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5ddd5224
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd55d555d12121101110111151515555333335522221222222222225ddd5ddd5ddd5dddddddddddddddddd22222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d521212110101011515151515555d521212121222122212222d5d5d5d5d5d5d5d5d5d5d5d52222222222222
ddddddddddddddd5ddddddd5ddd5ddd5ddd555555552222222221011111111515555222222212222222222222222dddddddddddddddddd222222222222222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d52121212121212111515121212122212221222122212221222125d5d5d5d5d522222241222222422242224
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd55555d22122212222222122222222222222222222222222222222222222d5ddd222222222222222222222222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d52121212121212121212121212121212122212221222222212222252122222222222222222222222222222
ddd5ddddddd5ddd5ddd5ddd5d5d5ddd5d5d5dd555551222222222222222222222222222222222222222222222225ddddddd22222222222222222222222222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d155d5d521212121212121212121212121212122212221222125d5d5d5d5d5d5d1222122212222224222422242224
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5d55555555221222122212222222222222222222222222225ddd5ddd5ddd5ddd5ddd522222222222222222222222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d555d555d52121212121212121212121212121222121d5d5d5d5d5d5d5d5d5d5d5d5d52222222222222222222222222
ddd5ddd5ddd5ddd5ddd5d5d5ddd5d5d5d555555555512221222122222222222222222222d5d5d5d5d5d5d5d5ddd5ddd5ddddddddd22222222222222222222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d155d555d155212120212121212121212121d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5222241222222422242224
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd555555555551212221222222212222d555d5d5ddd5d5d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd22222222222222222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d555d555d555d521212121222121d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d222222222222222222
d5d5ddd5d5d5ddd5d5d5d5d5d5d5d5d55555555555512121212125d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5ddddddddddd22222222222222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d555d155d15520212555d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5224222422242224
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd55555555555555555555555d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddddd2222222222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d555d1212155d555d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d222222222222
d5d5d5d5d5d5d5d5d5d5d5d5d5d5d555d2212121212555555555d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5dddddddddddddddddd2222222222
5d5d5d5d5d5d5d5d5d5d5d5d5d5d521212120212021d555d155d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5dd422242224
d5ddd5ddd5d5d5ddd5d5d5dd2222222221222121212555555555d5d555d5d5d555d5d5d5d5d5d5ddd5d5d5ddd5ddd5ddd5ddd5ddd5ddddddddddddddd2222222
5d5d5d5d5d5d5d5d5d522212121212121212121212055d555d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d222222
d5d5d5d5d5d5d5222222222222222222222222212125555555d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5dddddddddddddddddddddddd2222
5d5d5d5d52221222122212221222121212121212021d155d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5d24
d5ddd2222222222222222222222222222122212121255555d5d555d555d555d5d5d555d5d5d5d5d5d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddddddddddddddddd2
221212121212121212121212121212121212121212155d555d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5d
222222222222222222222222222222222222222221255555d5d5d5d5d5d5d5d5d5d5d5d5d555555555d5d5d5d5d5d5d5ddd5dddddddddddddddddddddddddddd
1222122212221222121212221212122212121212121d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5ddd
22222222222222222222222222222222222221222125d5d555d555d555d555d555d5d5d5555555d555d555ddd5ddd5ddd5ddd5ddd5dddddddddddddddddddddd
1212121212121212121212121212121212121212121d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5d
22222222222222222222222222222222222222222225d5d5d5d5d5d5d5d5d5d5d5d55555555555555555d555d5d5ddd5d5d5dddddddddddddddddddddddddddd
1222122212221222122212121222121212121212121d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5ddd5ddd
2222222222222222222222222222222222222222222555d555d555d555d555d555d5555555d555d555d555d555ddd5ddd5ddd5ddd5ddd5dddddddddddddddddd
1212121212121212121212121212121212121212121d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5ddd5d
22222222222222222222222222222222222222222225d5d5d5d5d5d5d5d5d5d5d5555555555555555555d555d5d5d5d5ddd5dddddddddddddddddddddddddddd
