include <more_configuration.scad>
include <bearings.scad>
include <drive_wheels.scad>
include <vitamin.scad>

use <gears.scad>
use <barbell.scad>
use <teardrops.scad>
use <functions.scad>

include <extruder.scad>

$fa=1;
$fs=.5;

gear_modulus = 1;
gear_pressure_angle = 20;
gear_depth_ratio = .5;
gear_clearance = .25;

num_planets = 3;

ring_teeth = 46;
planet_teeth = 18;

sun_teeth = ring_teeth-planet_teeth*2;

echo(str("sun_teeth: ", sun_teeth, ", ring_teeth: ", ring_teeth, ", planet_teeth: ", planet_teeth));

echo(str("gear ratio: ", ring_teeth+sun_teeth, " to ", sun_teeth, " (", 1+ring_teeth/sun_teeth, ":1)"));

sun_gear_hub_height = 6;
sun_gear_thread_height = 6;
sun_gear_hub_radius = 6;
sun_gear_origin = [0, 0, 4];

planet_carrier_bottom_plate_height = 2;
planet_gear_thread_height = sun_gear_thread_height-1;
planet_carrier_top_plate_height = m5_bolt_head_height+1;

motor_size = [40, 40, 50];
base_size = [50, 50, sun_gear_origin[z]+sun_gear_hub_height-planet_carrier_bottom_plate_height];

annulus_size = [50, 50, moving_clearance+planet_carrier_bottom_plate_height+moving_clearance+planet_gear_thread_height];

annulus_mount_hole_spacing = annulus_size[x]-10;

motor_mount_hole_spacing = 1.22*25.4;

planet_angle = 360/(ring_teeth+sun_teeth);
planet_offset = (planet_teeth-floor(planet_teeth/2)*2) == 0 ? 0 : planet_angle/2;

orbit_radius=((planet_teeth+sun_teeth)*gear_modulus)/2;


planet_carrier_height = planet_carrier_bottom_plate_height + planet_gear_thread_height + moving_clearance + planet_carrier_top_plate_height;

planet_carrier_z = base_size[z]+moving_clearance;
planet_z = planet_carrier_z+planet_carrier_bottom_plate_height+moving_clearance/2;

planet_carrier_radius = gear_pitch_radius(ring_teeth, gear_modulus)-2;


cover_size = [base_size[x], base_size[y], moving_clearance+planet_carrier_height+moving_clearance+5-annulus_size[z]];

planetary_plate();

translate([61, 56])
extruder_plate();

module planetary_plate()
{
	translate([0, 0]) base(print=1);
	translate([0, 53]) annulus(print=1);
	translate([53, 0]) cover(print=1);
	translate([-59, 53/2]) for(i=[0:1])
		translate([i*21, 0]) planet_gear();

	translate([-32, 86]) planet_gear();

	translate([-48, -5]) planet_carrier_lower(print=1);
	translate([-48, 58]) planet_carrier_upper(print=1);
}

module assembly()
{
	base();
	annulus();
	sun_gear();
	planet_carrier_lower();
	planet_gears();
	planet_carrier_upper();
	cover();

	translate([0, 0, base_size[z]+annulus_size[z]+cover_size[z]])
	{
		extruder_body();
		pinch_bracket();
	}
}

module base(print=0)
{
	p0 = (print==0) ? 1 : 0;
	p1 = 1-p0;

	translate(p1*[0, 0, base_size[z]])
	rotate(p1*[180, 0, 0])
	difference()
	{
		base_solid();
		base_void();
	}
}

module base_solid()
{
	linear_extrude(height=base_size[z], convexity=4)
	{
		for(i=[-1, 1]) for (j=[-1, 1])
		hull()
		{
			translate([i*(base_size[x]-10)/2, j*(base_size[y]-10)/2])
			rounded_square([10, 10], 3, $fn=32);

			translate([i*(motor_size[x]-10)/2, j*(motor_size[y]-10)/2])
			rounded_square([10, 10], 3, $fn=32);
		}
	}

