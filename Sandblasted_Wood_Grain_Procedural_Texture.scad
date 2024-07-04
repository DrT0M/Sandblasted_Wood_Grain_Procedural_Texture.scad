	Srands = 0;	//seed
	Arands = 0.15;	//amplitude
	Nrands = 2^18;	//powers of 6 for 3D
	Vrands = rands(-Arands,+Arands,Nrands,Srands);
	L3 = round(Nrands^(1/3));	//3D:64^3	L3 x L3 x L3 randomized cubic grid
	L2 = round(sqrt(Nrands));	//2D:512^2	L2 x L2 randomized square grid
	L1 = Nrands;			//1D:262144	
	L = [L1, L2, L3];		//L[ dim-1 ]
/*****************************************************************************/
function noise_interpolated(point,dim) =	//dim from 1 up to 3
	let(	D = dim
	,	W = L[D-1]

	,	fl1 = D<1 ? 0 : floor(point[D-1])
	,	fr1 = D<1 ? 0 : - fl1+point[D-1]
	,	lo1 = D<1 ? 0 : (fl1 < 0 ? (W - (-fl1 % W)) % W : fl1 % W)
	,	hi1 = D<1 ? 0 : (lo1 + 1) % W
	,	Fr1 = 1 - fr1

	,	fl2 = D<2 ? 0 : floor(point[D-2])
	,	fr2 = D<2 ? 0 : - fl2+point[D-2]
	,	lo2 = D<2 ? 0 : (fl2 < 0 ? (W - (-fl2 % W)) % W : fl2 % W)
	,	hi2 = D<2 ? 0 : (lo2 + 1) % W
	,	Fr2 = 1 - fr2

	,	fl3 = D<3 ? 0 : floor(point[D-3])
	,	fr3 = D<3 ? 0 : - fl3+point[D-3]
	,	lo3 = D<3 ? 0 : (fl3 < 0 ? (W - (-fl3 % W)) % W : fl3 % W)
	,	hi3 = D<3 ? 0 : (lo3 + 1) % W
	,	Fr3 = 1 - fr3
	)
	Vrands[hi1 + W*hi2 + W*W*hi3] * fr3 * fr2 * fr1 + 
	Vrands[lo1 + W*hi2 + W*W*hi3] * fr3 * fr2 * Fr1 +
	Vrands[hi1 + W*lo2 + W*W*hi3] * fr3 * Fr2 * fr1 + 
	Vrands[lo1 + W*lo2 + W*W*hi3] * fr3 * Fr2 * Fr1 +
	Vrands[hi1 + W*hi2 + W*W*lo3] * Fr3 * fr2 * fr1 + 
	Vrands[lo1 + W*hi2 + W*W*lo3] * Fr3 * fr2 * Fr1 +
	Vrands[hi1 + W*lo2 + W*W*lo3] * Fr3 * Fr2 * fr1 + 
	Vrands[lo1 + W*lo2 + W*W*lo3] * Fr3 * Fr2 * Fr1;
/*****************************************************************************/
function fractal_variation(point,dim,octaves=1,level=0,Mandelbrot_persistence=2) = 
	[ for(	Level=[0:octaves-1]	)	1 ] *
	[ for(	Level=[0:octaves-1]	)	
		noise_interpolated(point*2^(-Level),dim) 
		* ((is_undef(Mandelbrot_persistence) ? 2 : Mandelbrot_persistence)^(Level+1-octaves)) ];
/*****************************************************************************/
function G(x) = (x - floor(x))^2;	//growth ring seasonal density variation
function wood_density(x,y,z) =
//	This Sandblasted Wood Grain Procedural Texture in OpenSCAD is licensed under
//	MIT License
//
//	Copyright (c) 2024 DrT0M
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
//
	G(	1.3 *    fractal_variation([x,y,z]*2.5,dim=3,octaves=5)	//radial tree ring variations
	+ sqrt( (x*3-600*fractal_variation([z*0.55+40],dim=1,octaves=7,Mandelbrot_persistence=10))^2	//vertical tree trunk variations
	    +   (y*3)^2	) / 10	
	);
/*****************************************************************************/
module	grain(x,y,z,dot)
{
	let(	density = wood_density(x,y,z)
	,	greyscale = (40+100*(1-density))/255
	)	translate([x,y,z])
		color( c = [1,1,1]*greyscale)		//density grayscale
		cube(dot,center=true);
}
/*****************************************************************************/
module	veneer(x0,x1,y0,y1,z0,z1,dot)
{
	for( z = [z0:dot:z1] )
	for( y = [y0:dot:y1] )
	for( x = [x0:dot:x1] )
		grain(x,y,z,dot);
}
/*****************************************************************************/
*	box_sleeve();
module	box_sleeve()
{
	let(	INCH = 25.4	//mm
	,	D1 = 1.00*INCH,	D0 = 0
	,	W1 = 1.20*INCH,	W0 = -W1
	,	L1 = 1.75*INCH,	L0 = -L1
	,	dot = 0.5	//mm
	)
	{
		veneer( D0, D0, W0, W1, L0, L1, dot );
		veneer( D1, D1, W0, W1, L0, L1, dot );
* /*open ends*/	veneer( D0, D1, W0, W0, L0, L1, dot );
* /*open ends*/	veneer( D0, D1, W1, W1, L0, L1, dot );
		veneer( D0, D1, W0, W1, L0, L0, dot );
		veneer( D0, D1, W0, W1, L1, L1, dot );
	}
}
/*****************************************************************************/
	sandblasted();
