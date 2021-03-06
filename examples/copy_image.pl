#!/usr/bin/perl

# This script demonstrates usage of the copy() method

use strict;

my ($image_class,$poly_class,$font_class,$image_type);
sub BEGIN {
  chomp (my $package = shift);
  $package or die "\nUsage: generate_test_image.pl IMAGE_CLASS
\t- where IMAGE_CLASS is one of GD or GD::SVG
\t- GD generate png output; GD::SVG generates SVG.\n";

  if ($package eq 'GD::SVG') {
    $image_type = 'svg';
  } else {
    $image_type = 'png';
  }

  eval "use $package";
  $image_class = $package . '::Image';
  $poly_class  = $package . '::Polygon';
  $font_class  = $package . '::Font';
}

my $yoffset;

my $image = $image_class->new('800','1000');

# Allocate some colors
my $white  = $image->colorAllocate(255,255,255);
my $red    = $image->colorAllocate(255,0,0);
my $black  = $image->colorAllocate(0,0,0);
my $blue   = $image->colorAllocate(0,0,255);
my $gray   = $image->colorAllocate(127,127,127);
my $aqua   = $image->colorAllocate(127,255,212);
my $yellow = $image->colorAllocate(255,255,0);
my $orange = $image->colorAllocate(255,165,0);
my $green  = $image->colorAllocate(0,255,0);

# Setting pixels
my @colors = ($black,$red,$blue,$green,$yellow,$gray,$aqua,$orange);

# Make the background transparent (and white)
#$image->transparent($white);

my $string = 'GD vs GD::SVG';
$image->string(gdGiantFont,800/2-((gdGiantFont->width * length $string) / 2),1,$string,$black);

$image->string(gdMediumBoldFont,10,15,'Setting pixels...',$black);
my $color_index = 0;
for (my $x=250;$x<=750;$x+=10) {
  my $color = $colors[$color_index];
  $image->setPixel($x,25,$color);
  $color_index++;
  $color_index = 0 if ($color_index >= @colors);
}

# Drawing lines
$image->string(gdMediumBoldFont,10,35,'Drawing lines...',$black);
$image->setThickness(0.5);
$image->line(250,35,750,35,$aqua);
$image->line(250,40,750,40,$yellow);
$image->line(250,45,750,45,$red);
$image->setThickness(1);
$image->line(250,50,750,50,$black);
$image->line(250,55,750,55,$red);
$image->line(250,65,750,65,$green);
$image->setThickness(2);
$image->line(250,60,750,60,$blue);
$image->line(250,65,750,65,$green);
$image->line(250,70,750,70,$yellow);
$image->setThickness(4);
$image->line(250,75,750,75,$gray);
$image->line(250,80,750,80,$aqua);
$image->line(250,85,750,85,$orange);
$image->setThickness(1);

# Styled lines
$image->setStyle($black,$red,$red,$red,$red,$red,$red,$black,$black,$black,$black,$green);
$image->line(250,90,750,90,gdStyled);

# Brushed lines...
my $brush = $image_class->new(3,3);
$brush->colorAllocate(255,255,255);
my $mystery_color = $brush->colorAllocate(100,100,100);
$brush->setThickness(3);
$brush->line(0,0,0,3,$mystery_color);
$image->setBrush($brush);
$image->line(250,96,750,96,gdBrushed);

# Rectangles
$yoffset = 100;
$yoffset += 15;
$image->string(gdMediumBoldFont,10,$yoffset,'Rectangles...',$black);
$image->rectangle(250,$yoffset,750,$yoffset+20,$black);

# Filled rectangles
$yoffset += 40;
$image->string(gdMediumBoldFont,10,$yoffset,'Filled rectangles...',$black);
$image->filledRectangle(250,$yoffset,750,$yoffset+20,$red);

# Filled rectangles with borders
$yoffset += 40;
$image->string(gdMediumBoldFont,10,$yoffset,'Filled rectangles (bordered)...',$black);
$image->filledRectangle(250,$yoffset,750,$yoffset+20,$aqua);
$image->rectangle(250,$yoffset,750,$yoffset+20,$black);

# Generic distribution of features
my @xs = (qw/250 350 450 550 650/);

