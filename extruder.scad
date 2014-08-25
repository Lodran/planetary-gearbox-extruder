include <more_configuration.scad>
include <bearings.scad>
include <drive_wheels.scad>
include <vitamin.scad>

use <gears.scad>
use <barbell.scad>
use <teardrops.scad>
use <functions.scad>

$fa=1;
$fs=.5;

carriage_bolt_spacing = 50;
carriage_length = 65;

//carriage_bolt_spacing = 38;
//carriage_length = 50;

drive_bearing = 105_bearing;	// hobbyking part.
//drive_bearing = 115_bearing;
pinch_bearing = 623_bearing;	// hobbyking part.
//pinch_bearing = 624_bearing;
drive_wheel = makerbot_mk7;

extruder_body_height = 18;

drive_wheel_void_radius = drive_wheel[drive_wheel_radius]+1.25;

filament_radius = 3/2;
pinch_radius=.25;

filament_center = [drive_wheel[drive_wheel_hob_radius]+filament_radius-pinch_radius, 0, drive_wheel[drive_wheel_hob_center]+moving_clearance];

pinch_bearing_center = filament_center+[filament_radius-pinch_radius+pinch_bearing[bearing_outer_radius], 0, 0];

extruder_bolt_1 = [0, 20];
extruder_bolt_2 = [-11, -15];
hinge_bolt = [pinch_bearing_center[x], -13];

hinge_radius = 5;

pinch_bolt = [pinch_bearing_center[x], drive_wheel_void_radius+5];
pinch_bolt_offset = 4.25;

carriage_bolt_offset = (carriage_length-50)/2;

carriage_mount_min = [carriage_bolt_offset-carriage_length/2, -25];
carriage_mount_max = [carriage_bolt_offset+carriage_length/2, -25+5];
carriage_mount_center = (carriage_mount_min + carriage_mount_max)/2;
carriage_mount_size = carriage_mount_max - carriage_mount_min;

echo(str("carriage_mount_min: ", carriage_mount_min));
echo(str("carriage_mount_max: ", carriage_mount_max));

module extruder_plate()
{
	translate([0, 0]) extruder_body(print=1);
	translate([-33, -10]) pinch_bracket(print=1);
}

module extruder_body(print=0)
{
	p0=(print==0) ? 1 : 0;
	p1=1-p0;

	translate(p1*[0, 0, extruder_body_height])
	rotate(p1*[180, 0, 0])
	{
		difference()
		{
			extruder_body_solid();
			extruder_body_void();
		}

		if (print == 0)
		{
			// Drive wheel.

			translate([0, 0, drive_wheel[drive_wheel_length]/2+moving_clearance])
			%drive_wheel(drive_wheel);

			// Drive outer bearing.

			translate([0, 0, drive_wheel[drive_wheel_length]+moving_clearance])
			%cylinder(h=drive_bearing[bearing_length], r=drive_bearing[bearing_outer_radius]);

			// Pinch bearing.

			translate(pinch_bearing_center)
			%cylinder(h=pinch_bearing[bearing_length], r=pinch_bearing[bearing_outer_radius], center=true);

			for (bolt = [extruder_bolt_1, extruder_bolt_2, hinge_bolt])
				translate(bolt)
				translate([0, 0, 15])
				rotate([180, 0, 0])
				%cylinder(h=20, r=3/2);
		}
	}
}

module extruder_body_solid()
{
	p1 = carriage_mount_min+[3, 3];
	p2 = extruder_bolt_2+[0, -3];

	p3 = [carriage_mount_max[x]-3, p1[y]];
	p4 = [hinge_bolt[x], p2[y]];

	p5 = extruder_bolt_1+[10, 0];

	linear_extrude(height=extruder_body_height, convexity=4)
	{
		barbell([0, 0], extruder_bolt_1, drive_wheel_void_radius+5, 5, 10, 10);

		barbell([0, 0], p5, drive_wheel_void_radius+5, 5, 10, 10);

		translate((extruder_bolt_1+p5)/2)
		square([p5[x]-extruder_bolt_1[x], 10], center=true);

		barbell([0, 0], extruder_bolt_2, drive_wheel_void_radius+5, 5, 40, 5);
		barbell([0, 0], hinge_bolt, drive_wheel_void_radius+5, 7.5, 40, 30);

		barbell(p1, p2, 3, 5, 30, 30);
		barbell(p3, p4, 3, m3_bolt_head_diameter/2, 40, 30);

		polygon([p1+[0, -3], p1, p2, extruder_bolt_2, [0, 0], hinge_bolt, p4, p3, p3+[0, -3]]);
	}
}

