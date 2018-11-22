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

import 'package:ar_nac_hymns/songs_pdf_document/hymn.dart';
import 'package:ar_nac_hymns/songs_pdf_document/service_hymns.dart';
import 'package:ar_nac_hymns/songs_pdf_document/service_hymns_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  static Future<ServiceHymnsData> loadState() async {
    var sharedPreferences = await SharedPreferences.getInstance();

    var r = ServiceHymnsData(
        DateTime(sharedPreferences.getInt("year"),
            sharedPreferences.getInt("month"), sharedPreferences.getInt("day")),
        ServiceHymns(
          start: await loadHymn("start"),
          text: await loadHymn("text"),
          speakerChange: await loadHymn("speakerChange"),
          endOfPreaching: await loadHymn("endOfPreaching"),
          repentance: await loadHymn("repentance"),
          holyCommunion: await loadHymn("holyCommunion"),
          community: await loadHymn("community"),
          descongregation: await loadHymn("descongregation"),
          deceased: await loadHymn("deceased"),
        ));

    print("State loaded");

    return r;
  }

  static dynamic saveState(ServiceHymnsData data) async {
    var result = await saveDate(data.date) &&
        await saveHymn("start", data.serviceHymns.start.hymn,
            data.serviceHymns.start.section, data.serviceHymns.start.stanzas) &&
        await saveHymn("text", data.serviceHymns.text.hymn,
            data.serviceHymns.text.section, data.serviceHymns.text.stanzas) &&
        await saveHymn(
            "speakerChange",
            data.serviceHymns.speakerChange.hymn,
            data.serviceHymns.speakerChange.section,
            data.serviceHymns.speakerChange.stanzas) &&
        await saveHymn(
            "endOfPreaching",
            data.serviceHymns.endOfPreaching.hymn,
            data.serviceHymns.endOfPreaching.section,
            data.serviceHymns.endOfPreaching.stanzas) &&
        await saveHymn(
            "repentance",
            data.serviceHymns.repentance.hymn,
            data.serviceHymns.repentance.section,
            data.serviceHymns.repentance.stanzas) &&
        await saveHymn(
            "holyCommunion",
            data.serviceHymns.holyCommunion.hymn,
            data.serviceHymns.holyCommunion.section,
            data.serviceHymns.holyCommunion.stanzas) &&
        await saveHymn(
            "community",
            data.serviceHymns.community.hymn,
            data.serviceHymns.community.section,
            data.serviceHymns.community.stanzas) &&
        await saveHymn(
            "descongregation",
            data.serviceHymns.descongregation.hymn,
            data.serviceHymns.descongregation.section,
            data.serviceHymns.descongregation.stanzas) &&
        await saveHymn(
            "deceased",
            data.serviceHymns.deceased.hymn,
            data.serviceHymns.deceased.section,
            data.serviceHymns.deceased.stanzas);
    print("State saved");
    return result;
  }

  static Future<Hymn> loadHymn(String hymnName) async {
    var sharedPreferences = await SharedPreferences.getInstance();

    var r = Hymn(
        (sharedPreferences.getString(hymnName + ".hymn") ?? ""),
        (sharedPreferences.getString(hymnName + ".section") ?? ""),
        (sharedPreferences.getString(hymnName + ".stanzas") ?? ""));

    print("Hymn loaded: " +
        hymnName +
        " " +
        r.hymn +
        "." +
        r.section +
        "." +
        r.stanzas);

    return r;
  }

  static dynamic saveHymn(String hymnName, String hymnValue,
      String sectionValue, String stanzasValue) async {
    var sharedPreferences = await SharedPreferences.getInstance();

    var result = await sharedPreferences.setString(
            hymnName + ".hymn", hymnValue) &&
        await sharedPreferences.setString(
            hymnName + ".section", sectionValue) &&
        await sharedPreferences.setString(hymnName + ".stanzas", stanzasValue);

    print("Hymn saved: " +
        hymnName +
        " " +
        hymnValue +
        "." +
        sectionValue +
        "." +
        stanzasValue);

    return result;
  }

  static dynamic saveDate(DateTime date) async {
    var sharedPreferences = await SharedPreferences.getInstance();

    var result = await sharedPreferences.setInt("year", date.year) &&
        await sharedPreferences.setInt("month", date.month) &&
        await sharedPreferences.setInt("day", date.day);

    print("Date saved");

    return result;
  }

  static dynamic loadDate() async {
    var sharedPreferences = await SharedPreferences.getInstance();

    var r = DateTime(
        sharedPreferences.getInt("year") ?? DateTime.now().year,
        sharedPreferences.getInt("month") ?? DateTime.now().month,
        sharedPreferences.getInt("day") ?? DateTime.now().day);

    print("Date loaded");

    return r;
  }
}
