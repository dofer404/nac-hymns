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

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);
}

const landscapeA4 = PDFPageFormat(841.89, 595.28);
const portraitA4 = PDFPageFormat(595.28, 841.89);

/// Basically an extension of [PDFGraphics] that implements [drawDashedLine]
class ExtendedPdfGraphics extends PDFGraphics {
  /// Draws a line from [a] to [b] with the pattern "dash space dash space ... "
  ///
  /// The doubles in [dashDistances] are interpreted as distances
  /// following the pattern. That is, the first double is the length
  /// of a dash, the second is the length of a space, and so on.
  /// When the last double has been used then we start over from the
  /// first one without interrupting the pattern.
  void drawPointsDefinedDashedLine(
      List<double> dashDistances, Point a, Point b) {
    if (dashDistances.length == 0) {
      return;
    }

    /// Function variable: Returns [currentValue] increased by 1. Returns 0 if
    /// [currentValue] is outside the range 0-[dashDistances.length].
    var getCircularIndexNextValue = (int currentValue) {
      if (++currentValue >= dashDistances.length || currentValue < 0) {
        return 0;
      }
      return currentValue;
    };

    // The first distance is a dash.
    var isSpace = false;

    // Starting point
    moveTo(a.x, a.y);

    int distanceIndex = 0;

    // Obtain the destination/ending point of the first dash
    Map<String, dynamic> aOnePointMap =
        makeCloserPoint(dashDistances[distanceIndex], a, b);

    while (aOnePointMap.length > 0) {
      a = aOnePointMap["point"];
      if (isSpace) {
        moveTo(a.x, a.y);
      } else {
        lineTo(a.x, a.y);
      }
      distanceIndex = getCircularIndexNextValue(distanceIndex);
      isSpace = !isSpace;
      aOnePointMap = makeCloserPoint(dashDistances[distanceIndex], a, b);
    }
  }

  /// See [drawPointsDefinedDashedLine]
  void drawDashedLine(
      List<double> dashDistances, double x1, double y1, double x2, double y2) {
    drawPointsDefinedDashedLine(dashDistances, Point(x1, y1), Point(x2, y2));
  }

  /// Tries to return a new [Point] which is [distance] away from [a] in the
  /// direction of [b] without exceeding it.
  ///
  /// Returns a [Map] with a 'point' [Point] and an 'isTruncated' [bool]. Bool
  /// will be [true] when the new Point was successfully created at the
  /// indicated distance. Bool will be [false] when the new Point ended up
  /// closer than expected, that is, when the new Point is in the same position
  /// as [b].
  /// Returns an empty Map when the two points [a] and [b] are in the same
  /// place.
  Map<String, dynamic> makeCloserPoint(double distance, Point a, Point b) {
    double pointsDistance;
    if (a.x == b.x && a.y == b.y) {
      return {};
    } else {
      pointsDistance = getDistance(a, b);
    }
    bool isTruncated = false;
    if (pointsDistance <= distance) {
      a = b;
      isTruncated = true;
    } else {
      a = getPointAt(distance, a, b);
    }
    return {"point": a, "isTruncated": isTruncated};
  }

  /// Returns a new [Point] which is [distance] away from [fromPoint]
  /// in the direction of [toPoint].
  Point getPointAt(double distance, Point fromPoint, Point toPoint) {
    var pointsDistance = getDistance(fromPoint, toPoint);
    var cos = (toPoint.x - fromPoint.x) / pointsDistance;
    var sin = (toPoint.y - fromPoint.y) / pointsDistance;

    return new Point(
        fromPoint.x + distance * cos, fromPoint.y + distance * sin);
  }

  double getDistance(Point fromPoint, Point toPoint) {
    return sqrt(
        pow(fromPoint.x - toPoint.x, 2) + pow(fromPoint.y - toPoint.y, 2));
  }

  ExtendedPdfGraphics(ExtendedPdfPage page, PDFStream buf) : super(page, buf);
}