module filament_channel_support()
{
	for(i=[-.5, .5])
	translate(filament_center+[i, 0, -(filament_radius+moving_clearance+layer_height/2)])
	cube([1-.1, 50, layer_height], center=true);
}

module extruder_body_void()
{
	part_name = "Extruder body";
	part_count = 1;

	// Filament channel.

	translate(filament_center)
	rotate([90, 0, 0])
	rotate(180)
	octylinder(h=51, r=filament_radius+moving_clearance, center=true);

	// Drive wheel.

	difference()
	{
		translate([0, 0, -.1])
		cylinder(h=drive_wheel[drive_wheel_length]+moving_clearance*2+.1, r=drive_wheel_void_radius);
		
		filament_channel_support();
	}

	vitamin(part_name, part_count, 1, "Drive wheel", comment="5mm ID, 12mm OD, 11mm long", source="http://www.reprapdiscount.com/mechanics/52-hobbed-pulley.html#/bore_length_diameter_hob_diameter-5mm_11mm_12mm_10_1mm");

	// Access cutout.

	rotate(0)
	translate([-7, 0, (drive_wheel[drive_wheel_length]+moving_clearance*2)/2-.05])
	cube([14, (drive_wheel_void_radius-1)*2, drive_wheel[drive_wheel_length]+moving_clearance*2+.1], center=true);

	// Drive shaft

	cylinder(h=extruder_body_height+.1, r=m5_diameter/2);

	vitamin(part_name, part_count, 1, "M5 Nylock nut", comment="Drive shaft end nut", source="McMaster-Carr");

	// Drive outer bearing.

	translate([0, 0, drive_wheel[drive_wheel_length]+moving_clearance])
	cylinder(h=drive_bearing[bearing_length], r=drive_bearing[bearing_outer_radius]+fit_clearance);

    vitamin(part_name, part_count, 1, "105 Bearing", comment="Outer Drive shaft bearing", source = "Comes with Inner Drive shaft bearing");

	// Extruder mounting bolts.

	for (bolt = [extruder_bolt_1, extruder_bolt_2, hinge_bolt])
	{
		translate([bolt[x], bolt[y], -.1])
		cylinder(h=15-layer_height+.1, r=m3_diameter/2);

		translate([bolt[x], bolt[y], 15])
		linear_extrude(height=extruder_body_height-15+.1, convexity=4)
		{
			difference()
			{
				circle(m3_bolt_head_diameter/2);
				circle(m3_diameter/2);
			}
		}
	}
    
    vitamin(part_name, part_count, 3, M3x20, "Extruder mounting bolts", source="McMaster-Carr");

	// Pinch bearing bracket.

	difference()
	{
		translate(hinge_bolt) rotate(3) translate(-hinge_bolt)
			pinch_bracket_solid(moving_clearance);

		filament_channel_support();
	}

	// Pinch bracket bolts.

	for (i=[-1, 1])
	{
		translate([0, pinch_bolt[y], filament_center[z]+i*pinch_bolt_offset])
		rotate([0, 90, 0])
		{
			rotate(-90)
			octylinder(h=40, r=m3_diameter/2, center=true);

			translate([0, 0, -3])
			rotate([180, 0, 0])
			rotate(90)
			cylinder(h=10, r=m3_nut_diameter/2, $fn=6);
		}
	}
    
    vitamin(part_name, part_count, 2, M3_nylock, "Pinch bracket nuts", source="McMaster-Carr");
    vitamin(part_name, part_count, 2, M3x25, "Pinch bracket bolts", source="McMaster-Carr");
    vitamin(part_name, part_count, 2, M3_washer, "Pinch bracket washers", source="McMaster-Carr");

	// Nozzle mount

	translate([filament_center[x], carriage_mount_max[y], filament_center[z]])
	rotate([90, 0, 0])
	{
			cylinder(h=5.1, r=8+fit_clearance);
	}

    vitamin(part_name, part_count, 1, "Groove Mount Hot-End", "Any Groove Mount compatible Hot-End", source="https://www.hotends.com/index.php?route=product/product&product_id=88");

	// Carriage mounting bolts.