# Polygons
$yoffset += 40;
my @star = ([40,0],[50,30],
	    [80,40],[50,50],
	    [40,80],[30,50],
	    [0,40],[30,30],[40,0]);

$image->string(gdMediumBoldFont,10,$yoffset,'Polygons...',$black);
$color_index = 0;
foreach my $startx (@xs) {
  my $polygon = $poly_class->new();
  my $color = $colors[$color_index];
  foreach (@star) {
    my ($x,$y) = @$_;
    $polygon->addPt($startx + $x,$yoffset + $y);
  }
  $image->polygon($polygon,$color);
  $color_index++;
}

# Filled polygons
$yoffset = 320;
# This is the same as above, but using the offset()
# method of the polygon object Kind of a kludgy example (we have to
# start the iterative loop 100 pixels left of where we really want to
# start in order to demonstarte the offset method.
$image->string(gdMediumBoldFont,10,$yoffset,'Filled polygons...',$black);
$color_index = 0;
for (my $x=150;$x<=550;$x+=100) {
  my $polygon = $poly_class->new();
  my $color = $colors[$color_index];
  foreach (@star) {
    my ($starx,$stary) = @$_;
    $polygon->addPt($starx + $x,$stary + $yoffset);
  }
  $polygon->offset(100,0);
  $image->filledPolygon($polygon,$color);
  $color_index++;
}


# Filled bordered polygons
$yoffset += 100;
$image->string(gdMediumBoldFont,10,$yoffset,'Filled polygons (bordered and boxed)...',$black);
$color_index = 0;
foreach my $startx (@xs) {
  my $polygon    = $poly_class->new();
  my $color = $colors[$color_index];
  foreach (@star) {
    my ($x,$y) = @$_;
    $polygon->addPt($startx + $x,$yoffset + $y);
  }
  my ($left,$top,$right,$bottom) = $polygon->bounds();
  $image->rectangle($left,$bottom,$right,$top,$black);
  $image->filledPolygon($polygon,$color);
  $image->polygon($polygon,$black);
  $color_index++;
}

# Ellipses
$yoffset += 100;
my @ellipses = qw/290 390 490 590 690/;
$image->string(gdMediumBoldFont,10,$yoffset,'Ellipses...',$black);
$color_index = 0;
foreach my $x (@ellipses) {
  my $color = $colors[$color_index];
  $image->ellipse($x,$yoffset,80,25,$color);
  $color_index++;
}

# Filled ellipses
$yoffset += 30;
$image->string(gdMediumBoldFont,10,$yoffset,'Filled ellipses...',$black);
$color_index = 0;
foreach my $x (@ellipses) {
  my $color = $colors[$color_index];
  $image->filledEllipse($x,$yoffset,80,25,$color);
  $color_index++;
}

$yoffset += 30;
$image->string(gdMediumBoldFont,10,$yoffset,'Filled ellipses (bordered, increasing thickness)...',$black);
$color_index = 0;
foreach my $x (@ellipses) {
  $image->setThickness($color_index+1);
  my $color = $colors[$color_index];
  $image->filledEllipse($x,$yoffset,80,25,$color);
  $image->ellipse($x,$yoffset,80,25,$black);
  $color_index++;
}
$image->setThickness(1);

# Arcs (closed)
$yoffset += 30;
$image->string(gdMediumBoldFont,10,$yoffset,'Arcs (closed)...',$black);
$color_index = 0;
foreach my $x (@ellipses) {
  my $color = $colors[$color_index];
  $image->arc($x,$yoffset,80,25,0,360,$color);
  # Somewhat stupidly, these can also be created as
  $image->filledArc($x,$yoffset,80,25,0,360,$color,gdNoFill);
  $color_index++;
}

# Arcs on a circle (open)
$yoffset += 30;
$image->string(gdMediumBoldFont,10,$yoffset,'Arcs on a circle (open)...',$black);
$color_index = 0;
foreach my $x (@ellipses) {
  my $color = $colors[$color_index];
  #$image->arc($x,$yoffset,25,80,0,270,$color);
  $image->arc($x,$yoffset,25,25,0,90,$color);   # arcs on a circle...
  $color_index++;
}

