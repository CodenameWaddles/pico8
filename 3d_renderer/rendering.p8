pico-8 cartridge // http://www.pico-8.com
version 36
__lua__

camera_speed=0.1
camera_rotation_speed=0.01
red_palette = {2, 8, 14}
orange_palette = {4, 9, 10}
grey_palette = {5, 6, 7}

house={}
house.vertices={{1, 1, 1},
{-1, 1, 1},
{-1, -1, 1},
{1, -1, 1},
{1, 1, -1},
{-1, 1, -1},
{-1, -1, -1},
{1, -1, -1},
{0, 2, 0}}
house.faces={{1, 2, 3},
{1, 3, 4},
{2, 6, 7},
{2, 7, 3},
{3, 7, 8},
{3, 8, 4},
{4, 8, 5},
{4, 5, 1},
{5, 7, 6},
{5, 8, 7},
{9, 2, 1},
{9, 6, 2},
{9, 5, 6},
{9, 1, 5}}
house.col = red_palette
initial_cam_dir = {{0},{0},{1}}
cam = {pos={{0},{0},{-3}}, dir=initial_cam_dir}
cam_matrix = {{-100, 0, 64}, {0, -100, 64}, {0, 0, 1}}

light_dir = {{-1}, {1}, {-1}}

function _init()
    light_dir = normalize(light_dir)
    theta = 0
    objects={--house, 
    make_cube(3,0,0,0.5, grey_palette), 
    make_icosa(1,2,3, red_palette)}
    foreach(objects, function (obj)
        calculate_object_normals(obj)
    end)
    x = 40
    y = 15
end

function _update()
    world_matrix = {{1, 0, 0, -cam.pos[1][1]}, {0, 1, 0, -cam.pos[2][1]}, {0, 0, 1, -cam.pos[3][1]}}
    move_camera()
    world_matrix = matrix_product(rotation_matrix_y(theta), world_matrix)
    projection_matrix = matrix_product(cam_matrix, world_matrix)
    projected_objects={}
    rendered_objects = filter_rendered(objects)
    foreach(rendered_objects, function (obj)
        add(projected_objects, project_object(obj))
    end)
end

function _draw()
    cls()
    foreach(projected_objects, function (obj)
        draw_projection(obj)
    end)
    --fill_triangle_scanline({{20}, {20}}, {{x}, {y}}, {{0}, {60}}, 7)
    --fill_triangle_barycentric({{0}, {0}}, {{50}, {15}}, {{0}, {10}}, 7)
    --print(stat(1), 8)
    --print("cam x="..cam.pos[1][1]..", y="..cam.pos[2][1]..", z="..cam.pos[3][1])
    --print("cam dir x="..cam.dir[1][1]..", y="..cam.dir[2][1]..", z="..cam.dir[3][1])
    --local obj_dir = {{objects[1].vertices[1][1] - cam.pos[1][1]}, {objects[1].vertices[1][2] - cam.pos[2][1]}, {objects[1].vertices[1][3] - cam.pos[3][1]}}
    --print_matrix(obj_dir)
    --print("dot prod = "..dot(obj_dir, cam.dir))
    --line(64, 64, 64-10*cam.dir[1][1], 64-10*cam.dir[3][1], 8)
    --line(64, 64, 64-5*obj_dir[1][1], 64-5*obj_dir[3][1], 12)
end

function move_camera()
    local transaltion = {{0}, {0}, {0}}
    if(btn(0)) transaltion[1][1]+=camera_speed x-=1
    if(btn(1)) transaltion[1][1]-=camera_speed x+=1
    if(btn(2)) transaltion[2][1]+=camera_speed y-=1
    if(btn(3)) transaltion[2][1]-=camera_speed y+=1
    if(btn(4)) transaltion[3][1]+=camera_speed
    if(btn(5)) transaltion[3][1]-=camera_speed
    if(btn(0, 1)) theta += camera_rotation_speed
    if(btn(1, 1)) theta -= camera_rotation_speed
    transaltion = matrix_product(rotation_matrix_y(-theta), transaltion)
    cam.dir = matrix_product(rotation_matrix_y(-theta), initial_cam_dir)
    cam.pos = matrix_addition(cam.pos, transaltion)
