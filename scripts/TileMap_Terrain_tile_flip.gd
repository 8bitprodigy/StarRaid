#
#  Tilemap_Terrain by Chris DeBoy
#  Modified from original Script by Brian Jack
#  gau_veldt@hotmail.com
#  CC-BY-SA
#
tool
extends TileMap

# member variables here, example:
# var a=2
# var b="textvar"
var magic_random_max=pow(2,31)-1
var rs

var terrainMesh
var terrain
var surf
var chunkMap={}

var hm_data=[]
var hm_size
var hm_min
var hm_max
var hm_curseed

# Base tile
var cellTileMapBase={}
# Overlaid tile (w/alpha)
# TODO: Not yet used.
var cellTileMapOverlay={}
var cellTileMapAlpha={}

# chunk_size must be even and nonzero
export(bool) var ProceduralGen = true
export(int) var chunk_rings=0
export(int) var chunk_size=16
export var rseed=1338
export var height_scale=0.0
export var height_offset=0
export var smoothing=-1.5
export var clipDistance=320

# tileset texture
export(Material) var tileset_texture
var ts_width
var ts_height
var ts_skipw
var ts_skiph
var ts_tiles_per_row
var ts_tiles_per_col
var ts_total

var TILE_TL=0
var TILE_TR=1
var TILE_BL=2
var TILE_BR=3

# pixels between tileset cells
export(int) var tile_padding=0
# NB:
#
# Allows for space in the image between tiles to account for borders
# or repeating of the edge pixels to combat tile boundary artifacts
# due to UV rounding errors when texturing near a tile's edges.
#
# A tile padding of 1 indicates a 1px border around all tiles
# so a 64x64 tile is considered to take 66x66 in the image
# and the tile would be offset 1,1 within each 66x66 section
#
# eg:
#    tile (3x3 pixel)
#        123abc
#        456def
#        789ghi
#
#    These tiles tend to show artificts from the pixels
#    of neighbouring tiles when textured due to UV rounding errors near
#    the cell edges.
#
#    w/bounds padding (5x5)
#       11233aabcc
#       11233aabcc
#       44566ddeff
#       77899gghii
#       77899gghii
#
#    If the bounds-padded tiles encounter UV rounding error
#    while texturing a cell the errant UV's go into the padding
#    border rather than neighbouring tiles' pixels.

# width per tile in pixels
export(int) var tile_width=64
# height per tile in pixels
export(int) var tile_height=64
# total number of tiles
# (calculated from tileset_texture)
var tile_count=0

export(int) var mapScale = 1

# Generate terrain in-editor
export var displayTerrainInEditor=false setget build

#var heightmap = Image

func get_rand():
	if rs==null:
		rs=rand_seed(rseed)
	else:
		rs=rand_seed(rs[1])
	return -1.0+(2.0*float(rs[0])/float(magic_random_max))

func init_hm():
	hm_size=2
	hm_min=0
	hm_max=1
	if ProceduralGen:
		hm_data=[
			height_offset+get_rand()*height_scale,
			height_offset+get_rand()*height_scale,
			height_offset+get_rand()*height_scale,
			height_offset+get_rand()*height_scale,
		]
	else:
		hm_data=[
			height_offset*height_scale,
			height_offset*height_scale,
			height_offset*height_scale,
			height_offset*height_scale,
		]
	hm_curseed=rs[1]

func get_hmdata(x,y):
	return hm_data[y*hm_size+x]

