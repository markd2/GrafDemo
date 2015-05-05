GrafDemo
========

A little demo program showing off various Core Graphics features.  It's a sample program
for a set of posts over at the Big Nerd Ranch blog.

Behold the main menu it all of its glory:

![](assets/main-menu.png)

In general, the left-hand view is implemented in Objective-C, the
right-hand view is implemented in Swift, and the window controllers
alternate ObjC and Swift implementations.


Simple
------

**Simple** is a view that shows basic drawing, as well as GState hygiene.  The "Sloppy"
toggle turns off some GState management, showing attribute settings leak out in other
method's drawing.

![](assets/simple-window.png)


Lines
-----
Behold all things related to lines.  End caps, line joins, drawing mechanisms, and
line phases.

![](assets/lines-window.png)