end

-->8
--Drawing

function draw_projection(obj)
    local col = obj.col
    foreach(obj.faces, function (f)
        local v1 = obj.vertices[f[1]] v2 = obj.vertices[f[2]] v3 = obj.vertices[f[3]]
        local l = dot(light_dir, f[4])
        local color = col[1]

        if(l>=0) color = col[2]
        if(l>=0.8) color = col[3]
        
        --fill_triangle_barycentric(v1, v2, v3, color)
        --fill_triangle_scanline(v1, v2, v3, color)
        draw_edge(v1[1][1], v1[2][1], v2[1][1], v2[2][1], 7)
        draw_edge(v2[1][1], v2[2][1], v3[1][1], v3[2][1], 7)
        draw_edge(v3[1][1], v3[2][1], v1[1][1], v1[2][1], 7)
    end)
end

function draw_edge(x1, y1, x2, y2, col)
    if(not(on_screen(x1) and on_screen(y1) and on_screen(x2) and on_screen(y2))) return false
    local mask1 = get_vertex_screen_bitmask(x1, y1)
    local mask2 = get_vertex_screen_bitmask(x2, y2)
    if(mask1 & mask2 == 0) line(x1,y1,x2,y2,col) return true
    return false
end

function on_screen(x)
    return x>=-128 and x <= 256
end

function get_vertex_screen_bitmask(x, y)
    local mask = 0
    if(x>127) mask+=1
    if(x<0) mask+=2
    if(y<0) mask+=8
    if(y>127) mask+=4
    return mask
end

-->8
--Projection

function project_object(obj)
    local projected_vertices = {}
    local projected_faces = {}

    local vertices = obj.vertices
    
    --project vertices
    foreach(obj.vertices, function (v)
        add(projected_vertices, project_vertex(v))
    end)

    --filter back faces
    foreach(obj.faces, function (f)
        local v_dir = get_vector_from_points(cam.pos, get_point_matrix(vertices[f[1]]))
        if(dot(f[4], v_dir) < 0) add(projected_faces, f)
    end)

    return {vertices = projected_vertices, faces = projected_faces, col = obj.col}
end

function project_vertex(v)
    local proj = matrix_product(projection_matrix, {{v[1]}, {v[2]}, {v[3]}, {1}})
    return {{proj[1][1]/proj[3][1]}, {proj[2][1]/proj[3][1]}}
end

function filter_rendered(objects)
    local rendered = {}
    foreach(objects, function (obj)
        --local obj_dir = {{obj.vertices[1][1] - cam.pos[1][1]}, {obj.vertices[1][2] - cam.pos[2][1]}, {obj.vertices[1][3] - cam.pos[3][1]}}
        local obj_dir = get_vector_from_points(cam.pos, get_point_matrix(obj.vertices[1]))
        if(dot(obj_dir, cam.dir) > 0) add(rendered, obj)
    end)
    return rendered
end

-->8
--mesh utils

function calculate_object_normals(obj)
    local vertices = obj.vertices
    foreach(obj.faces, function (f)
        local n = calculate_face_normal(vertices[f[1]], vertices[f[2]], vertices[f[3]])
        f[4] = n
    end)
end

function calculate_face_normal(p1, p2, p3)
    local res = {}
    local v1 = get_vector_from_points(get_point_matrix(p1), get_point_matrix(p2))
    local v2 = get_vector_from_points(get_point_matrix(p1), get_point_matrix(p3))
    return normalize(cross(v1, v2))
end

function get_3d_AABB(vertices)
    local minX = vertices[1][1][1] local minY = vertices[1][2][1] local maxX = vertices[1][1][1] local maxY = vertices[1][2][1] local minZ = vertices[1][3][1] local maxZ = vertices[1][3][1]
    foreach(vertices, function (v)
        local x = v[1][1] y = v[2][1] z = v[3][1]
        if(x < minX) minX = x
        if(x > maxX) maxX = x
        if(y < minY) minY = y
        if(y > maxY) maxY = y
        if(z < minZ) minZ = z
        if(z > maxZ) maxZ = z
    end)
    return {{{minX}, {minY}, {minZ}}, {{maxX}, {maxY}, {maxZ}}}
