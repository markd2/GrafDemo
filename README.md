GrafDemo
========

A little demo program showing off various Core Graphics features.  It's a sample program
for a set of posts over at the Big Nerd Ranch blog:

* [In the Beginning](https://www.bignerdranch.com/blog/core-graphics-part-1-in-the-beginning/)
* [Contextually Speaking](https://www.bignerdranch.com/blog/core-graphics-part-2-contextually-speaking/)
* [Lines](https://www.bignerdranch.com/blog/core-graphics-part-three-lines/)
* Paths (forthcoming)

Here are some other, possibly interesting, CG-related blog posts:

* [Rectangles, Part 1](https://www.bignerdranch.com/blog/rectangles-part-1/) - an 
  introduction to CGRect and basic manipulations.
* [Rectangles, Part 2](https://www.bignerdranch.com/blog/rectangles-part-2/) - more
  CGRect and more fun API (union, intersection, insets, dividing)


Digital Dashboard
-----------------

Behold the main menu it all of its glory:

![](assets/main-menu.png)

For the demo windows, the left-hand view is implemented in Objective-C, the
right-hand view is implemented in Swift, and the window controllers
alternate ObjC and Swift implementations.


Simple
------

**Simple** is a view that shows basic drawing, as well as [GState hygiene](https://www.bignerdranch.com/blog/core-graphics-part-2-contextually-speaking/).  The "Sloppy"
toggle turns off some GState management, showing attribute settings leak out in other
method's drawing.

![](assets/simple-window.png)


Lines
-----
Here are things related to lines.  End caps, line joins, drawing mechanisms, and
line phases.

![](assets/lines-window.png)


Paths
-----
A sampler of the different path component calls.  Click and drag the control points to
see how they behave.

![](assets/paths-window.png)


Arcs
----
The plethora of "arc" calls are confusing.  Here they are with influence lines
and tweakable settings.

![](assets/arcs-window.png)


Transforms
----------
Transformations are a-fine thing.

![](assets/transforms-window.png)



PostScript
----------
A bit of history - Core Graphics is based on the PostScript drawing model.  CG also
includes a full postscript interpreter. This window lets you enter code and run it.
Worst IDE Evar.

![](assets/postscript-window.png)


Interesting Docs
----------------

* [Quartz 2D Programming Guide (Apple docs)](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/Introduction/Introduction.html)
* [Programming  with Quartz: 2D and PDF Graphics in Mac OS X (book)](http://www.amazon.com/Programming-Quartz-Graphics-Kaufmann-Computer/dp/0123694736/)