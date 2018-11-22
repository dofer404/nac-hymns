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

class ServiceHymns {
  Hymn start;
  Hymn text;
  Hymn speakerChange;
  Hymn endOfPreaching;
  Hymn repentance;
  Hymn holyCommunion;
  Hymn community;
  Hymn descongregation;
  Hymn deceased;

  ServiceHymns.fromList(List<Hymn> list) {
    for (var i = 0; i < 9; i++) {
      byIndexSetHymn(i, list[i]);
    }
  }

  ServiceHymns({
    this.start,
    this.text,
    this.speakerChange,
    this.endOfPreaching,
    this.repentance,
    this.holyCommunion,
    this.community,
    this.descongregation,
    this.deceased,
  });

  void byIndexSetHymn(int i, Hymn hymn) {
    switch (i) {
      case 0:
        start = hymn;
        break;
      case 1:
        text = hymn;
        break;
      case 2:
        speakerChange = hymn;
        break;
      case 3:
        endOfPreaching = hymn;
        break;
      case 4:
        repentance = hymn;
        break;
      case 5:
        holyCommunion = hymn;
        break;
      case 6:
        community = hymn;
        break;
      case 7:
        descongregation = hymn;
        break;
      case 8:
        deceased = hymn;
        break;
      default:
    }
  }

  Hymn byIndexGetHymn(int i) {
    switch (i) {
      case 0:
        return start;
        break;
      case 1:
        return text;
        break;
      case 2:
        return speakerChange;
        break;
      case 3:
        return endOfPreaching;
        break;
      case 4:
        return repentance;
        break;
      case 5:
        return holyCommunion;
        break;
      case 6:
        return community;
        break;
      case 7:
        return descongregation;
        break;
      case 8:
        return deceased;
        break;
      default:
        return null;
    }
  }
}
