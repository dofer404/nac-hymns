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

class Rect {
  Rect._();

  double _left, _top, _right, _bottom;

  Rect.fromLTRB(double left, double top, double right, double bottom) {
    _left = left;
    _top = top;
    _right = right;
    _bottom = bottom;
  }

  Rect.fromLTWH(double left, double top, double width, double height) {
    _left = left;
    _top = top;
    _right = left + width;
    _bottom = top - height;
  }

  double get height => _top - _bottom;

  double get width => _right - _left;

  double get left => _left;

  double get top => _top;

  double get right => _right;

  double get bottom => _bottom;
}
