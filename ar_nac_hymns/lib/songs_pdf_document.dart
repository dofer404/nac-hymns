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

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:image/image.dart' as pkg_image;

import 'package:extended_pdf_page/extended_pdf.dart';
import 'package:ar_nac_hymns/songs_pdf_document/big_table.dart';
import 'package:ar_nac_hymns/songs_pdf_document/service_hymns_data.dart';
import 'package:ar_nac_hymns/songs_pdf_document/small_table.dart';

const List<double> dashedLineStyle = [5, 3, 0.5, 3, 3, 3, 0.5, 3];
const cm = PDFPageFormat.cm;

enum TableType { big, small }

/// One page PDF containing 7 hym tables: 6 of compact design, 1 of formal
/// archive-ready design as requested by INA-Mnes.
class SongsPdfDocument extends PDFDocument {
  final someArbiraryWorkingMargins =
      Rect.fromLTRB(1.45415 * cm, 0.85415 * cm, 1.4662 * cm, 0.8345 * cm);

  final fontSize1 = 12.0;
  final fontSize2 = 9.0;
  final fontSize3 = 8.0;
  final fontSize4 = 7.0;
  final fontSize5 = 6.5;

  PDFFont font;
  pkg_image.Image image;
  Map<String, String> l10nStrings;

  ExtendedPdfPage _page;
  ExtendedPdfGraphics g; // Used for drawing during all method calls

  SongsPdfDocument(
    pkg_image.Image image,
    ByteData fontFile,
    this.l10nStrings,
    ServiceHymnsData serviceHymnsData,
  ) : super(deflate: zlib.encode) {
    if (fontFile == null) {
      this.font = PDFFont(this);
    } else {
      this.font = PDFTTFFont(this, fontFile);
    }

    this.image = image;

    _page = ExtendedPdfPage(
      this,
      pageFormat: portraitA4,
      margins: someArbiraryWorkingMargins,
      drawingOrientation: DrawingOrientation.rotatedLandscape,
    );

    // Used for drawing during all method calls
    g = _page.getGraphics();

    g.setColor(PDFColor(0.0, 0.0, 0.0));
    g.setLineWidth(linesWidth);
    paintAllTables(serviceHymnsData);
  }

  void paintSolidBoxBorders(Rect box, {Rect bordersToPaint}) {
    if (bordersToPaint == null) {
      bordersToPaint = allBorders;
    }

    if (bordersToPaint.top > 0.0) {
      g.drawLine(box.left, box.top, box.right, box.top);
    }
    if (bordersToPaint.right > 0.0) {
      g.drawLine(box.right, box.top, box.right, box.bottom);
    }
    if (bordersToPaint.bottom > 0.0) {
      g.drawLine(box.right, box.bottom, box.left, box.bottom);
    }
    if (bordersToPaint.left > 0.0) {
      g.drawLine(box.left, box.bottom, box.left, box.top);
    }
    g.strokePath();
  }

  static final allBorders = Rect.fromLTRB(1, 1, 1, 1);
  static final cuttingLinesWidth = 0.0420 * cm;
  static final linesWidth = 0.0210 * cm;

  void paintDashedBoxBorders(Rect box, {Rect bordersToPaint}) {
    if (bordersToPaint == null) {
      bordersToPaint = allBorders;
    }

    if (bordersToPaint.top > 0.0) {
      g.drawDashedLine(dashedLineStyle, box.left, box.top, box.right, box.top);
    }
    if (bordersToPaint.right > 0.0) {
      g.drawDashedLine(
          dashedLineStyle, box.right, box.top, box.right, box.bottom);
    }
    if (bordersToPaint.bottom > 0.0) {
      g.drawDashedLine(
          dashedLineStyle, box.right, box.bottom, box.left, box.bottom);
    }
    if (bordersToPaint.left > 0.0) {
      g.drawDashedLine(
          dashedLineStyle, box.left, box.bottom, box.left, box.top);
    }
    g.strokePath();
  }