func getChunkPG(x,y):
	# initialize terrain chunk at (x,y)
	var lo=min(x,y)
	var hi=max(x+1,y+1)

	# Expand the heightmap square one layer at a time until
	# chunk's points are contained within the expanded heightmap
	#
	# For landscapes a consistent generation loop must generate
	# the same landscape for a given starting seed regardless of
	# the order chunks are accessed.
	#
	var newsize
	var dpos
	var hrz
	var vrt
	var new_data
	rs[1]=hm_curseed
	while hm_min>lo or hm_max<hi:
		# Expand the heightmap square one layer
		newsize=hm_size+2
		dpos=0
		# new top row
		new_data=[hm_data[dpos]+get_rand()*height_scale]
		for hrz in range(hm_size):
			new_data.append(hm_data[dpos]+get_rand()*height_scale)
			dpos+=1
		new_data.append(hm_data[dpos-1]+get_rand()*height_scale)
		# rewind inner data back to start
		dpos=0
		# append each row of old data expanded with new data before and after
		for vrt in range(hm_size):
			# append new left cell
			new_data.append(hm_data[dpos]+get_rand()*height_scale)
			# append existing row
			for hrz in range(hm_size):
				new_data.append(hm_data[dpos])
				dpos+=1
			# append new right cell
			new_data.append(hm_data[dpos-1]+get_rand()*height_scale)
		# rewind inner data to repeat last row
		dpos-=hm_size
		# new bottom row
		new_data.append(hm_data[dpos]+get_rand()*height_scale)
		for k in range(hm_size):
			new_data.append(hm_data[dpos]+get_rand()*height_scale)
			dpos+=1
		new_data.append(hm_data[dpos-1]+get_rand()*height_scale)
		# recalc data properties
		hm_size+=2
		hm_min-=1
		hm_max+=1
		hm_data=new_data
	hm_curseed=rs[1]

	var ax=x+(hm_size/2)-1
	var ay=y+(hm_size/2)-1
	return [
		get_hmdata(ax  ,ay  ),
		get_hmdata(ax+1,ay  ),
		get_hmdata(ax  ,ay+1),
		get_hmdata(ax+1,ay+1)
	]

func getChunkHM(x,y):
	# initialize terrain chunk at (x,y)
	var lo=min(x,y)
	var hi=max(x+1,y+1)

	# Expand the heightmap square one layer at a time until
	# chunk's points are contained within the expanded heightmap
	#
	# For landscapes a consistent generation loop must generate
	# the same landscape for a given starting seed regardless of
	# the order chunks are accessed.
	#
	var newsize
	var dpos
	var hrz
	var vrt
	var new_data
	rs[1]=hm_curseed
	while hm_min>lo or hm_max<hi:
		# Expand the heightmap square one layer
		newsize=hm_size+2
		dpos=0
		# new top row
		new_data=[hm_data[dpos]+get_rand()*height_scale]
		for hrz in range(hm_size):
			new_data.append(hm_data[dpos]+get_rand()*height_scale)
			dpos+=1
		new_data.append(hm_data[dpos-1]+get_rand()*height_scale)
		# rewind inner data back to start
		dpos=0
		# append each row of old data expanded with new data before and after
		for vrt in range(hm_size):
			# append new left cell
			new_data.append(hm_data[dpos]+get_rand()*height_scale)
			# append existing row
			for hrz in range(hm_size):
				new_data.append(hm_data[dpos])
				dpos+=1
			# append new right cell
			new_data.append(hm_data[dpos-1]+get_rand()*height_scale)
		# rewind inner data to repeat last row
		dpos-=hm_size
		# new bottom row
		new_data.append(hm_data[dpos]+get_rand()*height_scale)
		for k in range(hm_size):
			new_data.append(hm_data[dpos]+get_rand()*height_scale)
			dpos+=1
		new_data.append(hm_data[dpos-1]+get_rand()*height_scale)
		# recalc data properties
		hm_size+=2
		hm_min-=1
		hm_max+=1
		hm_data=new_data
	hm_curseed=rs[1]

	var ax=x+(hm_size/2)-1
	var ay=y+(hm_size/2)-1
	return [
		get_hmdata(ax  ,ay  ),
		get_hmdata(ax+1,ay  ),
		get_hmdata(ax  ,ay+1),
		get_hmdata(ax+1,ay+1)
	]

