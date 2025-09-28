shader_type canvas_item;


uniform vec2 polygon_points[2000];
uniform int polygon_indices[5];
uniform int polygon_count = 0;

bool is_point_in_polygon(vec2 point, vec2 polygon[2000], int polygonMin, int polygonMax) {
    int intersections = 0;
	int size = polygonMax - polygonMin;
	
    for (int i = polygonMin; i < polygonMax; i++) {
        vec2 v1 = polygon_points[i];
		
		int nextIndex = i + 1;
		if(nextIndex >= polygonMax) {
			nextIndex -= size;
		}
        vec2 v2 = polygon_points[nextIndex];

        // Check if the ray intersects with the edge of the polygon
        if (((v1.y > point.y) != (v2.y > point.y)) &&
            (point.x < (v2.x - v1.x) * (point.y - v1.y) / (v2.y - v1.y) + v1.x)) {
            intersections++;
        }
    }

    // The point is inside the polygon if the number of intersections is odd
    return (intersections % 2) == 1;
}

void fragment() {
	for(int i = 1; i < polygon_count; i++) {
		bool result = is_point_in_polygon(FRAGCOORD.xy, polygon_points, polygon_indices[i - 1], polygon_indices[i]);
		if(result) {
			discard;
		}
	}
	
    vec4 color = texture(TEXTURE, UV);
    COLOR = color;
	
}