	translate([0, 0, base_size[z]-1])
	linear_extrude(height=1)
		rounded_square(base_size, 3, $fn=32);
}

module base_void()
{
	part_name = "Base";
	part_count = 1;

	for (i=[-.5, .5]) for (j=[-.5, .5])
	{
		translate([i*annulus_mount_hole_spacing, j*annulus_mount_hole_spacing, base_size[z]])
		rotate([180, 0, 0])
		M3_nut_hole(base_size[z]-4, support=0);

		translate([i*motor_mount_hole_spacing, j*motor_mount_hole_spacing, 0])
		M3_bolt_hole(base_size[z]-4, support=1);
	}

	translate([0, 0, base_size[z]-1-.05])
	linear_extrude(height=1+.1)
		circle(sun_gear_hub_radius+moving_clearance*2);

	vitamin(part_name, part_count, 4, M3x10, comment="Motor mounting bolts", source="McMaster-Carr");
	vitamin(part_name, part_count, 4, M3_nylock, comment="Cover mounting nuts", source="McMaster-Carr");
}

module annulus(print=0)
{
	p0 = (print==0) ? 1 : 0;
	p1 = 1-p0;

	translate(p0*[0, 0, base_size[z]])
	difference()
	{
		annulus_solid();
		annulus_void();
	}
}

module annulus_solid()
{
	linear_extrude(annulus_size[z], convexity=4)
	{
		rounded_square(annulus_size, 3, $fn=32);
	}
}

module annulus_void()
{
	translate([0, 0, -.1])
	linear_extrude(height = annulus_size[z]+.2, convexity=8)
	{
		rotate(odd(sun_teeth+planet_teeth+ring_teeth)*360/ring_teeth/2)
		gear2D(ring_teeth, gear_modulus, gear_pressure_angle, gear_depth_ratio, -gear_clearance);
	
		for (i=[-.5, .5]) for (j=[-.5, .5])
		{
			translate([i*annulus_mount_hole_spacing, j*annulus_mount_hole_spacing])
			circle(m3_diameter/2);
		}
	}
}

module sun_gear(print=0)
{
	p0=(print==0) ? 1 : 0;
	p1=1-p0;

	translate(p0*sun_gear_origin)
	{
		%render(convexity=4)
		difference()
		{
			sun_gear_solid();
			sun_gear_void();
		}
	}
}

module sun_gear_solid()
{
	cylinder(h=sun_gear_hub_height, r=sun_gear_hub_radius);

	translate([0, 0, sun_gear_hub_height-.1])
	linear_extrude(height=sun_gear_thread_height+.1, convexity=8)
	rotate(even(sun_teeth+planet_teeth+ring_teeth)*360/sun_teeth/2)
	gear2D(sun_teeth, gear_modulus, gear_pressure_angle, gear_depth_ratio, gear_clearance);
}

module sun_gear_void()
{
	part_name = "Sun gear";
	part_count = 1;

	translate([0, 0, -.05])
	cylinder(h=sun_gear_hub_height+sun_gear_thread_height+.1, r=m5_diameter/2);

	translate([0, 0, sun_gear_hub_height/2])
	rotate([90, 0, 0])
	{
		cylinder(h=sun_gear_hub_radius+.1, r=m3_diameter/2, $fn=6);

		/*
		if (steel_sun == 0)
		hull()
		{
			translate([0, 0, 4.5])
			rotate(90)
			cylinder(h=m3_nut_thickness, r=m3_nut_diameter/2, $fn=6);

			translate([0, -5, 4.5])
			rotate(90)
			cylinder(h=m3_nut_thickness, r=m3_nut_diameter/2, $fn=6);
		}
		*/
	}

	vitamin(part_name, part_count, 1, "10T/5MM M1 Pinion", comment="Sun gear", source="http://www.hobbyking.com/hobbyking/store/__45522__10T_5mm_M1_Hardened_Steel_Pinion_Gear_1pc_.html");
}

module planet_carrier_lower(print=0)
{
	p0=(print==0) ? 1 : 0;
	p1=1-p0;