func tile2UV(tile_idx,flip_X,flip_Y,swap_XY):
	#prints("Tile ID: ", tile_idx, " | Flip X: ", flip_X, " | Flip Y: ", flip_Y, " | Swap X/Y: ", swap_XY)
	# converts tileset index to texture UV coords
	#var lt=ts_skipw*int(tile_idx%ts_tiles_per_col)
	var lt = tile_idx%ts_tiles_per_col
	#var lt = ts_skipw * tile_idx.x
	var rt=lt+tile_width
	#prints("lt:", lt, " | rt:", rt)
	#var top=ts_skiph*float(tile_idx/ts_tiles_per_row)
	var top = float(tile_idx/ts_tiles_per_row)
	var btm=top+tile_height
	#prints("top:", top, " | btm:", btm)
	"""
	var l=float( lt+tile_idx)/float(ts_width)
	var t=float(top+tile_idx)/float(ts_height)
	var r=float( rt)/float(ts_width)
	var b=float(btm)/float(ts_height)
	"""
	var j = 1.0 / float(ts_tiles_per_row)
	var k = 1.0 / float(ts_tiles_per_col)
	var l = float(lt * j)
	var t = float(top * k)
	var r = l + j
	var b = t + k
	#"""
	#prints("l:", l, " | t:", t, " | r:", r, " | b:", b)
	var ul = Vector2(l,t)
	var ur = Vector2(r,t)
	var br = Vector2(l,b)
	var bl = Vector2(r,b)
	#temp variable
	var tmp
	#flip UV coords
	
		
	if flip_X and !flip_Y:
		print("Fizz")
		tmp = ul
		ul = ur
		ur = tmp
		tmp = bl
		bl = br
		br = tmp
	if flip_Y and !flip_X:
		print("Buzz")
		tmp = ul
		ul = bl
		bl = tmp
		tmp = ur
		ur = br
		br = tmp
	if flip_X and flip_Y:
		print("FizzBuzz")
		tmp = ul
		ul = br
		br = tmp
		tmp = ur
		ur = bl
		bl = tmp
		
	if swap_XY:
		prints("Swapped X/Y @ ", tile_idx)
		"""tmp = ul
		ul = ur
		ur = br
		br = bl
		bl = tmp"""
		ul = Vector2(r,t)
		ur = Vector2(l,b)
		br = Vector2(r,b)
		bl = Vector2(l,t)
	return [
		ul,
		ur,
		br,
		bl
	]