  void drawCenteredText(
      String text, double fontSize, double left, double top, double cellWidth) {
    if (text == "") {
      text = "-";
    } else if (text == null) {
      text = "";
    }
    var inCellTextLeftPos =
        (cellWidth / 2) - (((font.stringSize(text).w * fontSize) / 2) * 1.1);
    g.drawString(
      font,
      fontSize,
      text,
      left + inCellTextLeftPos,
      top,
    );
  }

  void paintAllTables(ServiceHymnsData serviceHymnsData) {
    var drawingBorders = _page.contentAreaBorders;
    var rightFlag = (int i) => i == 3 ? 1.0 : 0.0;
    var bottomFlag = (int i, int j) => (i < 2 && j == 0) || j > 0 ? 1.0 : 0.0;

    for (var j = 0; j < 2; j++) {
      for (var i = 0; i < 4; i++) {
        bool isBigTable = (i == 0 && j == 1);

        if ((i < 2 && j > 0) && !isBigTable) {
          continue;
        }

        double posX =
            drawingBorders.left + (i * SmallTable.cuttingLinesSquare.width);
        double posY =
            drawingBorders.top - (j * SmallTable.cuttingLinesSquare.height);

        var tableType = isBigTable ? TableType.big : TableType.small;
        var bordersFlags = isBigTable
            ? /*Not top*/ Rect.fromLTRB(1.0, 0.0, 1.0, 1.0)
            : Rect.fromLTRB(1.0, 1.0, rightFlag(i), bottomFlag(i, j));

        printTable(tableType, serviceHymnsData, x: posX, y: posY);
        g.setLineWidth(cuttingLinesWidth);
        printTableCuttingLines(tableType,
            x: posX, y: posY, bordersToPaint: bordersFlags);
        g.setLineWidth(linesWidth);
      }
    }
  }

  void printTableCuttingLines(TableType tableType,
      {@required double x, @required double y, @required Rect bordersToPaint}) {
    var cuttingLinesBox;
    if (tableType == TableType.big) {
      cuttingLinesBox = BigTable.cuttingLinesSquare.boundedTo(x, y);
    } else {
      cuttingLinesBox = SmallTable.cuttingLinesSquare.boundedTo(x, y);
    }

    paintDashedBoxBorders(cuttingLinesBox, bordersToPaint: bordersToPaint);
  }