	translate(p0*[0, 0, planet_carrier_z])
	difference()
	{
		planet_carrier_lower_solid();
		planet_carrier_void();
	}
}

module planet_carrier_lower_solid()
{
	cylinder(h=planet_carrier_height/2, r=planet_carrier_radius);
}

module planet_carrier_upper(print=0)
{
	p0=(print==0) ? 1 : 0;
	p1=1-p0;

	translate(p0*[0, 0, planet_carrier_z])
	translate(p1*[0, 0, planet_carrier_height])
	rotate(p1*[180, 0, 0])
	difference()
	{
		planet_carrier_upper_solid();
		planet_carrier_void();
	}

	part_name = "Planet carrier";
	part_count = 1;

	vitamin(part_name, part_count, 1, "M5x30 Bolt", comment="Drive shaft", source="McMaster-Carr");
	vitamin(part_name, part_count, 3, M3_nylock, source="McMaster-Carr");
	vitamin(part_name, part_count, 3, M3x6, source="McMaster-Carr");

}

module planet_carrier_upper_solid()
{
	translate([0, 0, planet_carrier_height/2])
	cylinder(h=planet_carrier_height/2, r=planet_carrier_radius);
}

function planet_angle(i) = i*floor(360/num_planets/planet_angle)*planet_angle+planet_offset;

module planet_carrier_void()
{
	planet_radius = gear_outer_radius(planet_teeth, gear_modulus, gear_depth_ratio, gear_clearance);

	//alignment notch

	translate([(planet_carrier_radius), 0, planet_carrier_height/2])
	rotate(45)
	cube([1.5, 1.5, planet_carrier_height+.1], center=true);

	// Sun gear
	translate([0, 0, -.1])
	cylinder(h=planet_carrier_bottom_plate_height+planet_gear_thread_height+moving_clearance+.1, r=7);

	// Planet gears
	translate([0, 0, planet_carrier_bottom_plate_height])
	{

		for(i=[0:num_planets-1]) assign(a1=i*floor(360/num_planets/planet_angle)*planet_angle+planet_offset) assign(a2=a1*ring_teeth/planet_teeth+180/planet_teeth*odd(sun_teeth))
		{
			rotate([0, 0, a1])
			translate([orbit_radius, 0, 0])
			linear_extrude(height=planet_gear_thread_height+moving_clearance, convexity=4)
			{
				difference()
				{
					circle(planet_radius+1);
					circle(5/2-fit_clearance);
				}
			}
		}
	}

	// Drive bolt

	translate([0, 0, planet_carrier_height-1])
	rotate([180, 0, 0])
	cylinder(h=m5_bolt_head_height+.1, r=m5_nut_diameter/2, $fn=6);

	translate([0, 0, planet_carrier_height-layer_height])
	linear_extrude(height=layer_height+.1, convexity=4)
	{
		difference()
		{
			circle(drive_bearing[bearing_outer_radius]+1);
			circle(drive_bearing[bearing_outer_radius]-.5);
		}
	}

	translate([0, 0, planet_carrier_height-layer_height*2])
	rotate([180, 0, 0])
	cylinder(h=m5_bolt_head_height, r=m5_diameter/2);

	// Planet carrier nuts & bolts.

	for(i=[0:num_planets-1]) assign(a1=planet_angle(i)) assign(a2=planet_angle((i+1) % num_planets) + (i==num_planets-1 ? 360 : 0))
	{
		rotate([0, 0, (a1+a2)/2])
		{
			translate([planet_carrier_radius-4.5, 0, planet_carrier_height/2])
			{
				translate([0, 0, -.1])
				M3_nut_hole(length=planet_carrier_height/2-5+.1, support=1);
				rotate([180, 0, 0])
				translate([0, 0, -.1])
				M3_bolt_hole(length=planet_carrier_height/2-4+.1, support=1);
			}
		}
	}
		

}

module planet_gear()
{
	difference()
	{
		planet_gear_solid();
		planet_gear_void();
	}
}

