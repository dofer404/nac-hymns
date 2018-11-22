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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ar_nac_hymns/data.dart';
import 'package:ar_nac_hymns/songs_pdf_document/hymn.dart';
import 'package:ar_nac_hymns/songs_pdf_document/service_hymns.dart';
import 'package:ar_nac_hymns/songs_pdf_document/service_hymns_data.dart';

enum ButtonAction { print, share }

class AddHymTablePage extends StatefulWidget {
  final void Function() Function(
    Map<String, String> l10nStrings,
    ServiceHymnsData serviceData,
  ) printPdf;

  final void Function() Function(
    Map<String, String> l10nStrings,
    ServiceHymnsData serviceData,
    GlobalKey<State<StatefulWidget>> shareWidget,
  ) sharePdf;

  final GlobalKey<State<StatefulWidget>> shareWidget;

  final Map<String, String> l10nStrings;

  AddHymTablePage(
    this.l10nStrings,
    this.printPdf,
    this.sharePdf,
    this.shareWidget,
  );

  @override
  _AddHymTablePageState createState() => _AddHymTablePageState(
        l10nStrings,
        this.printPdf,
        this.sharePdf,
        this.shareWidget,
      );
}

class _AddHymTablePageState extends State<AddHymTablePage> {
  void Function() Function(
    Map<String, String> l10nStrings,
    ServiceHymnsData serviceData,
  ) printPdf;

  void Function() Function(
    Map<String, String> l10nStrings,
    ServiceHymnsData serviceData,
    GlobalKey<State<StatefulWidget>> shareWidget,
  ) sharePdf;

  List<HymnInputs> hymnInputs;

  Map<String, String> l10nStrings;

  List<Widget> hymnInputsWidgets;

  GlobalKey<State<StatefulWidget>> shareWidget;

  ServiceHymnsData data;

  _AddHymTablePageState(
    this.l10nStrings,
    this.printPdf,
    this.sharePdf,
    this.shareWidget,
  );

  void initState() {
    super.initState();
    loadData();
  }

  void dispose() {
    // Clean up the controller when the Widget is disposed
    for (HymnInputs hymInput in hymnInputs) {
      hymInput.dispose();
    }
    super.dispose();
  }

  void loadDate() {
    if (dateController != null) {
      dateController.text = data.date.day.toString() +
          "/" +
          data.date.month.toString() +
          "/" +
          data.date.year.toString();
    }
  }

  void loadHymns() {
    if (hymnInputs != null) {
      for (var i = 0; i < hymnInputs.length; i++) {
        hymnInputs.elementAt(i).hymnController.text =
            data.serviceHymns.byIndexGetHymn(i).hymn;
        hymnInputs.elementAt(i).sectionController.text =
            data.serviceHymns.byIndexGetHymn(i).section;
        hymnInputs.elementAt(i).stanzasController.text =
            data.serviceHymns.byIndexGetHymn(i).stanzas;
      }
    }
  }

  void loadData() async {
    var state = await Data.loadState();
    setState(() {
      this.data = state;
      loadDate();
      loadHymns();
    });
  }