	translate([carriage_bolt_offset, 0, filament_center[z]])
	for (i=[-1, 1])
	{
		translate([i*carriage_bolt_spacing/2, carriage_mount_center[y], 0])
		rotate([-90, 0, 0])
		cylinder(h=carriage_mount_size[y]+.1, r=m3_diameter/2, center=true);

		translate([i*carriage_bolt_spacing/2, carriage_mount_min[y]+2, 0])
		rotate([-90, 0, 0])
		cylinder(h=20, r=m3_nut_diameter/2, $fn=6);
	}
    
    vitamin(part_name, part_count, 2, M3_nylock, "Carriage mounting nuts", source="McMaster-Carr");
    vitamin(part_name, part_count, 2, M3x16, "Carriage mounting bolts", source="McMaster-Carr");

}

module pinch_bracket(print=0)
{
	p0=(print==0) ? 1 : 0;
	p1=1-p0;

	translate(p1*[0, 0, pinch_bearing_center[x]+7.5])
	rotate(p1*[0, 90, 0])
	difference()
	{
		pinch_bracket_solid();
		render(convexity=4) pinch_bracket_void();
	}
}

module pinch_bracket_solid_outline(clearance=0)
{
	c1 = (clearance == 0) ? 0 : 1;

	p1 = [pinch_bearing_center[x], pinch_bearing_center[y]];
	r1 = pinch_bearing[bearing_outer_radius];

	p2 = [pinch_bearing_center[x]+2, pinch_bolt[y]];
	r2 = 5.5;

	intersection()
	{
		union()
		{
			barbell(hinge_bolt, p1, hinge_radius+clearance, pinch_bearing[bearing_outer_radius]+clearance, 5-clearance, 5-clearance);

			barbell(p1, p2, r1+clearance, r2+clearance, 5-clearance, 5-clearance);

			translate(hinge_bolt)
			rotate(30-c1*20)
			translate([5, 0])
			square([10, (hinge_radius+clearance)*2], center=true);

			translate(p2)
			rotate(-30)
			translate([5, 0])
			square([10, (r2+clearance)*2], center=true);

			translate([p2[x]+2, (hinge_bolt[y]+p2[y])/2])
			square([(r2+clearance)*2-4, p2[y]-hinge_bolt[y]], center=true);
		}

		translate([p2[x]-2, 0])
		square([(r2+clearance)*2+4, 40], center=true);
	}
}

module pinch_bracket_hinge_void(clearance=0)
{
	c1 = (clearance == 0) ? 0 : 1;

	hinge_support_length = 6;

	p0 = hinge_bolt + [0, -.5];

	p1 = [pinch_bearing_center[x], pinch_bearing_center[y]];
	r1 = pinch_bearing[bearing_outer_radius];
	
	p2 = [pinch_bearing_center[x]+2, pinch_bolt[y]];
	r2 = 5.5;

	translate(p1)
	wedge(-vec_angle_2(p1-hinge_bolt)-90, 100)
	{
		rotate_extrude(convexity=4)
		{
			translate([pinch_bearing[bearing_outer_radius]+clearance, 0])
			square([pinch_bearing[bearing_outer_radius], hinge_support_length+.1]);
		}
	}

	translate(hinge_bolt) hull()
	{
		cylinder(h=hinge_support_length+.1, r=vec_length_2(p1-hinge_bolt)-pinch_bearing[bearing_outer_radius]-clearance);

		rotate(-45)
		translate([5, 0, 0])
		cylinder(h=hinge_support_length+.1, r=vec_length_2(p1-hinge_bolt)-pinch_bearing[bearing_outer_radius]-clearance);

		rotate(-45-90)
		translate([5, 0, 0])
		cylinder(h=hinge_support_length+.1, r=vec_length_2(p1-hinge_bolt)-pinch_bearing[bearing_outer_radius]-clearance);
	}
}

module pinch_bracket_solid(clearance=0)
{
	c1 = (clearance == 0) ? 0 : 1;

	hinge_support_length = 6;

	p0 = hinge_bolt + [0, -.5];

	p1 = [pinch_bearing_center[x], pinch_bearing_center[y]];
	r1 = pinch_bearing[bearing_outer_radius];
	
	p2 = [pinch_bearing_center[x]+2, pinch_bolt[y]];
	r2 = 5.5;

