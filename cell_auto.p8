pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--cellular automata

screen = {}

p=0.08

update_buffer_total=2
update_buffer=0
update=true

height=50
width=50

function _init()
    cls()
    for i=1,height do
        add(screen,{})
        for j=1,width do
            px=rnd(1)
            if(px<p) then
                screen[i][j]=1
            else
                screen[i][j]=0
            end
        end
    end
    new_screen=screen
end

function _update()
    if(update_buffer<update_buffer_total) update=false update_buffer+=1
    if(update_buffer==update_buffer_total) update=true update_buffer=0
    if(update) then
        cls()
        for i=2,height-1 do
            for j=2,width-1 do
                --updating cell states
                sum=screen[i-1][j-1]+screen[i-1][j]+screen[i-1][j+1]+screen[i][j-1]+screen[i][j+1]+screen[i+1][j-1]+screen[i+1][j]+screen[i+1][j+1]
                if(screen[i][j]==0 and sum==3) new_screen[i][j]=1
                if(screen[i][j]==1 and (sum<2 or sum>3)) new_screen[i][j]=0

                --drawing new frame
                if(new_screen[i][j]==1) pset(i-1,j-1,7)
                if(new_screen[i][j]==0) pset(i-1,j-1,0)

                screen=new_screen
            end
        end
    end
end

--function _draw()
    
--end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