  void printTable(TableType tableType, ServiceHymnsData data,
      {double x, double y}) {
    Rect dateSquare, tableSquare;
    double topHeaderHeight, rowHeight, leftHeaderWidth, columnWidth;
    if (tableType == TableType.big) {
      paintSolidBoxBorders(BigTable.outerRect.boundedTo(x, y));

      dateSquare = BigTable.dateRect.boundedTo(x, y);
      paintSolidBoxBorders(dateSquare);

      tableSquare = BigTable.tableRect.boundedTo(x, y);
      paintSolidBoxBorders(tableSquare);

      topHeaderHeight = BigTable.topHeaderHeight;
      rowHeight = BigTable.rowHeight;
      leftHeaderWidth = BigTable.leftHeaderWidth;
      columnWidth = BigTable.columnWidth;
    } else {
      dateSquare = SmallTable.datePosition.boundedTo(x, y);

      tableSquare = SmallTable.tableSquare.boundedTo(x, y);
      // Top Header Lines
      paintSolidBoxBorders(
          Rect.fromLTWH(
              tableSquare.left + SmallTable.leftHeaderWidth,
              tableSquare.top,
              tableSquare.width - SmallTable.leftHeaderWidth,
              SmallTable.topHeaderHeight),
          bordersToPaint: Rect.fromLTRB(1.0, 1.0, 1.0, 0.0));
      // Non-header Right-bottom lines
      paintSolidBoxBorders(
          Rect.fromLTWH(
              tableSquare.left + SmallTable.leftHeaderWidth,
              tableSquare.top - SmallTable.topHeaderHeight,
              tableSquare.width - SmallTable.leftHeaderWidth,
              tableSquare.height - SmallTable.topHeaderHeight),
          bordersToPaint: Rect.fromLTRB(0.0, 0.0, 1.0, 1.0));
      // Non-header Bottom-Left-Top lines
      paintSolidBoxBorders(
          Rect.fromLTWH(
              tableSquare.left,
              tableSquare.top - SmallTable.topHeaderHeight,
              SmallTable.leftHeaderWidth,
              tableSquare.height - SmallTable.topHeaderHeight),
          bordersToPaint: Rect.fromLTRB(1.0, 1.0, 0.0, 1.0));

      topHeaderHeight = SmallTable.topHeaderHeight;
      rowHeight = SmallTable.rowHeight;
      leftHeaderWidth = SmallTable.leftHeaderWidth;
      columnWidth = SmallTable.columnWidth;
    }

    // Will use this Map to print strings later.
    Map<int, Rect> rows = {};
    rows[1] = Rect.fromLTWH(
      tableSquare.left,
      tableSquare.top - topHeaderHeight,
      tableSquare.width,
      rowHeight,
    );
    for (var i = 0; i < 4; i++) {
      paintSolidBoxBorders(rows[rows.keys.last],
          bordersToPaint: /*Top and Bottom*/ Rect.fromLTRB(0.0, 1.0, 0.0, 1.0));
      rows[rows.keys.last + 2] = Rect.fromLTWH(
        rows[rows.keys.last].left,
        rows[rows.keys.last].top - (rowHeight * 2),
        rows[rows.keys.last].width,
        rows[rows.keys.last].height,
      );
    }

    paintSolidBoxBorders(rows[rows.keys.last],
        bordersToPaint: /*only top*/ Rect.fromLTRB(0.0, 1.0, 0.0, 0.0));

    var leftAndRight = Rect.fromLTRB(1.0, 0.0, 1.0, 0.0);

    var lnrInVLines = Rect.fromLTRB(tableSquare.left + leftHeaderWidth,
        dateSquare.top, tableSquare.right - columnWidth, dateSquare.bottom);

    if (tableType == TableType.big) {
      paintSolidBoxBorders(lnrInVLines, bordersToPaint: leftAndRight);
    }

    lnrInVLines = Rect.fromLTRB(lnrInVLines.left, tableSquare.top,
        lnrInVLines.right, tableSquare.bottom);
    paintSolidBoxBorders(lnrInVLines, bordersToPaint: leftAndRight);

    var onlyLeft = Rect.fromLTRB(1.0, 0.0, 0.0, 0.0);
    var centerVLine = Rect.fromLTRB(lnrInVLines.left + columnWidth,
        dateSquare.top, lnrInVLines.left + columnWidth, dateSquare.bottom);

    if (tableType == TableType.big) {
      paintSolidBoxBorders(centerVLine, bordersToPaint: onlyLeft);
    }

    centerVLine = Rect.fromLTRB(centerVLine.left, tableSquare.top,
        centerVLine.right, tableSquare.bottom);
    paintSolidBoxBorders(centerVLine, bordersToPaint: onlyLeft);

    var texts = buildTableTexts(tableType, data, rows, x, y);

    var leftMargin = 0.1 * cm;
    for (var i = 0; i < texts.length; i++) {
      for (var j = 0; j < texts[i].keys.length; j++) {
        if (texts[i][texts[i].keys.elementAt(j)][3] == null) {
          g.drawString(
              font,
              texts[i][texts[i].keys.elementAt(j)][2],
              texts[i].keys.elementAt(j),
              texts[i][texts[i].keys.elementAt(j)][0] + leftMargin,
              texts[i][texts[i].keys.elementAt(j)][1]);
        } else {
          drawCenteredText(
              texts[i].keys.elementAt(j),
              texts[i][texts[i].keys.elementAt(j)][2],
              texts[i][texts[i].keys.elementAt(j)][0],
              texts[i][texts[i].keys.elementAt(j)][1],
              texts[i][texts[i].keys.elementAt(j)][3]);
        }
      }
    }

    if (tableType == TableType.small) {
      if (image.width > 0 && image.height > 0) {
        PDFImage img = PDFImage(
          this,
          image: image.data.buffer.asUint8List(),
          width: image.width,
          height: image.height,
        ); // TODO: specify the preferred image width (367) and height (508)

        Rect imagePlaceHolder = SmallTable.imagePlaceHolder.boundedTo(x, y);
        double iphRatio = imagePlaceHolder.width / imagePlaceHolder.height;
        double imageRatio = image.width / image.height;
        double imageHeight, imageWidth;
        Point centerShift;
        if (imageRatio < iphRatio) {
          // Height match
          imageHeight = imagePlaceHolder.height;
          imageWidth = imageRatio * imageHeight;
          centerShift = Point((imagePlaceHolder.width - imageWidth) / 2, 0);
        } else if (imageRatio >= iphRatio) {
          // Width match
          imageWidth = imagePlaceHolder.width;
          imageHeight = imageWidth / imageRatio;
          centerShift = Point(0, (imagePlaceHolder.height - imageHeight) / 2);
        }

        g.drawImage(
            img,
            imagePlaceHolder.left + centerShift.x,
            (imagePlaceHolder.top - centerShift.y) - imageHeight,
            imageWidth,
            imageHeight);

        g.strokePath();
      } else {
        print("Warning!! The image is either of zero width or it is of zero " +
            " height (or both)");
      }
    }
  }