module	sandblasted()
{
	let(	INCH = 25.4	//mm
	,	D1 = 1.00*INCH,	D0 = 0
	,	W1 = 1.20*INCH,	W0 = -W1
	,	L1 = 1.75*INCH,	L0 = -L1
	,	dot = 0.5	//mm
	,	grit = 0.4	//mm (higher grit for deeper sand ablation effect)
	)
	{
		translate([D0,W0,L0]) rotate([0,-90,0])	scale([dot,dot,+grit])	surfaceData(
			[for( W = [W0:dot:W1] )	//along Y-axis
			[for( L = [L0:dot:L1] )	//along X-axis
				wood_density(D0,W,L)]]);
		translate([D1,W0,L0]) rotate([0,-90,0])	scale([dot,dot,-grit])	surfaceData(
			[for( W = [W0:dot:W1] )	//along Y-axis
			[for( L = [L0:dot:L1] )	//along X-axis
				wood_density(D1,W,L)]]);
* /*open ends*/	translate([D0,W0,L0]) rotate([0,-90,-90])scale([dot,dot,-grit])	surfaceData(
			[for( D = [D0:dot:D1] )	//along Y-axis
			[for( L = [L0:dot:L1] )	//along X-axis
				wood_density(D,W0,L)]]);
* /*open ends*/	translate([D0,W1,L0]) rotate([0,-90,-90])scale([dot,dot,+grit])	surfaceData(
			[for( D = [D0:dot:D1] )	//along Y-axis
			[for( L = [L0:dot:L1] )	//along X-axis
				wood_density(D,W1,L)]]);
		translate([D0,W0,L0])			scale([dot,dot,-grit])	surfaceData(
			[for( W = [W0:dot:W1] )	//along Y-axis
			[for( D = [D0:dot:D1] )	//along X-axis
				wood_density(D,W,L0)]]);
		translate([D0,W0,L1])			scale([dot,dot,+grit])	surfaceData(
			[for( W = [W0:dot:W1] )	//along Y-axis
			[for( D = [D0:dot:D1] )	//along X-axis
				wood_density(D,W,L1)]]);
	}
}
/*****************************************************************************/
/* OpenSCAD User Manual/Tips and Tricks - Data Heightmap
data = 	[ for(a=[0:10:360])
	[ for(b=[0:10:360])
		cos(a-b)+4*sin(a+b)+(a+b)/40 ]
	];

surfaceData(data, center=true);
cube();
*/
// operate like the builtin module surface() but
// from a matrix of floats instead of a text file
module surfaceData(M, center=false, convexity=10){
	n = len(M);
	m = len(M[0]);
	miz  = min([for(Mi=M) min(Mi)]);
	minz = miz<0? miz-1 : -1;
	ctr  = center ? [-(m-1)/2, -(n-1)/2, 0]: [0,0,0];
	points = [ // original data points
		for(i=[0:n-1])for(j=[0:m-1]) [j, i, M[i][j]] +ctr,
		[   0,   0, minz ] + ctr, 
		[ m-1,   0, minz ] + ctr, 
		[ m-1, n-1, minz ] + ctr, 
		[   0, n-1, minz ] + ctr,
		// additional interpolated points at the center of the quads
		// the points bellow with `med` set to 0 are not used by faces
		for(i=[0:n-1])for(j=[0:m-1])
			let( med = i==n-1 || j==m-1 ? 0:
			(M[i][j]+M[i+1][j]+M[i+1][j+1]+M[i][j+1])/4 )
		[j+0.5, i+0.5, med] + ctr
	];
	faces = [ // faces connecting data points to interpolated ones
		for(i=[0:n-2])
		for(j=[i*m:i*m+m-2]) 
		each [ [   j+1,     j, j+n*m+4 ], 
		       [     j,   j+m, j+n*m+4 ], 
		       [   j+m, j+m+1, j+n*m+4 ], 
		       [ j+m+1,   j+1, j+n*m+4 ] ] ,
		// lateral and bottom faces
		[ for(i=[0:m-1])           i, n*m+1,   n*m ], 
		[ for(i=[m-1:-1:0]) -m+i+n*m, n*m+3, n*m+2 ], 
		[ for(i=[n-1:-1:0])      i*m,   n*m, n*m+3 ], 
		[ for(i=[0:n-1])     i*m+m-1, n*m+2, n*m+1 ],
		[n*m, n*m+1, n*m+2, n*m+3 ]
	];
	polyhedron(points, faces, convexity);
}
//tab stop @ 8
//$vpt=[ 0.00, 0.00, 0.00];
//$vpr=[60.60, 0.00,300.3];	//[70.40, 0.00,22.90];
//$vpd=292.71;
//$vpf=22.50;
//viewport 441x597
