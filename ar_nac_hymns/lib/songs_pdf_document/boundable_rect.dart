/*
 * Copyright (C) 2018, Pirani E. Fernando <feremp.i+dev@gmail.com>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:extended_pdf_page/extended_pdf.dart';

/// A Rect object that can latter be shifted in position
class BoundableRect extends Rect {
  BoundableRect.fromLTRB(double left, double top, double right, double bottom)
      : super.fromLTRB(left, top, right, bottom);
  BoundableRect.fromLTWH(double left, double top, double width, double height)
      : super.fromLTWH(left, top, width, height);

  BoundableRect boundedTo(double x, double y) => BoundableRect.fromLTWH(
        x + this.left,
        y - this.top,
        this.width,
        this.height,
      );
}
