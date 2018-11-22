# extended_pdf_page

A flutter package project that adds margin and orientation 'management' plus 
a dashed line drawing function over pdf/pdf.dart from the printing package.

Basecally code to enable landscape drawing throu the use of a coordinate 
system translation and rotation plus some properties, like getPageSize, 
getInMarginsSize, or getMargins, to match the system.

## Getting Started

Inspect the example included.

For help getting started with Flutter, view our online [documentation](https://flutter.io/).

For help on editing package code, view the [documentation](https://flutter.io/developing-packages/).

## Some Notes

The included functions for dashed line drawing and others (problably not 
necesary ones) do not follow the base package primitives, new classes, like 
Point, Size, BoxBordersDistances are introduced. Perhaps a good step would be to 
fix this situation and remove everything that's not necesary.

This package was written to be used in one specific project, AKA print_my_hymns, 
but presumably it is usable in generic scenarios. It works, thas all we know.