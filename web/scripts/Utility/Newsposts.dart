import "package:CommonLib/listThingy.dart";
import 'dart:html';

abstract class Newsposts {
   static  void drawNewposts(Element container) {
       List<Thingy> tmp = new List<Thingy>()
           ..add(new Newspost("7/8/2018","Been working on gettings trees rendering right before now, but I'm ready for shit to get real."));
   }
}