end

function get_2d_AABB(p1, p2, p3)
    local minX = flr(min(p1[1][1], min(p2[1][1], p3[1][1]))) local minY = flr(min(p1[2][1], min(p2[2][1], p3[2][1])))
    local maxX = flr(max(p1[1][1], max(p2[1][1], p3[1][1]))) local maxY = flr(max(p1[2][1], max(p2[2][1], p3[2][1])))
    return {{{minX}, {minY}}, {{maxX}, {maxY}}}
end

function fill_triangle_barycentric(p1, p2, p3, col)
    local bb = get_2d_AABB(p1, p2, p3)
    
    for x=bb[1][1][1],bb[2][1][1] do
        for y=bb[1][2][1],bb[2][2][1] do
            local p = {{x}, {y}}
            if(edge_function(p1, p2, p) and edge_function(p2, p3, p) and edge_function(p3, p1, p)) pset(x, y, col)
        end
    end
end

function edge_function(a, b, p)
    return ((p[1][1] - a[1][1]) * (b[2][1] - a[2][1]) - (p[2][1] - a[2][1]) * (b[1][1] - a[1][1]) >= 0)
end

function fill_triangle_scanline(p1, p2, p3, col)
    --get start point
    local index = 1
    if(check_if_triangle_extremum(p1, p2, p3)) pstart = p1 index = 1
    if(check_if_triangle_extremum(p2, p1, p3)) pstart = p2 index = 2
    if(check_if_triangle_extremum(p3, p2, p1)) pstart = p3 index = 3

    --get end point
    if(index == 1) then
        if(abs(p1[2][1] - p2[2][1]) > abs(p1[2][1] - p3[2][1])) then
            pend = p2
            pint = p3
        else
            pend = p3
            pint = p2
        end
    elseif(index == 2) then
        if(abs(p2[2][1] - p1[2][1]) > abs(p2[2][1] - p3[2][1])) then
            pend = p1
            pint = p3
        else
            pend = p3
            pint = p1
        end
    elseif(index == 3) then
        if(abs(p3[2][1] - p1[2][1]) > abs(p3[2][1] - p2[2][1])) then
            pend = p1
            pint = p2
        else
            pend = p2
            pint = p1
        end
    end

    local xdmain = (pend[1][1] - pstart[1][1]) / (pend[2][1] - pstart[2][1])
    
    local xd1 = (pint[1][1] - pstart[1][1]) / (pint[2][1] - pstart[2][1])
    
    local xd2 = (pend[1][1] - pint[1][1]) / (pend[2][1] - pint[2][1])
    

    local threshold = 0.01
    if(abs(pend[2][1] - pstart[2][1]) <= threshold) xdmain = pend[1][1] - pstart[1][1]
    if(abs(pint[2][1] - pstart[2][1]) <= threshold) xd1 = pint[1][1] - pstart[1][1]
    if(abs(pend[2][1] - pint[2][1]) <= threshold) xd2 = pend[1][1] - pint[1][1]

    

    local xstart = pstart[1][1]
    local ystart = pstart[2][1]

    local xend = pstart[1][1]
    local yend = pstart[2][1]

    local i = 0

    while(((abs(xend - pint[1][1]) >= 2) or (abs(yend - pint[2][1]) >= 2)) and i < 127) do
        line(xstart, ystart, xend, yend, col)
        xend += sgn(pint[1][1] - pstart[1][1]) * abs(xd1)
        yend += sgn(pint[2][1] - pstart[2][1])
        xstart += sgn(pend[1][1] - pstart[1][1]) * abs(xdmain)
        ystart += sgn(pend[2][1] - pstart[2][1])
        i+=1  
    end
    i = 0

    if(abs(yend - pend[2][1]) >= 2) then
        while(((abs(xend - pend[1][1]) >= 2) or (abs(yend - pend[2][1]) >= 2)) and i < 127) do
            line(xstart, ystart, xend, yend, col)
            xend += sgn(pend[1][1] - pint[1][1]) * abs(xd2)
            yend += sgn(pend[2][1] - pint[2][1])
            xstart += sgn(pend[1][1] - pstart[1][1]) * abs(xdmain)
            ystart += sgn(pend[2][1] - pstart[2][1])
            i+=1
        end
    else
        line(xend, yend, pend[1][1], pend[2][1], col)
    end

    --pset(pstart[1][1], pstart[2][1], 11) --start in green
    --pset(pint[1][1], pint[2][1], 9)
    --pset(pend[1][1], pend[2][1], 8) --end in red
    
