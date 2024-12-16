shader_type canvas_item;

uniform vec4 fill_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 center = vec2(0.5); // The center of the circle in UV space
    float radius = 0.47;      // Circle radius in UV space a bit less than .5 to avoid sticking out of progressbar

	// Calculate distance from the fragment to the circle center
    float dist = distance(UV, center);

    // If the distance is less than the radius, draw the circle with fill color
    if (dist < radius) {
        COLOR = fill_color; // White color
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Transparent outside the circle
    }
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
