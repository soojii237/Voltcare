import 'package:flutter/cupertino.dart';

class Screen {
  static Future<dynamic> open(BuildContext context, Widget target) =>
      Navigator.push(context, CupertinoPageRoute(builder: (context) => target));
  static Future<dynamic> pushReplacement(BuildContext context, Widget target) =>
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => target));




  static close(BuildContext context, {dynamic result}) => Navigator.pop(context, result);

  static closeDialog(BuildContext context, {dynamic result}) => Navigator.of(context, rootNavigator: true).pop(result);

  static closePopupOpenPage(BuildContext context, Widget target) {
    closeDialog(context);
    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => target));
  }

  ///Current page from stack get removed and the new page is opened
  static openClosingCurrentPage(BuildContext context, Widget target) =>
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => target));

  ///All page under the stack will get removed and the new page is opened
  static openAsNewPage(BuildContext context, Widget target) =>
      Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => target), (route) => false);


  
}