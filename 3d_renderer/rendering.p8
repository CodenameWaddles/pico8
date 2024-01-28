pico-8 cartridge // http://www.pico-8.com
version 36
__lua__

camera_speed=0.1

cube={}
cube.vertices={{1, 1, 1},
{-1, 1, 1},
{-1, -1, 1},
{1, -1, 1},
{1, 1, -1},
{-1, 1, -1},
{-1, -1, -1},
{1, -1, -1},
{0, 2, 0}}
cube.faces={{1, 2, 3},
{1, 3, 4},
{1, 5, 6},
{1, 6, 2},
{2, 6, 7},
{2, 7, 3},
{3, 7, 8},
{3, 8, 4},
{4, 8, 5},
{4, 5, 1},
{5, 7, 6},
{5, 8, 7},
{9, 2, 1},
{9, 2, 6},
{9, 6, 5},
{9, 5, 1}}
objects={cube}
cam = {pos={0,0,-3}}
cam_matrix = {{-100, 0, 64}, {0, -100, 64}, {0, 0, 1}}

function _init()
    
end

function _update()
    move_camera()
    world_matrix = {{1, 0, 0, -cam.pos[1]}, {0, 1, 0, -cam.pos[2]}, {0, 0, 1, -cam.pos[3]}}
    projection_matrix = matrix_product(cam_matrix, world_matrix)
    projected_objects={}
    rendered_objects = filter_rendered(objects)
    foreach(rendered_objects, function (obj)
        add(projected_objects, project_object(obj))
    end)
end

function _draw()
    cls()
    --print(projected_objects[1].vertices[3][1][1])
    foreach(projected_objects, function (obj)
        draw_projection(obj)
    end)
    print(stat(1))
    print("cam x="..cam.pos[1]..", y="..cam.pos[2]..", z="..cam.pos[3])
end

function move_camera()
    if(btn(0)) cam.pos[1]+=camera_speed
    if(btn(1)) cam.pos[1]-=camera_speed
    if(btn(2)) cam.pos[2]+=camera_speed
    if(btn(3)) cam.pos[2]-=camera_speed
    if(btn(4)) cam.pos[3]+=camera_speed
    if(btn(5)) cam.pos[3]-=camera_speed
end

-->8
--Drawing

function draw_projection(obj)
    foreach(obj.faces, function (f)
        line(obj.vertices[f[1]][1][1], obj.vertices[f[1]][2][1], obj.vertices[f[2]][1][1], obj.vertices[f[2]][2][1])
        line(obj.vertices[f[2]][1][1], obj.vertices[f[2]][2][1], obj.vertices[f[3]][1][1], obj.vertices[f[3]][2][1])
        line(obj.vertices[f[3]][1][1], obj.vertices[f[3]][2][1], obj.vertices[f[1]][1][1], obj.vertices[f[1]][2][1])
    end)
end


-->8
--Projection

function project_object(obj)
    local projected_vertices = {}
    foreach(obj.vertices, function (v)
        add(projected_vertices, project_vertex(v))
    end)
    return {vertices = projected_vertices, faces = obj.faces}
end

function project_vertex(v)
    local proj = matrix_product(projection_matrix, {{v[1]}, {v[2]}, {v[3]}, {1}})
    return {{proj[1][1]/proj[3][1]}, {proj[2][1]/proj[3][1]}}
end

function filter_rendered(objects)
    local rendered = {}
    foreach(objects, function (obj)
        if(obj.vertices[1][3] > cam.pos[3]) add(rendered, obj)
    end)
    return rendered
end


-->8
--math utils

function matrix_addition(mat1, mat2)
    assert(#mat1 == #mat2 and #mat1[1] == #mat2[1], "Matrix addition with wrong sizes")
    local res={}
    for i=1,#mat1 do
        local line={}
        for j=1,#mat1[i] do
            add(line, mat1[i][j] + mat2[i][j])
        end
        add(res, line)
    end
    return res
end

function dot(v1, v2)
    assert(#v1==#v2, "Dot product with wrong sizes")
    res=0
    for i=1,#v1 do
        res+=v1[i]*v2[i]
    end
    return res
end

function matrix_product(mat1, mat2)
    --assert matrix sizes
    assert(#mat1[1] == #mat2, "Matrix product with wrong sizes")
    res={}
    for i=1,#mat1 do
        local line={}
        for j=1,#mat2[1] do
            c=0
            for k=1,#mat2 do
                c+=mat1[i][k] * mat2[k][j]
            end
            add(line, c)
        end
        add(res, line)
    end
    return res
end

function print_matrix(mat)
    for i=1,#mat do
        local line=""
        for j=1,#mat[i] do
            line = line..mat[i][j].." "
        end
        print(line)
    end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