  Widget printButton() => Padding(
        padding: const EdgeInsets.all(0.0),
        child: Builder(
          builder: (context) => RaisedButton(
                onPressed: () => buttonPress(
                      ButtonAction.print,
                      context,
                      shareWidget,
                    ),
                child: Center(
                  child: Row(
                    children: [
                      Icon(Icons.print),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(l10nStrings["printDocument"]),
                      )
                    ],
                  ),
                ),
              ),
        ),
      );
  Widget shareButton() => Padding(
        padding: const EdgeInsets.all(0.0),
        child: Builder(
          builder: (context) => RaisedButton(
                onPressed: () => buttonPress(
                      ButtonAction.share,
                      context,
                      shareWidget,
                    ),
                color: Colors.indigoAccent,
                child: Row(
                  children: [
                    Icon(Icons.share),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        l10nStrings["shareDocument"],
                      ),
                    )
                  ],
                ),
              ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (this.hymnInputs == null) {
      var results = HymnInputs.inputs(context, l10nStrings);
      this.hymnInputs = results[0];
      this.hymnInputsWidgets = results[1];
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Crear Himnos de Servicio"),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.white70,
        child: Column(
          children: <Widget>[
            dateInput(),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      children: () {
                        List<Widget> r = [];
                        r.addAll(this.hymnInputsWidgets);
                        r.add(Row(
                          children: <Widget>[
                            Flexible(
                              child: printButton(),
                            ),
                            shareButton()
                          ],
                        ));
                        return r;
                      }(),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void buttonPress(
    ButtonAction buttonAction,
    BuildContext context,
    GlobalKey<State<StatefulWidget>> shareWidget,
  ) {
    var newService = new ServiceHymnsData(
      () {
        String s = dateController.text;
        List<String> lll = s.split("/");
        return DateTime(
            int.parse(lll[2]), int.parse(lll[1]), int.parse(lll[0]));
      }(),
      ServiceHymns.fromList(
        () {
          List<Hymn> list = [];
          for (var i = 0; i < this.hymnInputs.length; i++) {
            list.add(Hymn(
                this.hymnInputs[i].hymnController.text,
                this.hymnInputs[i].sectionController.text,
                this.hymnInputs[i].stanzasController.text));
          }
          return list;
        }(),
      ),
    );
    if (newService != null) {
      if (buttonAction == ButtonAction.print) {
        printPdf(l10nStrings, newService)();
      } else if ((buttonAction == ButtonAction.share)) {
        sharePdf(l10nStrings, newService, shareWidget)();
      }
    }
  }

  var dateController = TextEditingController(
      text: DateTime.now().day.toString() +
          "/" +
          DateTime.now().month.toString() +
          "/" +
          DateTime.now().year.toString());

  Widget dateInput() => Padding(
        padding: EdgeInsets.fromLTRB(200, 0, 0, 10),
        child: TextField(
          autofocus: true,
          controller: dateController,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(labelText: "Fecha"),
          onChanged: (String value) async {
            List<String> lll = value.split("/");
            try {
              var date = DateTime(
                  int.parse(lll[2]), int.parse(lll[1]), int.parse(lll[0]));
              await Data.saveDate(date);
            } catch (e) {}
          },
        ),
      );
}

class HymnInputs {
  String textLabel;
  String hymnId;
  BuildContext context;
  HymnInputs(this.hymnId, this.context, Map<String, String> l10nStrings) {
    textLabel = l10nStrings[hymnId];
  }

  TextEditingController hymnController = new TextEditingController();
  TextEditingController sectionController = new TextEditingController();
  TextEditingController stanzasController = new TextEditingController();

  void dispose() {
    // Clean up the controller when the Widget is disposed
    hymnController.dispose();
    sectionController.dispose();
    stanzasController.dispose();
  }

  String sectionInputValue;
  String stanzasInputValue;
  String hymnInputValue;

  static List<dynamic> inputs(
      BuildContext context, Map<String, String> l10nStrings) {
    List<HymnInputs> hymnInputs = [
      HymnInputs("start", context, l10nStrings),
      HymnInputs("text", context, l10nStrings),
      HymnInputs("speakerChange", context, l10nStrings),
      HymnInputs("endOfPreaching", context, l10nStrings),
      HymnInputs("repentance", context, l10nStrings),
      HymnInputs("holyCommunion", context, l10nStrings),
      HymnInputs("community", context, l10nStrings),
      HymnInputs("descongregation", context, l10nStrings),
      HymnInputs("deceased", context, l10nStrings),
    ];
    List<Widget> rowInputs = [];
    for (var i = 0; i < hymnInputs.length; i++) {
      rowInputs.add(
        Row(
          children: [
            hymnInputs[i].hymnInput,
            hymnInputs[i].sectionInput,
            hymnInputs[i].stanzasInput,
          ],
        ),
      );
    }
    return [hymnInputs, rowInputs];
  }

  Widget get hymnInput => Flexible(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: TextField(
            keyboardType: TextInputType.number,
            controller: hymnController,
            decoration: InputDecoration(labelText: textLabel),
            onChanged: (newInputValue) {
              Data.saveHymn(hymnId, newInputValue, sectionController.text,
                  stanzasController.text);
            },
          ),
        ),
      );

  Widget get sectionInput => Flexible(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: TextField(
            keyboardType: TextInputType.text,
            controller: sectionController,
            decoration: InputDecoration(labelText: "Sección"),
            onChanged: (newInputValue) {
              Data.saveHymn(hymnId, hymnController.text, newInputValue,
                  stanzasController.text);
            },
          ),
        ),
      );

  Widget get stanzasInput => Flexible(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: TextField(
            keyboardType: TextInputType.number,
            controller: stanzasController,
            decoration: InputDecoration(labelText: "Estrofas"),
            onChanged: (newInputValue) {
              Data.saveHymn(hymnId, hymnController.text, sectionController.text,
                  newInputValue);
            },
          ),
        ),
      );
}