# Arcs on an ellipse (open)
$yoffset += 30;
$image->string(gdMediumBoldFont,10,$yoffset,'Arcs on an ellipse (open)...',$black);
$color_index = 0;
foreach my $x (@ellipses) {
  my $color = $colors[$color_index];
  $image->arc($x,$yoffset,25,80,0,270,$color);
  $color_index++;
}

# filledArcs (closed)
$yoffset += 60;
$image->string(gdMediumBoldFont,10,$yoffset,'Filled arcs (closed)...',$black);
$color_index = 0;
foreach my $x (@ellipses) {
  my $color = $colors[$color_index];
  $image->filledArc($x,$yoffset,80,25,0,360,$color);
  $color_index++;
}

# filledArcs (open)
$yoffset += 30;
$image->string(gdMediumBoldFont,10,$yoffset,'Filled arcs (open)...',$black);
$color_index = 0;
foreach my $x (@ellipses) {
  my $color = $colors[$color_index];
  $image->filledArc($x,$yoffset,80,25,40,120,$color);
  $color_index++;
}

# filledArcs (special styles)
$yoffset += 30;
$image->string(gdMediumBoldFont,10,$yoffset,'Filled arcs (special styles)...',$black);
$color_index = 0;

$image->filledArc(290,$yoffset,80,25,60,160,$colors[$color_index++],gdEdged|gdNoFill);
$image->string(gdTinyFont,250,$yoffset+20,'gdEdged|gdNoFill',$black);
$image->filledArc(390,$yoffset,80,25,60,160,$colors[$color_index++],gdArc);
$image->string(gdTinyFont,350,$yoffset+20,'gdArc',$black);
$image->filledArc(490,$yoffset,80,25,60,160,$colors[$color_index++],gdChord);
$image->string(gdTinyFont,450,$yoffset+20,'gdChord',$black);
$image->filledArc(590,$yoffset,80,25,60,160,$colors[$color_index++],gdChord|gdNoFill);
$image->string(gdTinyFont,550,$yoffset+20,'gdChord|gdNoFill',$black);

$image->filledArc(690,$yoffset,80,25,60,160,$colors[$color_index++],gdArc);
$image->filledArc(690,$yoffset,80,25,60,160,$colors[0],gdEdged|gdNoFill);
$image->string(gdTinyFont,630,$yoffset+20,'gdArc, then gdEdged|gdNoFill',$black);

# Fonts...
$yoffset += 40;
$image->string(gdMediumBoldFont,10,$yoffset,'Fonts',$black);

# Print examples of the oo-method calls
$image->string(gdTinyFont,250,$yoffset,'gdTinyFont',$black);
$image->string($font_class->Tiny,400,$yoffset,"$font_class->Tiny",$black);

$image->string(gdSmallFont,250,$yoffset+20,'gdSmallFont',$black);
$image->string($font_class->Small,400,$yoffset+20,"$font_class->Small",$black);

$image->string(gdMediumBoldFont,250,$yoffset+40,'gdMediumBoldFont',$black);
$image->string($font_class->MediumBold,400,$yoffset+40,"$font_class->MediumBold",$black);

$image->string(gdLargeFont,250,$yoffset+60,'gdLargeFont',$black);
$image->string($font_class->Large,400,$yoffset+60,"$font_class->Large",$black);

$image->string(gdGiantFont,250,$yoffset+80,'gdGiantFont',$black);
$image->string($font_class->Giant,400,$yoffset+80,"$font_class->Giant",$black);

# stringUp is broken with SVG 2.32?
#$image->stringUp(gdGiantFont,370,$yoffset+100,'gdGiantFont',$black);
#$image->stringUp($font_class->Giant,550,$yoffset+100,"$font_class->Giant",$black);

# Copy a square into the middle of a new image
my $target = $image_class->new(600,600);
$target->copy($image,200,200,300,300,200,200);
my $black  = $target->colorAllocate(0,0,0);
$target->rectangle(0,0,600,600,$black);

open OUT,">copy-source_image.svg";
print OUT $image->$image_type();
close OUT;

open OUT,">copy-destination_image.svg";
print OUT $target->$image_type();
close OUT;
