// Drying rack foot guard for robot vacuums
// Replaces the plastic end cap on a round-tube foot.
//
// The tube's last section is straight but angled: it rises from the tip
// (which touches the floor) to the level middle part. The tube end slides into
// a closed socket tilted to that same angle. The rest of the block is a
// top-open channel that follows the rise, with extra room below the tube so
// the channel never props the tube up out of the socket.
//
// x = 0 is the foot end of the block.
// Open in OpenSCAD and use Window > Customizer to adjust the parameters.
// Print flat side down, no supports needed (the socket is teardrop-shaped).

/* [Tube] */
// Measured outer diameter of the tube (mm)
tube_d = 16.0;
// Extra diameter for fit; 0.3-0.5 for a snug slide fit, increase if too tight
clearance = 0.2;
// How far the tube goes into the closed socket at the foot end (mm); keep it shorter than end_seg_len
socket_len = 35;
// End wall thickness at the closed foot end (mm)
end_wall = 3;

/* [Tube shape (measured without the old caps)] */
// Length of the straight angled end section, from the tip to where it meets the level middle (mm)
end_seg_len = 70;
// How much higher the level middle is than the tip, measured at the tube's bottom (mm)
end_rise = 5;
// Floor thickness under the tube tip; raises the whole rack by this much
gap_at_tip = 3;
// Extra room under the tube after the socket, so small measurement errors don't lift the tube out of the socket
under_clearance = 2;
// Sideways widening of the open channel towards the open end, per side (degrees). Gives room if the leg sits at a slight sideways angle to the block
channel_flare = 1;

/* [Block shape] */
// Overall length (mm); 60 is enough for a test print of the socket fit
length = 170;
// Total height; above ~30 mm most robots' bumpers will hit it instead of climbing
height = 35;
// Width at the floor
base_w = 40;
// Width at the top
top_w = 30;

/* [Details] */
// Rounding radius of the profile edges
edge_r = 3;
// Chamfer length of the two block ends
end_chamfer = 8;
// Chamfer along the top edges of the channel, eases dropping the tube in
entry_chamfer = 1.5;

/* [Hidden] */
$fn = 96;
eps = 0.01;

bore_d = tube_d + clearance;
// Angle of the end section
tilt = atan(end_rise / end_seg_len);
// Tube tip (where the axis meets the end face); shifted so the tilted end face clears the end wall
x_tip = end_wall + bore_d / 2 * sin(tilt);
z_tip = gap_at_tip + bore_d / 2;
// Where the socket ends, along the tilted axis
socket_end = x_tip + socket_len * cos(tilt);
z_socket_end = z_tip + socket_len * sin(tilt);
// Where the tube reaches the level middle part
rise_end = x_tip + end_seg_len;
z_far = z_tip + end_rise;
// Extra channel half-width at x from the sideways flare (starts at the socket)
function flare_at(x) = max(0, x - socket_end) * tan(channel_flare);

H  = height;
BW = base_w;
TW = top_w;

assert(socket_len < end_seg_len, "socket_len must be shorter than end_seg_len");
assert(length >= socket_end + end_wall, "length must be longer than the socket");
assert(H >= z_socket_end + bore_d / 2 * sqrt(2) + 2, "Block is too low to roof over the socket");
assert(H >= z_far + bore_d / 2, "Block is lower than the top of the raised tube");
assert(TW >= bore_d + 4, "Top is too narrow for the tube channel");
assert(TW - bore_d - 2 * flare_at(length - min(end_chamfer, length / 4)) - 2 * entry_chamfer >= 4,
       "channel_flare is too big: the channel walls get too thin near the open end");

module profile2d(bw, tw, h) {
    // Rounded trapezoid; bottom edge kept sharp so it sits flat
    r = min(edge_r, h / 3);
    intersection() {
        offset(r) offset(-r)
            polygon([[-bw/2, -r], [bw/2, -r], [tw/2, h], [-tw/2, h]]);
        translate([-bw, 0]) square([2 * bw, h]);
    }
}

// Teardrop: a circle with a 45-degree point on top (+y in 2D), so a sideways
// hole prints without supports. The tube still rests on the round part.
module teardrop2d(d) {
    r = d / 2;
    hull() {
        circle(d = d);
        translate([0, r * sqrt(2)]) square(0.01, center = true);
    }
}

module extrude_x(len) {
    rotate([90, 0, 90]) linear_extrude(len) children();
}

module body() {
    c = min(end_chamfer, length / 4);
    shrink = c * 2;
    // Hull of the full profile (shortened) and a smaller profile (full length)
    // gives sloped ends so the robot slides off instead of catching.
    hull() {
        translate([c, 0, 0]) extrude_x(length - 2 * c)
            profile2d(BW, TW, H);
        extrude_x(length)
            profile2d(max(BW - shrink, TW), max(TW - shrink, bore_d + 2), H - c / 2);
    }
}

// Thin cross-section of the channel at x, with the tube axis at z:
// round bottom (lowered by drop), widened sideways by the flare at x,
// and open straight up to the top.
module channel_slice(x, z, drop) {
    w = flare_at(x);
    translate([x, 0, 0]) rotate([0, 90, 0]) linear_extrude(eps)
        hull() {
            for (y = [-w, w]) {
                translate([-z, y]) circle(d = bore_d);
                translate([-(z - drop), y]) circle(d = bore_d);
            }
            translate([-(H + 1), -bore_d / 2 - w]) square([1, bore_d + 2 * w]);
        }
}

// Thin cross-section of the chamfer along the channel's top edges at x
module chamfer_slice(x) {
    hw = bore_d / 2 + flare_at(x);
    translate([x, 0, H + eps]) rotate([90, 0, 90]) linear_extrude(eps)
        polygon([[-hw - entry_chamfer, 0], [hw + entry_chamfer, 0],
                 [hw, -entry_chamfer], [-hw, -entry_chamfer]]);
}

module cutouts() {
    // Closed socket at the foot end, tilted to the tube's end angle.
    // Runs 2 mm past socket_end so its slanted end face overlaps the channel
    // instead of leaving a lip of roof material inside the bore.
    // Teardrop-shaped so the socket roof prints without supports.
    translate([x_tip, 0, z_tip])
        rotate([0, 90 - tilt, 0]) linear_extrude(socket_len + 2) rotate(90) teardrop2d(bore_d);

    // Open channel: rest of the angled section, then the level part
    hull() {
        channel_slice(socket_end, z_socket_end, 0);
        channel_slice(rise_end, z_far, under_clearance);
    }
    hull() {
        channel_slice(rise_end, z_far, under_clearance);
        channel_slice(max(length, rise_end) + 1, z_far, under_clearance);
    }

    // Chamfer along the top edges of the channel
    hull() {
        chamfer_slice(socket_end);
        chamfer_slice(length + 1);
    }
}

difference() {
    body();
    cutouts();
}