func genChunkNode(x,y):
	# Set up new node and mesh
	terrain=MeshInstance.new()
	add_child(terrain)
	terrainMesh=Mesh.new()
	terrain.set_mesh(terrainMesh)
	surf=SurfaceTool.new()
	# origin is half the chunk size
	var org=chunk_size/2
	# convert to a float for lerp calcs
	var fCellSz=float(chunk_size)
	# get height points for the chunk corners
	var cpoints
	if ProceduralGen:
		cpoints=getChunkPG(x,y)
	else:
		cpoints=getChunkHM(x,y)
	var ul=cpoints[0]
	var ur=cpoints[1]
	var bl=cpoints[2]
	var br=cpoints[3]
	var avg_elv=(ul+ur+bl+br)/4.0
	# interpolate height over the chunk
	# using lerp and ease to round the transitions
	var il
	var ir
	var elv
	var hmap=[]
	hmap.resize(1+chunk_size)
	for hmap_v in range(1+chunk_size):
		il=lerp(bl,ul,ease(hmap_v/fCellSz,smoothing))
		ir=lerp(br,ur,ease(hmap_v/fCellSz,smoothing))
		hmap[hmap_v]=[]
		hmap[hmap_v].resize(1+chunk_size)
		for hmap_h in range(1+chunk_size):
			elv=lerp(il,ir,ease(hmap_h/fCellSz,smoothing))
			hmap[hmap_v][hmap_h]=elv
	# generates mesh:
	# paired triangles (quads) for each cell of the chunk
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vs
	var hs

	# TODO: use indexes for cell's texture
	var tile_uv

	for v in range(chunk_size):
		vs=v-org
		for h in range(chunk_size):
			hs=h-org
			
			avg_elv=(hmap[v][h]+hmap[v][h+1]+hmap[v+1][h]+hmap[v+1][h+1])/4
			tile_uv=tile2UV(0,false,false,false)
			"""
			if avg_elv>=0 and avg_elv<2:
				tile_uv=tile2UV(1)
			if avg_elv>=2 and avg_elv<4:
				tile_uv=tile2UV(2)
			if avg_elv>=4 and avg_elv<6:
				tile_uv=tile2UV(3)
			if avg_elv>=6 and avg_elv<10:
				tile_uv=tile2UV(4)
			"""
			var hx = hs + (x*chunk_size)
			var vy = vs + (-y*chunk_size)
			if get_cell(hx,vy) != INVALID_CELL:
				
				tile_uv=tile2UV(get_cell(hx,vy),is_cell_x_flipped(hx,vy),is_cell_y_flipped(hx,vy),is_cell_transposed(hx,vy))

			surf.add_color(Color(1,1,1))
			surf.add_uv(tile_uv[TILE_TL])
			surf.add_vertex(Vector3(hs*mapScale,hmap[v][h],vs*mapScale))
			surf.add_color(Color(1,1,1))
			surf.add_uv(tile_uv[TILE_TR])
			surf.add_vertex(Vector3((hs+1)*mapScale,hmap[v][h+1],vs*mapScale))
			surf.add_color(Color(1,1,1))
			surf.add_uv(tile_uv[TILE_BL])
			surf.add_vertex(Vector3(hs*mapScale,hmap[v+1][h],(vs+1)*mapScale))
			surf.add_color(Color(1,1,1))
			surf.add_uv(tile_uv[TILE_BL])
			surf.add_vertex(Vector3(hs*mapScale,hmap[v+1][h],(vs+1)*mapScale))
			surf.add_color(Color(1,1,1))
			surf.add_uv(tile_uv[TILE_TR])
			surf.add_vertex(Vector3((hs+1)*mapScale,hmap[v][h+1],vs*mapScale))
			surf.add_color(Color(1,1,1))
			surf.add_uv(tile_uv[TILE_BR])
			surf.add_vertex(Vector3((hs+1)*mapScale,hmap[v+1][h+1],(vs+1)*mapScale))

	# generate normals based on vertex ordering
	surf.generate_normals()
	surf.set_material(tileset_texture)
	# applies changes to the mesh object
	surf.commit(terrainMesh)
	# position chunk appropriately in world
	terrain.set_name("chunk_"+str(x)+"_"+str(y))
	terrain.set_translation(Vector3((x*chunk_size)*mapScale,0,(y*-chunk_size)*mapScale))
	terrain.create_trimesh_collision()
	terrain.lod_max_distance = clipDistance
	return terrain

func registerChunk(n,x,y):
	if not chunkMap.has(y):
		chunkMap[y]={}
	chunkMap[y][x]=n

func registerChunkBase(tilemap,x,y):
	if not cellTileMapBase.has(y):
		cellTileMapBase[y]={}
	cellTileMapBase[y][x]=tilemap

func registerChunkOverlay(tilemap,alpha,x,y):
	if not cellTileMapOverlay.has(y):
		cellTileMapOverlay[y]={}
	if not cellTileMapAlpha.has(y):
		cellTileMapAlpha[y]={}
	cellTileMapOverlay[y][x]=tilemap
	cellTileMapOverlay[y][x]=alpha

func modifyHeightmap(x, y, amount):
	pass

func deformTerrain(x, y, brush):
	pass

func build(foo):
	_ready()

func _ready():
	# Initalization here
	chunkMap={}
	rs=rand_seed(rseed)
	init_hm()

	# set up tileset
	var ts=tileset_texture.get_texture(SpatialMaterial.TEXTURE_ALBEDO)
	ts_width=ts.get_width()
	ts_height=ts.get_height()
	ts_skipw=(2*tile_padding)+tile_width
	ts_skiph=(2*tile_padding)+tile_height
	ts_tiles_per_row=int(ts_width/ts_skipw)
	ts_tiles_per_col=int(ts_height/ts_skiph)
	#prints("Tiles Per Row: ", ts_tiles_per_row, " | Tiles Per Col: ", ts_tiles_per_col)
	ts_total=ts_tiles_per_row*ts_tiles_per_col

	# generate some chunks nodes for the scene
	var v
	var h
	for v in range(-chunk_rings,1+chunk_rings):
		for h in range(-chunk_rings,1+chunk_rings):
			registerChunk(genChunkNode(h,v),h,v)
