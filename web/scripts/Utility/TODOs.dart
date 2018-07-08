import 'package:CommonLib/listThingy.dart';
import 'dart:html';

abstract class TODOs {
    static  void drawTodos(Element container) {
        List<Thingy> tmp = new List<Thingy>()
            ..add(new Thingy("Get a sufficiently big canvas to draw trees onto."))
            ..add(new Thingy("Draw one random tree."))
            ..add(new Thingy("Make that random tree small, with no leaves."))
            ..add(new Thingy("Every five minutes the random tree doubles in size, till its full size or more (cap at full size)."))
            ..add(new Thingy("Tree grows if you are on screen, or when you come back it will calc how big it should be."))
            ..add(new Thingy("One full size, after five minutes grow flowers."))
            ..add(new Thingy("After five minutes, tree glows, on click grow fruit. (means you can't skip seeing flower stage)"))
            ..add(new Thingy("After five minute, fruit gets tied to a physics object and drops."))
            ..add(new Thingy("Clicking on fruit adds it to your inventory."))
            ..add(new Thingy("In inventory can sell, or select fruit. Selling fruit gives you money."))
            ..add(new Thingy("Fruit grown contains datastring for bred tree. "))
            ..add(new Thingy("On creation, tree knows what flower it will have and what fruit (fruit can be random)"))
            ..add(new Thingy("Make dollLib tree breeding account for fruit/flowers/leaves. "))
            ..add(new Thingy("Clicking on canvas with fruit selected drops it, when it touches ground, it grows new tree."))
            ..add(new Thingy("Roots."))
            ..add(new Thingy("Essence."))
            ..add(new Thingy("Nidhogg."))
            ..add(new Thingy("Page where you can convert tree bux to Caegers (but iff patient empress). Maybe in wigglersim itself."))
            ..add(new Thingy("Page where you can send special fruits (essence/grubs) into wigglersim."))
            ..add(new Thingy("navbar"))
            ..add(new Thingy("css"))


        ;

        ListThingy list = new ListThingy("TODO List for JR",tmp);
        list.renderSelf(container);
    }
}