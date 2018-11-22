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

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as pkg_image;
import 'package:ar_nac_hymns/add_hym_table.dart';
import 'package:ar_nac_hymns/songs_pdf_document.dart';
import 'package:ar_nac_hymns/songs_pdf_document/hymn.dart';
import 'package:ar_nac_hymns/songs_pdf_document/service_hymns.dart';
import 'package:ar_nac_hymns/songs_pdf_document/service_hymns_data.dart';
import 'package:printing/printing.dart';

import 'l10n.dart';

void main() async => runApp(
      MaterialApp(
        localizationsDelegates: [
          const L10nDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: L10n.supportedLocales(),
        home: MyHomePage(),
      ),
    );

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final shareWidget = new GlobalKey();
  final ServiceHymnsData dummyServiceData = ServiceHymnsData(
      DateTime(2018, 10, 17),
      ServiceHymns(
        start: Hymn("1", "R", ""),
        text: Hymn("22", "R", ""),
        speakerChange: Hymn("333", "R", ""),
        endOfPreaching: Hymn("99999", "R", "1-2"),
        repentance: Hymn("182", "R", ""),
        holyCommunion: Hymn("72", "R", ""),
        community: Hymn("36", "R", ""),
        descongregation: Hymn("382", "I", ""),
        deceased: Hymn("150", "R", ""),
      ));

  void Function() _printPdf(
      Map<String, String> l10nStrings, ServiceHymnsData serviceData) {
    return () async {
      print("Print ...");
      ByteData fontFile =
          await rootBundle.load('resources/fonts/Ubuntu-Regular.ttf');
      ByteData imgByteData = await rootBundle.load('resources/imgs/logo.png');
      pkg_image.Image image =
          pkg_image.decodeImage(Uint8List.view(imgByteData.buffer));
      final pdf = SongsPdfDocument(image, fontFile, l10nStrings, serviceData);
      Printing.printPdf(document: pdf);
    };
  }

  void Function() sharePdf(
    Map<String, String> l10nStrings,
    ServiceHymnsData serviceData,
    GlobalKey<State<StatefulWidget>> shareWidget,
  ) {
    return () async {
      print("Share ...");
      ByteData fontFile =
          await rootBundle.load('resources/fonts/Ubuntu-Regular.ttf');
      ByteData imgByteData = await rootBundle.load('resources/imgs/logo.png');
      pkg_image.Image image =
          pkg_image.decodeImage(Uint8List.view(imgByteData.buffer));
      final pdf = SongsPdfDocument(image, fontFile, l10nStrings, serviceData);

      // iPad specific (?) Not tested
      final RenderBox referenceBox =
          shareWidget.currentContext.findRenderObject();
      final topLeft =
          referenceBox.localToGlobal(referenceBox.paintBounds.topLeft);
      final bottomRight =
          referenceBox.localToGlobal(referenceBox.paintBounds.bottomRight);
      final bounds = Rect.fromPoints(topLeft, bottomRight);
      Printing.sharePdf(document: pdf, bounds: bounds);
    };
  }

  @override
  Widget build(BuildContext context) {
    return AddHymTablePage(
      L10n.of(context).l10nStrings,
      _printPdf,
      sharePdf,
      shareWidget,
    );
  }

  Widget get twoButtonsMain => Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).text("my_church_hymns_title")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
                child: Text(L10n.of(context).text('print_document')),
                onPressed: _printPdf(
                  L10n.of(context).l10nStrings,
                  dummyServiceData,
                )),
            RaisedButton(
              key: shareWidget,
              child: Text(L10n.of(context).text('share_document')),
              onPressed: sharePdf(
                L10n.of(context).l10nStrings,
                dummyServiceData,
                shareWidget,
              ),
            )
          ],
        ),
      ));
}

