// import 'package:cardmaker/stack_board/lib/helpers.dart';
// import 'package:flutter/painting.dart';

// import 'ex_locale.dart';

// extension ExTextStyle on TextStyle {
//   Map<String, dynamic> toJson() {
//     return <String, dynamic>{
//       if (color != null) 'color': color?.toARGB32(),
//       if (decoration != null) 'decoration': decoration?.toString(),
//       if (decorationColor != null)
//         'decorationColor': decorationColor?.toARGB32(),
//       if (decorationStyle != null)
//         'decorationStyle': decorationStyle?.toString(),
//       if (decorationThickness != null)
//         'decorationThickness': decorationThickness,
//       if (fontWeight != null) 'fontWeight': fontWeight?.toString(),
//       if (fontStyle != null) 'fontStyle': fontStyle?.toString(),
//       if (fontFamily != null) 'fontFamily': fontFamily,
//       if (fontFamilyFallback != null)
//         'fontFamilyFallback': fontFamilyFallback?.join(','),
//       if (fontSize != null) 'fontSize': fontSize,
//       if (letterSpacing != null) 'letterSpacing': letterSpacing,
//       if (wordSpacing != null) 'wordSpacing': wordSpacing,
//       if (textBaseline != null) 'textBaseline': textBaseline?.toString(),
//       if (height != null) 'height': height,
//       if (locale != null) 'locale': locale?.toJson(),
//     };
//   }
// }

// TextStyle? jsonToTextStyle(Map<String, dynamic> data) {
//   return TextStyle(
//     color: ColorDeserialization.from(data['color']),
//     decoration: data['decoration'] == null
//         ? null
//         : stringToTextDecoration(asT<String>(data['decoration'])),
//     decorationColor: data['decorationColor'] == null
//         ? null
//         : Color(asT<int>(data['decorationColor'])),
//     decorationStyle: ExEnum.tryParse<TextDecorationStyle>(
//       TextDecorationStyle.values,
//       asT<String>(data['decorationStyle']),
//     ),
//     decorationThickness: data['decorationThickness'] == null
//         ? null
//         : asT<double>(data['decorationThickness']),
//     fontWeight: ExEnum.tryParse<FontWeight>(
//       FontWeight.values,
//       asT<String>(data['fontWeight']),
//     ),
//     fontStyle: ExEnum.tryParse<FontStyle>(
//       FontStyle.values,
//       asT<String>(data['fontStyle']),
//     ),
//     fontFamily: data['fontFamily'] == null
//         ? null
//         : asT<String>(data['fontFamily']),
//     fontFamilyFallback: data['fontFamilyFallback'] == null
//         ? null
//         : asT<String>(data['fontFamilyFallback']).split(','),
//     fontSize: data['fontSize'] == null ? null : asT<double>(data['fontSize']),
//     letterSpacing: data['letterSpacing'] == null
//         ? null
//         : asT<double>(data['letterSpacing']),
//     wordSpacing: data['wordSpacing'] == null
//         ? null
//         : asT<double>(data['wordSpacing']),
//     textBaseline: ExEnum.tryParse(
//       TextBaseline.values,
//       asT<String>(data['textBaseline']),
//     ),

//     height: data['height'] == null ? null : asT<double>(data['height']),
//     locale: data['locale'] == null ? null : jsonToLocale(asMap(data['locale'])),
//   );
// }

// TextDecoration? stringToTextDecoration(String data) {
//   if (!data.contains('combine')) {
//     switch (data) {
//       case 'TextDecoration.none':
//         return TextDecoration.none;
//       case 'TextDecoration.underline':
//         return TextDecoration.underline;
//       case 'TextDecoration.overline':
//         return TextDecoration.overline;
//       case 'TextDecoration.lineThrough':
//         return TextDecoration.lineThrough;
//       default:
//         return TextDecoration.none;
//     }
//   }

//   final List<String> values = data.split('[')[1].split(']')[0].split(', ');
//   final List<TextDecoration> decorations = <TextDecoration>[];
//   for (final String value in values) {
//     switch (value) {
//       case 'underline':
//         decorations.add(TextDecoration.underline);
//         break;
//       case 'overline':
//         decorations.add(TextDecoration.overline);
//         break;
//       case 'lineThrough':
//         decorations.add(TextDecoration.lineThrough);
//         break;
//       default:
//         break;
//     }
//   }

//   return TextDecoration.combine(decorations);
// }
import 'package:cardmaker/widgets/common/stack_board/lib/helpers.dart';
import 'package:flutter/painting.dart';

import 'ex_locale.dart';

// Helper function to serialize FontWeight to its numeric weight value
int? fontWeightToJson(FontWeight? weight) {
  if (weight == null) return null;

  if (weight == FontWeight.w100) return 100;
  if (weight == FontWeight.w200) return 200;
  if (weight == FontWeight.w300) return 300;
  if (weight == FontWeight.w400 || weight == FontWeight.normal) return 400;
  if (weight == FontWeight.w500) return 500;
  if (weight == FontWeight.w600) return 600;
  if (weight == FontWeight.w700 || weight == FontWeight.bold) return 700;
  if (weight == FontWeight.w800) return 800;
  if (weight == FontWeight.w900) return 900;

  return 400; // Default to normal
}