module planet_gear_solid()
{
	linear_extrude(height=planet_gear_thread_height, convexity=8)
	gear2D(planet_teeth, gear_modulus, gear_pressure_angle, gear_depth_ratio, gear_clearance);
}

module planet_gear_void()
{
	translate([0, 0, -.05])
	linear_extrude(height=planet_gear_thread_height+.1, convexity=8)
	circle(5/2+fit_clearance);
}

module planet_gears(print=0)
{
	p0=(print==0) ? 1 : 0;
	p1=1-p0;

	translate(p0*[0, 0, planet_z])
	{
		for(i=[0:num_planets-1]) assign(a1=i*floor(360/num_planets/planet_angle)*planet_angle+planet_offset) assign(a2=a1*ring_teeth/planet_teeth+180/planet_teeth*odd(sun_teeth+ring_teeth))
		{
			translate(p1*[i*16, 0, 0])
			rotate([0, 0, a1])
			translate(p0*[orbit_radius, 0, 0])
			rotate([0, 0, -a2])
			planet_gear();
		}
	}
}

module cover(print=0)
{
	p0=(print==0) ? 1 : 0;
	p1=1-p0;

	translate(p0*[0, 0, base_size[z]+annulus_size[z]])
	translate(p1*[0, 0, cover_size[z]])
	rotate(p1*[180, 0, 0])
	difference()
	{
		cover_solid();
		cover_void();
	}
}

module cover_solid()
{
	linear_extrude(height=cover_size[z], convexity=4)
		rounded_square(cover_size, 3, $fn=32);
}

module cover_void()
{
	part_name = "Cover";
	part_count = 1;

	// Planet carrier void.

	translate([0, 0, -.1])
	cylinder(h=cover_size[z]-5+.1, r=planet_carrier_radius+1);

	// Bearing pocket.

	translate([0, 0, cover_size[z]-5-moving_clearance])
	cylinder(h=drive_bearing[bearing_length], r=drive_bearing[bearing_outer_radius]+fit_clearance);

    vitamin(part_name, part_count, 1, "105 Bearing", comment="Inner Drive shaft bearing", source="http://www.hobbyking.com/hobbyking/store/__21549__Ball_Bearing_5x10x4mm_2pcs_bag_Turnigy_Trailblazer_1_8_XB_and_XT_1_5_.html");

	// Output bolt shaft.

	translate([0, 0, -.05])
	cylinder(h=cover_size[z]+.1, r=m5_diameter/2+moving_clearance);

	// Annulus mounting bolts.

	for(i=[-1, 1]) for (j=[-1, 1])
	{
		translate([i*annulus_mount_hole_spacing/2, j*annulus_mount_hole_spacing/2, -base_size[z]-annulus_size[z]-5])
		M3_bolt_hole(25, head_length=7, support=1);
	}

    vitamin(part_name, part_count, 4, M3x20, comment="Annulus mounting bolts", source = "McMaster-Carr");

	// Extruder mounting nuts.

	for (bolt = [extruder_bolt_1, extruder_bolt_2, hinge_bolt])
	{
		translate([bolt[x], bolt[y], cover_size[z]-1])
		rotate([180, 0, 0])
		cylinder(h=cover_size[z]-1+.1, r=m3_nut_diameter/2, $fn=6);

		translate([bolt[x], bolt[y], -.05])
		cylinder(h=cover_size[z]+.1, r=m3_diameter/2);

	}

    vitamin(part_name, part_count, 3, M3_nylock, M3_nut, comment="Extruder mounting nuts", source="McMaster-Carr");
}

module rounded_square(size, radius, $fn)
{
	hull()
	{
		for(i=[-1, 1]) for (j=[-1, 1])
			translate([i*(size[x]/2-radius), j*(size[y]/2-radius)])
				circle(radius, $fn=$fn);
	}
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
	linear_extrude(height=head_length+.1, convexity=4)
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

function odd(x) = x-(floor(x/2)*2);
function even(x) = 1-odd(x);
