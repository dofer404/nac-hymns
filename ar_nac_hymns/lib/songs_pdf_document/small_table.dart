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

import 'package:ar_nac_hymns/songs_pdf_document.dart';
import 'package:ar_nac_hymns/songs_pdf_document/boundable_rect.dart';

/// Holds all needed 2D measurements to print the small table of hymns
class SmallTable {
  static final contentBorders = BoundableRect.fromLTWH(
    0.4981 * cm,
    0.2999 * cm,
    5.6973 * cm,
    7.6889 * cm,
  );

  static final leftHeaderWidth = 2 * cm;
  static final topHeaderHeight = 0.5997 * cm;

  static final tableSquare = BoundableRect.fromLTWH(
    contentBorders.left,
    contentBorders.top + (1.6968 * cm),
    5.6974 * cm, // Width
    5.9902 * cm, // Height
  );

  static double get columnWidth => (tableSquare.width - leftHeaderWidth) / 3;
  static double get rowHeight => (tableSquare.height - topHeaderHeight) / 9;

  static final innerVerticalsBox = BoundableRect.fromLTRB(
    tableSquare.left + leftHeaderWidth + columnWidth,
    tableSquare.top,
    tableSquare.right - columnWidth,
    tableSquare.bottom,
  );

  static final datePosition =
      BoundableRect.fromLTWH(2.6210 * cm, 1.0311 * cm, 0, 0);

  static final imagePlaceHolder = BoundableRect.fromLTWH(
    contentBorders.left,
    contentBorders.top,
    leftHeaderWidth,
    ((tableSquare.top + topHeaderHeight) - contentBorders.top) -
        // Bottom Image Margin
        (0.1483 * cm),
  );

  static final cuttingLinesSquare = BoundableRect.fromLTWH(
    0,
    0,
    contentBorders.width + contentBorders.left * 2,
    contentBorders.height + contentBorders.top * 2,
  );
}