// Helper function to deserialize FontWeight from numeric value
FontWeight? fontWeightFromJson(dynamic data) {
  if (data == null) return null;

  int weightValue;
  if (data is num) {
    weightValue = data.toInt();
  } else if (data is String) {
    weightValue = int.tryParse(data) ?? 400;
  } else {
    return FontWeight.normal;
  }

  switch (weightValue) {
    case 100:
      return FontWeight.w100;
    case 200:
      return FontWeight.w200;
    case 300:
      return FontWeight.w300;
    case 400:
      return FontWeight.normal;
    case 500:
      return FontWeight.w500;
    case 600:
      return FontWeight.w600;
    case 700:
      return FontWeight.bold;
    case 800:
      return FontWeight.w800;
    case 900:
      return FontWeight.w900;
    default:
      return FontWeight.normal;
  }
}

extension ExTextStyle on TextStyle {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (color != null) 'color': color?.toARGB32(),
      if (decoration != null) 'decoration': decoration?.toString(),
      if (decorationColor != null)
        'decorationColor': decorationColor?.toARGB32(),
      if (decorationStyle != null)
        'decorationStyle': decorationStyle?.toString(),
      if (decorationThickness != null)
        'decorationThickness': decorationThickness,
      if (fontWeight != null) 'fontWeight': fontWeightToJson(fontWeight),
      if (fontStyle != null) 'fontStyle': fontStyle?.toString(),
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontFamilyFallback != null)
        'fontFamilyFallback': fontFamilyFallback?.join(','),
      if (fontSize != null) 'fontSize': fontSize,
      if (letterSpacing != null) 'letterSpacing': letterSpacing,
      if (wordSpacing != null) 'wordSpacing': wordSpacing,
      if (textBaseline != null) 'textBaseline': textBaseline?.toString(),
      if (height != null) 'height': height,
      if (locale != null) 'locale': locale?.toJson(),
      if (shadows != null && shadows!.isNotEmpty)
        'shadows': shadows
            ?.map(
              (shadow) => {
                'offset': {'dx': shadow.offset.dx, 'dy': shadow.offset.dy},
                'blurRadius': shadow.blurRadius,
                'color': shadow.color.toARGB32(),
              },
            )
            .toList(),
    };
  }
}

TextStyle? jsonToTextStyle(Map<String, dynamic> data) {
  return TextStyle(
    color: ColorDeserialization.from(data['color']),
    decoration: data['decoration'] == null
        ? null
        : stringToTextDecoration(asT<String>(data['decoration'])),
    decorationColor: data['decorationColor'] == null
        ? null
        : Color(asT<int>(data['decorationColor'])),
    decorationStyle: ExEnum.tryParse<TextDecorationStyle>(
      TextDecorationStyle.values,
      asT<String>(data['decorationStyle']),
    ),
    decorationThickness: data['decorationThickness'] == null
        ? null
        : asT<double>(data['decorationThickness']),
    fontWeight: fontWeightFromJson(data['fontWeight']),
    fontStyle: ExEnum.tryParse<FontStyle>(
      FontStyle.values,
      asT<String>(data['fontStyle']),
    ),
    fontFamily: data['fontFamily'] == null
        ? null
        : asT<String>(data['fontFamily']),
    fontFamilyFallback: data['fontFamilyFallback'] == null
        ? null
        : asT<String>(data['fontFamilyFallback']).split(','),
    fontSize: data['fontSize'] == null ? null : asT<double>(data['fontSize']),
    letterSpacing: data['letterSpacing'] == null
        ? null
        : asT<double>(data['letterSpacing']),
    wordSpacing: data['wordSpacing'] == null
        ? null
        : asT<double>(data['wordSpacing']),
    textBaseline: ExEnum.tryParse(
      TextBaseline.values,
      asT<String>(data['textBaseline']),
    ),
    height: data['height'] == null ? null : asT<double>(data['height']),
    locale: data['locale'] == null ? null : jsonToLocale(asMap(data['locale'])),
    shadows: data['shadows'] == null
        ? null
        : (data['shadows'] as List<dynamic>).map((s) {
            final shadowData = asMap(s);
            return Shadow(
              offset: Offset(
                asT<double>(shadowData['offset']['dx']) ?? 0.0,
                asT<double>(shadowData['offset']['dy']) ?? 0.0,
              ),
              blurRadius: asT<double>(shadowData['blurRadius']) ?? 0.0,
              color: Color(asT<int>(shadowData['color'])),
            );
          }).toList(),
  );
}

TextDecoration? stringToTextDecoration(String? data) {
  if (data == null) return null;

  if (!data.contains('combine')) {
    switch (data) {
      case 'TextDecoration.none':
        return TextDecoration.none;
      case 'TextDecoration.underline':
        return TextDecoration.underline;
      case 'TextDecoration.overline':
        return TextDecoration.overline;
      case 'TextDecoration.lineThrough':
        return TextDecoration.lineThrough;
      default:
        return TextDecoration.none;
    }
  }

  final List<String> values = data.split('[')[1].split(']')[0].split(', ');
  final List<TextDecoration> decorations = <TextDecoration>[];
  for (final String value in values) {
    switch (value.trim()) {
      case 'underline':
        decorations.add(TextDecoration.underline);
        break;
      case 'overline':
        decorations.add(TextDecoration.overline);
        break;
      case 'lineThrough':
        decorations.add(TextDecoration.lineThrough);
        break;
      default:
        break;
    }
  }

  return decorations.isEmpty
      ? TextDecoration.none
      : TextDecoration.combine(decorations);
}