end

function check_if_triangle_extremum(p1, p2, p3)
    return (p1[1][1] == min(p1[1][1], min(p2[1][1], p3[1][1])) or p1[1][1] == max(p1[1][1], max(p2[1][1], p3[1][1]))) and (p1[2][1] == min(p1[2][1], min(p2[2][1], p3[2][1])) or p1[2][1] == max(p1[2][1], max(p2[2][1], p3[2][1])))
end

function make_cube(x, y, z, r, col)
    local cube={}
    cube.vertices={{x+r, y+r, z+r},
    {x-r, y+r, z+r},
    {x-r, y-r, z+r},
    {x+r, y-r, z+r},
    {x+r, y+r, z-r},
    {x-r, y+r, z-r},
    {x-r, y-r, z-r},
    {x+r, y-r, z-r}}
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
    {5, 8, 7}}
    cube.col = col
    return cube
end

function make_icosa(x, y, z, col)
    icosa = {}
    icosa.vertices = {
        {x-0.525731, y, z-0.850651},
        {x+0.525731, y, z-0.850651},
        {x+0.525731, y, z+0.850651},
        {x-0.525731, y, z+0.850651},
        {x-0.850651, y-0.525731, z},
        {x-0.850651, y+0.525731, z},
        {x+0.850651, y+0.525731, z},
        {x+0.850651, y-0.525731, z},
        {x, y-0.850651, z+0.525731},
        {x, y-0.850651, z-0.525731},
        {x, y+0.850651, z-0.525731},
        {x, y+0.850651, z+0.525731},
    }
    icosa.faces = {
        {2 , 10,  1},
        {11,  2,  1},
        {6 , 11,  1},
        {5 , 6 , 1},
        {10,  5,  1},
        {9 , 3 , 4},
        {5 , 9 , 4},
        {6 , 5 , 4},
        {12,  6,  4},
        {3 , 12,  4},
        {12,  3,  7},
        {11,  12, 7},
        {2 , 11,  7},
        {8 , 2 , 7},
        {3 , 8 , 7},
        {12,  11, 6},
        {10,  9,  5},
        {8 , 3 , 9},
        {10,  8,  9},
        {2 , 8 , 10}}
    icosa.col = col
    return icosa
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

function get_vector_from_points(p1, p2)
    return {{p2[1][1] - p1[1][1]}, {p2[2][1] - p1[2][1]}, {p2[3][1] - p1[3][1]}}
end

function get_2d_vector_from_points(p1, p2)
    return {{p2[1][1] - p1[1][1]}, {p2[2][1] - p1[2][1]}}
end

function get_point_matrix(v)
    return {{v[1]}, {v[2]}, {v[3]}}
end

function dot(v1, v2)
    assert(#v1==#v2, "Dot product with wrong sizes")
    local res=0
    for i=1,#v1 do
        res+=v1[i][1]*v2[i][1]
    end
    return res
end

function cross(v1, v2)
    assert(#v1==#v2, "Dot product with wrong sizes")
    return {{v1[2][1]*v2[3][1] - v1[3][1]*v2[2][1]}, {v1[3][1]*v2[1][1] - v1[1][1]*v2[3][1]}, {v1[1][1]*v2[2][1] - v1[2][1]*v2[1][1]}}
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

function rotation_matrix_y(theta)
    return {{cos(theta), 0, sin(theta)},
            {0, 1, 0},
            {-sin(theta), 0, cos(theta)}}
end

function normalize(v)
    local mag = magnitude(v)
    return {{v[1][1]/mag}, {v[2][1]/mag}, {v[3][1]/mag}}
end

function magnitude(v)
    return sqrt(v[1][1]^2 + v[2][1]^2 + v[3][1]^2)
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
