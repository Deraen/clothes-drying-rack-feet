// Rail end cap with wire hinge hole
// Replaces the plastic end cap on the end of a 16 mm rail tube where the
// 4 mm wire of a wing frame hooks in and pivots.
//
// The cap is a sleeve over the tube end with a crosswise hole for the wire
// beyond the tube end. The cap can be turned on the tube, so the hole can
// point whichever way the wire needs.
//
// Prints standing up, open end on the bed, no supports needed:
// the socket roof slopes in at 45 degrees and the wire hole is teardrop-shaped.
// z = 0 is the open end.
// Open in OpenSCAD and use Window > Customizer to adjust the parameters.

/* [Tube] */
// Measured outer diameter of the tube (mm)
tube_d = 16.0;
// Extra diameter for the tube; loose enough that the cap turns freely on it
clearance = 0.55;
// How far the tube goes into the cap (mm)
socket_len = 20;

/* [Wire] */
// Wire diameter (mm)
wire_d = 4.0;
// Extra diameter for the wire hole; small for a tight fit, open it up with a 4 mm drill if needed
wire_clearance = 0.1;
// Distance from the socket bottom to the centre of the wire hole (mm). Set a bit less than the measured tube end to wire distance (9 mm), so the tube stops short of the socket bottom and the hole can line up with the wire
wire_offset = 7;

/* [Cap] */
// Wall thickness around the tube (mm)
wall = 3;
// Material beyond the wire hole, at the rounded end (mm)
end_wall = 4;
// Chamfer at the open end, eases sliding it on the tube
entry_chamfer = 0.8;
// Minimum plastic between the sloped socket roof and the wire hole (mm)
roof_min = 1.2;

/* [Hidden] */
$fn = 96;
eps = 0.01;

bore_d = tube_d + clearance;
hole_d = wire_d + wire_clearance;
od = bore_d + 2 * wall;
R = od / 2;
wire_z = socket_len + wire_offset;
// Total length: wire hole plus material past it
total = wire_z + hole_d / 2 + end_wall;
// The rounded end starts here; never lower than the socket roof
dome_z = max(total - R, socket_len);
// The socket roof slopes in at 45 degrees as far as the wire hole allows,
// leaving only a short flat bridge in the middle
roof_h = max(0, min(bore_d / 2, wire_offset - hole_d / 2 - roof_min));

assert(wire_offset >= hole_d / 2 + 1, "wire_offset too small: the wire hole would cut into the socket");
assert(total > dome_z, "Cap is too short for the rounded end");

// Teardrop: a circle with a 45-degree point on top (+y in 2D), so a sideways
// hole prints without supports. The wire still pivots on the round part.
module teardrop2d(d) {
    r = d / 2;
    hull() {
        circle(d = d);
        translate([0, r * sqrt(2)]) square(0.01, center = true);
    }
}

module body() {
    hull() {
        cylinder(r = R, h = dome_z);
        // Rounded end: an ellipsoid that reaches exactly to `total`
        translate([0, 0, dome_z])
            scale([1, 1, (total - dome_z) / R]) sphere(r = R);
    }
}

difference() {
    body();
    // Tube socket
    translate([0, 0, -eps]) cylinder(d = bore_d, h = socket_len + eps);
    // Sloped socket roof
    translate([0, 0, socket_len - eps])
        cylinder(d1 = bore_d, d2 = bore_d - 2 * roof_h, h = roof_h + eps);
    // Entry chamfer
    translate([0, 0, -eps])
        cylinder(d1 = bore_d + 2 * entry_chamfer, d2 = bore_d, h = entry_chamfer + eps);
    // Crosswise wire hole, along y, point up
    translate([0, R + 1, wire_z]) rotate([90, 0, 0])
        linear_extrude(od + 2) teardrop2d(hole_d);
}