	difference()
	{
		translate([0, 0, extruder_body_height/2])
		linear_extrude(height=extruder_body_height+clearance*2, center=true, convexity=4)
		{
			pinch_bracket_solid_outline(clearance);
		}

		translate([0, 0, extruder_body_height-hinge_support_length+clearance])
		{
			pinch_bracket_hinge_void(clearance);
		}
	}
}

module pinch_bracket_void()
{
	part_name = "Pinch bearing bracket";
	part_count = 1;

	// Hinge bolt.

	translate([hinge_bolt[x], hinge_bolt[y], -.05])
	rotate(90)
	octylinder(h=extruder_body_height+.1, r=m3_diameter/2);

	// Pinch bearing bolt.

	pr1=(pinch_bearing == 624_bearing) ? m4_diameter/2 : m3_diameter/2;
	pr2=(pinch_bearing == 624_bearing) ? m4_bolt_head_diameter/2 : m3_bolt_head_diameter/2;
	pr3=(pinch_bearing == 624_bearing) ? m4_nut_diameter/2 : m3_nut_diameter/2;

	translate([pinch_bearing_center[x], pinch_bearing_center[y]])
	{
		translate([0, 0, -.05])
		{
			rotate(90)
			{
				octylinder(h=extruder_body_height+1, r=pr1);
				translate([0, 0, -.05])
				octylinder(h=4+.1, r=pr2);
			}
		}

		translate([0, 0, extruder_body_height-4])
		rotate(90)
		cylinder(h=5, r=pr3, $fn=6);
	}

	// Pinch bearing.

	difference()
	{
		translate([0, 0, pinch_bearing_center[z]])
		linear_extrude(height=pinch_bearing[bearing_length]+moving_clearance*2+fit_clearance, convexity=4, center=true)
		{
			hull()
			{
				translate([pinch_bearing_center[x], pinch_bearing_center[y]])
				circle(pinch_bearing[bearing_outer_radius]+moving_clearance);

				translate([pinch_bearing_center[x]-5, pinch_bearing_center[y]])
				circle(pinch_bearing[bearing_outer_radius]+moving_clearance+1);
			}
		}

		translate(pinch_bearing_center)
		for (i=[-1, 1]) scale([1, 1, i])
			translate([0, 0, (pinch_bearing[bearing_length]+fit_clearance)/2])
			cylinder(h=moving_clearance+.1, r1=pinch_bearing[bearing_outer_radius]-2, r2= pinch_bearing[bearing_outer_radius]-1);
	}

	vitamin(part_name, part_count, 1, "623 Bearing", comment="Pinch Bearing", source="http://www.hobbyking.com/hobbyking/store/__11726__HK600GT_Ball_Bearings_Pack_3x10x4mm_4pcs_bag.html");

	// Pinch bolts.

	for (i=[-1, 1])
	{
		translate([0, pinch_bolt[y], filament_center[z]+i*pinch_bolt_offset])
		rotate([0, 90, 0])
		{
			cylinder(h=45, r=m3_diameter/2, center=true);
		}
	}

	vitamin(part_name, part_count, 1, M3x16, comment="Pinch Bearing Bolt", source="McMaster-Carr");
	vitamin(part_name, part_count, 1, M3_nylock, comment="Pinch Bearing Nut", source="McMaster-Carr");
}

module M3_bolt_hole(length, head_length = 4, support=0)
{
	translate([0, 0, -.1])
	cylinder(h=length+.1+(support==0 ? .1 : -layer_height), r=m3_diameter/2);

	translate([0, 0, length])
	linear_extrude(height=head_length+.1, convexity=true)
	{
		if (support == 0)
			circle(m3_bolt_head_diameter/2);
		else
		difference()
		{
			circle(m3_bolt_head_diameter/2);
			circle(m3_diameter/2);
		}
	}
}

module M3_nut_hole(length, head_length = 5, support=0)
{
	translate([0, 0, -.1])
	cylinder(h=length+.1+(support==0 ? .1 : -layer_height), r=m3_diameter/2);

	translate([0, 0, length])
	linear_extrude(height=head_length+.1, convexity=true)
	{
		if (support == 0)
			circle(m3_nut_diameter/2, $fn=6);
		else
		difference()
		{
			circle(m3_nut_diameter/2, $fn=6);
			circle(m3_diameter/2);
		}
	}
}

module wedge(a1, a2)
{
	intersection()
	{
		child();
		translate([0, 0, -20])
		difference()
		{
			rotate(a1)
			cube(40);
			rotate(a2)
			cube(40);
		}
	}
}