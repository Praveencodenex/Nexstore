import 'package:flutter/material.dart';
import 'size_config.dart';

const kPrimaryColor =  Color(0xFF004b24);
const kPrimaryColorAccent =  Color(0xFF108A11);
const kAccentTextAccentOrange = Color(0xFFFF7006);
const kAccentTextAccentYellow =   Color(0xFFFFD500);
const kMarqueeTextColor = Color(0xFF8F853C);
const kAppBarColor = Color(0xFFEEECE6);
const kMarqueeColor = Color(0xFFFDF4D1);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryColorTint1 =  Color(0xffd1dff8);
const kPrimaryColorCardBack =  Color(0xffd9e3dd);
const kPrimaryColorTint =  Color(0xffe4edfa);
const kWhiteColor = Color(0xFFFFFFFF);
const kGreyColor = Color(0xFFEDEDED);
const kGreyColorLight = Color(0xFFF6F6F6);
const kGreyColorLightMed = Color(0xFFCECECE);
const kSecondaryColor = Color(0xFFABABAB);
const kDescription = Color(0xFF7C7C7C);
const kTextColor = Color(0xFF5B5B5B);
const kBlackColor = Color(0xFF000000);

const String _primaryFont = 'manrope';
const String _secondaryFont = 'manrope';

final headingH2Style = TextStyle(
  fontFamily:_primaryFont ,
  fontSize: getProportionateScreenFont(25),
  fontWeight: FontWeight.w900,
  color: kBlackColor,
);

final headingH3Style = TextStyle(
  fontFamily:_primaryFont ,
  fontSize: getProportionateScreenFont(20),
  fontWeight: FontWeight.w900,
  color: kBlackColor,
);

final headingH4Style = TextStyle(
  fontFamily:_primaryFont ,
  fontSize: getProportionateScreenFont(15),
  fontWeight: FontWeight.w900,
  color: kBlackColor,
);

final buttonStyleStyle = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(16),
  fontWeight: FontWeight.w700,
  color: kBlackColor,

);

final bodyStyleStyleB0 = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(27),
  fontWeight: FontWeight.w800,
  color: kTextColor,
  letterSpacing: 0,
);
final bodyStyleStyleB5 = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(24),
  fontWeight: FontWeight.w800,
  color: kTextColor,
  letterSpacing: 0,
);
final bodyStyleStyleB1 = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(16),
  fontWeight: FontWeight.w600,
  color: kTextColor,
  letterSpacing: 0,
);

final bodyStyleStyleB1SemiBold = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(16),
  fontWeight: FontWeight.w700,
  color: kTextColor,
  letterSpacing:  0,
);

final bodyStyleStyleB1Bold = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(16),
  fontWeight: FontWeight.w800,
  color: kTextColor,
  letterSpacing:  0,
);

final bodyStyleStyleB2 = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(14),
  fontWeight: FontWeight.w600,
  color: kBlackColor,
  letterSpacing:0,
);

final bodyStyleStyleB25 = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(15),
  fontWeight: FontWeight.w800,
  color: kBlackColor,
  letterSpacing:0,
);

final bodyStyleStyleB2SemiBold = TextStyle(
  fontFamily:_secondaryFont,
  fontSize: getProportionateScreenFont(14),
  fontWeight: FontWeight.w700,
  color: kBlackColor,
  letterSpacing: 0,
);

final bodyStyleStyleB2Bold = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(14),
  fontWeight: FontWeight.w800,
  color: kBlackColor,
  letterSpacing:  0,
);

final bodyStyleStyleB3SemiBold = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(12),
  fontWeight: FontWeight.w700,
  height: 1.1,
  letterSpacing:  0,
  color: kBlackColor,
);

final bodyStyleStyleB3Medium = TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(12),
  fontWeight: FontWeight.w600,
  color: kBlackColor,
  letterSpacing: 0,
);

final bodyStyleStyleB3= TextStyle(
  fontFamily:_secondaryFont ,
  fontSize: getProportionateScreenFont(13),
  fontWeight: FontWeight.w500,
  color: kBlackColor,
  letterSpacing:  0,
);



