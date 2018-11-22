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

/// Holds all needed 2D measurements to print the big table of hymns
class BigTable {
  static final outerRect = BoundableRect.fromLTWH(
    0.5115 * cm,
    0.5134 * cm,
    7.8 * cm,
    9.9960 * cm,
  );

  static final dateRect = BoundableRect.fromLTWH(
    outerRect.left + 0.4021 * cm,
    outerRect.top + 0.4004 * cm,
    6.9987 * cm,
    0.7972 * cm,
  );

  static final dateHeaderWidth = 2.7976 * cm;
  static final topHeaderHeight = 0.5997 * cm;
  static final leftHeaderWidth = 2.7976 * cm;

  static final tableRect = BoundableRect.fromLTWH(
    dateRect.left,
    dateRect.top + dateRect.height + 0.5997 * cm,
    dateRect.width,
    topHeaderHeight + 7.2003 * cm,
  );

  static final double rowHeight =
      (BigTable.tableRect.height - BigTable.topHeaderHeight) / 9;
  static final double columnWidth =
      (BigTable.tableRect.width - BigTable.leftHeaderWidth) / 3;

  static final cuttingLinesSquare = BoundableRect.fromLTWH(
    0,
    0,
    outerRect.width + outerRect.left * 2,
    outerRect.height + outerRect.top * 2,
  );
}