  List<Map<String, List<double>>> buildTableTexts(TableType tableType,
      ServiceHymnsData data, Map<int, Rect> rows, double x, double y) {
    Rect dateSquare, tableSquare, lnrInVLines, centerVLine;
    double leftHeaderWidth, columnWidth, fttdFactor, tableContentFontSize;
    List<List<dynamic>> leftHeadersTexts;

    if (tableType == TableType.big) {
      dateSquare = BigTable.dateRect.boundedTo(x, y);
      tableSquare = BigTable.tableRect.boundedTo(x, y);
      leftHeaderWidth = BigTable.leftHeaderWidth;
      columnWidth = BigTable.columnWidth;
      lnrInVLines = Rect.fromLTRB(tableSquare.left + leftHeaderWidth,
          dateSquare.top, dateSquare.right - columnWidth, dateSquare.bottom);
      centerVLine = Rect.fromLTRB(lnrInVLines.left + columnWidth,
          tableSquare.top, lnrInVLines.left + columnWidth, tableSquare.bottom);
      fttdFactor = 1.4;
      tableContentFontSize = fontSize1;

      leftHeadersTexts = [
        [l10nStrings["start"], fontSize2],
        [l10nStrings["text"], fontSize2],
        [l10nStrings["speakerChange"], fontSize2],
        [l10nStrings["endOfPreaching"], fontSize2],
        [l10nStrings["repentance"], fontSize2],
        [l10nStrings["holyCommunion"], fontSize2],
        [l10nStrings["community"], fontSize2],
        [l10nStrings["descongregation"], fontSize2],
        [l10nStrings["deceased"], fontSize2],
      ];
    } else {
      dateSquare = SmallTable.datePosition.boundedTo(x, y);
      tableSquare = SmallTable.tableSquare.boundedTo(x, y);
      leftHeaderWidth = SmallTable.leftHeaderWidth;
      columnWidth = SmallTable.columnWidth;
      lnrInVLines = Rect.fromLTRB(tableSquare.left + leftHeaderWidth,
          tableSquare.top, tableSquare.right - columnWidth, tableSquare.bottom);
      centerVLine = Rect.fromLTRB(lnrInVLines.left + columnWidth,
          tableSquare.top, lnrInVLines.left + columnWidth, tableSquare.bottom);
      fttdFactor = 1.0;
      tableContentFontSize = fontSize2;

      leftHeadersTexts = [
        [l10nStrings["start"], fontSize2],
        [l10nStrings["text"], fontSize2],
        [l10nStrings["speakerChange"], fontSize3],
        [l10nStrings["endOfPreaching"], fontSize3],
        [l10nStrings["repentance"], fontSize5],
        [l10nStrings["holyCommunion"], fontSize2],
        [l10nStrings["community"], fontSize5],
        [l10nStrings["descongregation"], fontSize5],
        [l10nStrings["deceased"], fontSize2],
      ];
    }

    double fromTopTextDistance = fontSize1 * fttdFactor;
    List<Map<String, List<double>>> texts = [
      // date row
      tableType == TableType.big
          ? makeRow(
              defaultCenterInWidth: BigTable.columnWidth,
              centerInWidth1: -1.0,
              text1: l10nStrings["date"],
              text2: data.date.day.toString(),
              text3: data.date.month.toString(),
              text4: data.date.year.toString(),
              defaultSize: fontSize1,
              left1: dateSquare.left,
              left2: lnrInVLines.left,
              left3: centerVLine.left,
              left4: lnrInVLines.right,
              top: dateSquare.top - fromTopTextDistance)
          : {
              l10nStrings["date"] +
                  ":  " +
                  data.date.day.toString() +
                  "/" +
                  data.date.month.toString() +
                  "/" +
                  data.date.year.toString(): [
                dateSquare.left,
                dateSquare.top,
                fontSize2,
                null
              ],
            },
      // header row
      makeRow(
          defaultCenterInWidth: BigTable.columnWidth,
          text1: null,
          text2: l10nStrings["hymn"],
          text3: l10nStrings["section"],
          text4: l10nStrings["stanzas"],
          defaultSize: fontSize3,
          left1: dateSquare.left,
          left2: lnrInVLines.left,
          left3: centerVLine.left,
          left4: lnrInVLines.right,
          top: tableSquare.top - (fromTopTextDistance / fttdFactor)),
    ];
    // 1 to 9 rows
    for (var i = 1; i < 10; i += 2) {
      texts.add(makeRow(
          defaultCenterInWidth: columnWidth,
          centerInWidth1: -1.0,
          text1: leftHeadersTexts[i - 1][0],
          text2: data.serviceHymns.byIndexGetHymn(i - 1).hymn,
          text3: data.serviceHymns.byIndexGetHymn(i - 1).section,
          text4: data.serviceHymns.byIndexGetHymn(i - 1).stanzas,
          defaultSize: tableContentFontSize,
          size1: leftHeadersTexts[i - 1][1],
          left1: tableSquare.left,
          left2: lnrInVLines.left,
          left3: centerVLine.left,
          left4: lnrInVLines.right,
          top: rows[i].top - fromTopTextDistance));
      // Avoid trying to insert a 10th row (there is no 10th row)
      if (i < 8) {
        texts.add(makeRow(
            defaultCenterInWidth: columnWidth,
            centerInWidth1: -1.0,
            text1: leftHeadersTexts[i][0],
            text2: data.serviceHymns.byIndexGetHymn(i).hymn,
            text3: data.serviceHymns.byIndexGetHymn(i).section,
            text4: data.serviceHymns.byIndexGetHymn(i).stanzas,
            defaultSize: tableContentFontSize,
            size1: leftHeadersTexts[i][1],
            left1: tableSquare.left,
            left2: lnrInVLines.left,
            left3: centerVLine.left,
            left4: lnrInVLines.right,
            top: rows[i].bottom - fromTopTextDistance));
      }
    }
    return texts;
  }

  Map<String, List<double>> makeRow(
      {@required String text1,
      @required String text2,
      @required String text3,
      @required String text4,
      double defaultCenterInWidth,
      double centerInWidth1,
      double centerInWidth2,
      double centerInWidth3,
      double centerInWidth4,
      @required double defaultSize,
      double size1,
      double size2,
      double size3,
      double size4,
      @required double left1,
      @required double left2,
      @required double left3,
      @required double left4,
      @required double top}) {
    double Function(double) calcCellWidth = (cellWidth) {
      return cellWidth == null
          ? defaultCenterInWidth
          : cellWidth < 0.0 ? null : cellWidth;
    };

    return {
      text1: [left1, top, size1 ?? defaultSize, calcCellWidth(centerInWidth1)],
      text2: [left2, top, size2 ?? defaultSize, calcCellWidth(centerInWidth2)],
      text3: [left3, top, size3 ?? defaultSize, calcCellWidth(centerInWidth3)],
      text4: [left4, top, size4 ?? defaultSize, calcCellWidth(centerInWidth4)]
    };
  }
}
