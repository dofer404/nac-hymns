/*
 * Copyright (C) 2018, Pirani E. Fernando <feremp.i+dev@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

part of 'extended_pdf.dart';

enum DrawingOrientation {
  landscape,
  rotatedLandscape,
  portrait,
  rotatedPortrait
}

/// An extended [PDFPage] that's aware of margins and facilitates drawing
/// orientation management.
///
/// Also implements [ExtendedPdfGraphics.drawPointsDefinedDashedLine]
class ExtendedPdfPage extends PDFPage {
  Rect _margins;
  DrawingOrientation _drawingOrientation;

  Rect get margins => _margins;

  Size get pageSize => Size(
        // Invert width an height
        pageFormat.height,
        pageFormat.width,
      );

  Size get contentAreaSize => Size(
        pageSize.width - (_margins.left + _margins.right),
        pageSize.height - (_margins.top + _margins.bottom),
      );

  /// Holds x coordinates of the lateral borders and y coordinates of the top
  /// and bottom borders of this page
  Rect get borders => Rect.fromLTWH(0, pageSize.height, pageSize.width, 0);

  /// Holds x coordinates of the lateral borders and y coordinates of the top
  /// and bottom borders of the internal box (the content area) delimited by the
  /// margins of this page
  Rect get contentAreaBorders => Rect.fromLTRB(
      _margins.left,
      _margins.bottom + contentAreaSize.height,
      _margins.left + contentAreaSize.width,
      _margins.bottom);

  /// This is the current drawing orientation when creating [ExtendedPdfGraphics]
  /// objects thru [getGraphics]
  DrawingOrientation get drawingOrientation => _drawingOrientation;

  /// Draw as if the page is oriented the way [drOr] indicates. Note this is
  /// independent of the orientation of the page.
  ///
  /// Background: This is a workaround due to a problem on al least one android
  /// phone. The problem being that the printing mechanism assumes the page
  /// orientation is PORTRAIT. This causes cropping of LANDSCAPE oriented pages.
  /// Using this method you can draw on a PORTRAIT oriented page as if it where
  /// LANDSCAPE oriented, thus allowing the flawed printing mechanism to print
  /// without cropping the content.
  ///
  /// @see [getGraphics]
  void setDrawingOrientation(DrawingOrientation drOr) {
    _drawingOrientation = drOr;
  }

  /// Returns a [ExtendedPdfGraphics] object, which can then be used to render
  /// on to this page in the same direction that was retrieved from
  /// [getDrawingOrientation] at the moment of creation. If a previous
  /// [PDFGraphics] object was used, this object is appended to the page, and
  /// will be drawn over the top of any previous objects.
  /// A change in [DrawingOrientation] won't affect already created
  /// [ExtendedPdfGraphics] objects.
  ///
  /// @return a new [ExtendedPdfGraphics] object to be used to draw on this page.
  ExtendedPdfGraphics getGraphics() {
    var stream = new PDFObjectStream(pdfDocument);
    var g = new ExtendedPdfGraphics(this, stream.buf);
    contents.add(stream);
    switch (drawingOrientation) {
      case DrawingOrientation.landscape:
        g.setTransform(getOriginOnLanscapeBottomLeftTransformMatrix4());
        g.setTransform(getClockwiseHalfPiRotateMatrix4());
        break;
      case DrawingOrientation.rotatedLandscape:
        g.setTransform(getOriginOnRotatedLanscapeBottomLeftTransformMatrix4());
        g.setTransform(getCounterClockwiseHalfPiRotateMatrix4());
        break;
      case DrawingOrientation.rotatedPortrait:
        g.setTransform(getOriginOnRotatedPortraitBottomLeftTransformMatrix4());
        g.setTransform(getOnePiRotateMatrix4());
        break;
      default:
    }

    /// Is enabling this a good idea? Probably complicates the logic for drawing
    /// interchangeably from margins and page borders.
    if (false) {
      g.setTransform(getOriginOnBlmTransformMatrix4());
    }

    return g;
  }

  Matrix4 getOriginOnLanscapeBottomLeftTransformMatrix4() =>
      Matrix4.translationValues(
        0.0,
        pageFormat.height,
        0.0,
      );

  Matrix4 getOriginOnRotatedLanscapeBottomLeftTransformMatrix4() =>
      Matrix4.translationValues(
        pageFormat.width,
        0.0,
        0.0,
      );

  Matrix4 getOriginOnRotatedPortraitBottomLeftTransformMatrix4() =>
      Matrix4.translationValues(
        pageFormat.width,
        pageFormat.height,
        0.0,
      );

  /// Moves the origin of the coordinate system to coincide with the bottom left
  /// margins corner.
  ///
  /// That is -after the translation- the bottom left margin corner will be at:
  ///   (x, y) = (0, 0)
  Matrix4 getOriginOnBlmTransformMatrix4() => Matrix4.translationValues(
        _margins.left,
        -_margins.bottom,
        0.0,
      );

  /// Rotates the axis half pi clockwise (1.5 radians)
  ///
  /// Try using 1.5 instead of 1.499999 and the drawings disappear. A mystery in
  /// my ignorance.
  Matrix4 getClockwiseHalfPiRotateMatrix4() => Matrix4.rotationZ(pi * 1.499999);

  /// Rotates the axis one pi (1 radian)
  ///
  /// Try using 1 instead of 0.999999. We don't know what may happen.
  /// See [getClockwiseHalfPiRotateMatrix4]
  Matrix4 getOnePiRotateMatrix4() => Matrix4.rotationZ(pi * 0.999999);

  /// Rotates the axis half pi counterclockwise (0.5 radians)
  ///
  /// Try using 0.5 instead of 0.499999. We don't know what may happen.
  /// See [getClockwiseHalfPiRotateMatrix4]
  Matrix4 getCounterClockwiseHalfPiRotateMatrix4() =>
      Matrix4.rotationZ(pi * 0.499999);

  ExtendedPdfPage(
    PDFDocument pdfDocument, {
    PDFPageFormat pageFormat,
    Rect margins,
    DrawingOrientation drawingOrientation = DrawingOrientation.portrait,
  }) : super(
          pdfDocument,
          pageFormat: pageFormat,
        ) {
    this._margins = margins;

    setDrawingOrientation(drawingOrientation);
  }

  /// Translate top-to-bottom y-values to bottom-to-top values
  ///
  /// This and [applyTopLeftMargins] form the [fnaTransform]
  Point fixPointsYAxis(Point p, {bool useMargins = true}) {
    return Point(p.x, fixYAxis(p.y, useMargins: useMargins));
  }

  double fixYAxis(double y, {bool useMargins = true}) {
    if (useMargins) {
      return this.contentAreaSize.height - y;
    } else {
      return this.pageSize.height - y;
    }
  }

  /// Moves [p.x] to the right by [_margins.left] and [p.y] to
  /// the bottom by [_margins.top]
  ///
  /// This and [fixPointsYAxis(p)] form the [fnaTransform]
  Point applyTopLeftMargins(Point p) {
    p = Point(p.x + _margins.left, p.y - _margins.top);
    return p;
  }

  Point fnaTransform(Point p) {
    return applyTopLeftMargins(fixPointsYAxis(p));
  }
}
