import json
import math
from pprint import pprint
from sys import maxint

# define a world which contains 800x600 
# find what the maximum size is first
# scale everything so that the maximum is 800x600
# ceiling everything.

max_x = -maxint
max_y = -maxint

min_x = maxint
min_y = maxint


globe = []

isos = {}

def projection(coordinates):
	x = coordinates[0]
	y = coordinates[1]

	x = round(x)
	y = round(y)


	y = y * -1
	return [x, y]

with open('area.json') as json_file:
	data = json.load(json_file)
	for country in data:
		name = country["properties"]["name"]
		iso = country["properties"]["iso"]
		isos[name] = iso


with open('raw_countries.json') as json_file:
    data = json.load(json_file)
    for country_index, country in enumerate(data):
		state = {}

		name = country["properties"]["admin"]
		state["area"] = country["area"]
		state["centroid"] = projection(country["centroid"])
		state["name"] = name

		if name in isos:
			print("Adding iso: " + name.encode('utf-8') +":" + isos[name].encode('utf-8'))
			state["iso"] = isos[name]
		else:
			print("Unable to find iso:" + name)
			state["iso"] = "UNKNOWN"

		if state["name"] != "Antarctica":
			geometry = country["geometry"]
			if geometry["type"] == "MultiPolygon":
				globe_paths = []
				for feature_index, feature in enumerate(geometry['coordinates']):
					globe_path = []
					for path_index, path in enumerate(feature):
						globe_coords = []
						for coords_index, coords in enumerate(path):
							updated = projection(coords)
							x = updated[0]
							y = updated[1]

							if max_x < x:
								max_x = x

							if max_y < y:
								max_y = y

							if min_x > x:
								min_x = x

							if min_y > y:
								min_y = y

							globe_coords.append(updated)
						globe_path.append(globe_coords)
					globe_path.append(globe_path[0])
					globe_paths.append(globe_path)
				state["paths"] = globe_paths
			else:
				globe_paths = []
				globe_path = []

				for feature_index, feature in enumerate(geometry['coordinates']):
					globe_coords = []
					last_index = [maxint, maxint]
					for coords_index, coords in enumerate(feature):
						updated = projection(coords)
						x = updated[0]
						y = updated[1]

						if max_x < x:
							max_x = x

						if max_y < y:
							max_y = y

						if min_x > x:
							min_x = x

						if min_y > y:
							min_y = y

						globe_coords.append(updated)
					globe_path.append(globe_coords)
				globe_paths.append(globe_path)
				state["paths"] = globe_paths

			globe.append(state)



length_x = abs(min_x) + max_x
length_y = abs(min_y) + max_y

step_x = 1.0 / length_x
step_y = 1.0 / length_y

print("MAX_X: " + str(max_x) + " MIN_X:" + str(min_x) + " MAX_Y:" + str(max_y) + " MIN_Y:" + str(min_y))
print("LENGTH_X: " + str(length_x) + " LENGTH_Y:" + str(length_y) + " STEP:" + str(step_x) + "," + str(step_y))


projection = []


for country_index, country in enumerate(globe):
	centroid_x = country["centroid"][0]
	centroid_y = country["centroid"][1]

	state = {
		"area": country["area"],
		"iso": country["iso"],
		"name" : country["name"],
		"centroid": [
			(centroid_x + abs(min_x)) * step_x,
			(centroid_y + abs(min_y)) * step_y
	]}



	print("Setting Centroid to X:" + str(state["centroid"][0]) + ", Y:" + str(state["centroid"][1]))
	print("\tfrom X:" + str(centroid_x) + ", Y:" + str(centroid_y))

	projection_paths = []
	for path_index, path in enumerate(country["paths"]):
		projection_path = []
		for coords_index, coords in enumerate(path):
			projection_coords = []
			last_x = coords[0][0]
			last_y = coords[0][1]

			for coord_index, coord in enumerate(coords):
				x = coord[0]
				y = coord[1]

				absolute_x = abs((x) - (last_x))
				if absolute_x > (length_x / 2):
					print("Flip: " + state["name"])
					print("OLD X: " + str(last_x) + ", Y:" + str(last_y))
					print("NEW X: " + str(x) + ", Y:" + str(y))

					x = x * -1

				last_x = x
				last_y = y

				projection_coords.append( [
					(x + abs(min_x)) * step_x,
					(y + abs(min_y)) * step_y
				])

			deduped_projection_coords = []
			for coord_index, coord in enumerate(projection_coords):
				if coord_index == 0:
					print("Appending: coords_index:" + str(coord_index))
					print("\tCurrent X: " + str(coord[0]) + ", Y:" + str(coord[1]))
					deduped_projection_coords.append(coord)
					continue
				else:
					origin_coord = projection_coords[coord_index -1]
					print("Checking")
					print("\tCurrent X: " + str(coord[0]) + ", Y:" + str(coord[1]))
					print("\tLast    X: " + str(origin_coord[0]) + ", Y:" + str(origin_coord[1]))

					if coord[0] == origin_coord[0] and coord[1] == origin_coord[1]:
						# We have a dup.
						print("\tDupe, dropping...")
						continue
					else:
						deduped_projection_coords.append(coord)

			deduped_projection_coords.append(deduped_projection_coords[0])
			projection_path.append(deduped_projection_coords)
		projection_paths.append(projection_path)

	state["paths"] = projection_paths
	projection.append(state)


with open('transformed_countries.json', 'w') as outfile:
	print("Dumping changed coordinates")
	json.dump(projection, outfile)
