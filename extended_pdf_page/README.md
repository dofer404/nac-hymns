# extended_pdf_page

A flutter package project that adds margin and orientation 'management' plus 
a dashed line drawing function over pdf/pdf.dart from the printing package.

Basically code to enable landscape drawing through the use of a coordinate 
system translation and rotation plus some properties, like getPageSize, 
getInMarginsSize, or getMargins, to match the system.

## Getting Started

Inspect the example included.

For help getting started with Flutter, view the Flutter online [documentation](https://flutter.io/).

For help on editing package code, view the [documentation](https://flutter.io/developing-packages/).

## Some Notes

The included functions for dashed line drawing and others (probably not
necessary ones) do not follow the base package primitives, new classes, like 
Point, Size, BoxBordersDistances are introduced. Perhaps a good step would be to 
fix this situation and remove everything that's not necessary.

This package was written to be used in one specific project, AKA ar_nac_hymns, 
but presumably it is usable in generic scenarios. It works, that's all we know.
