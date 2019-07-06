# Boxes and Bubbles

This is a port from
[jastice/boxes-and-bubbles](https://github.com/jastice/boxes-and-bubbles) to elm
0.19. Unpublished in the package registry ATM.

A simple-as-possible 2D physics rigid-body physics engine for Elm. Supports only
bubbles (circles) and boxes (axis-aligned rectangles).

Here's [an example](http://joakin.github.io/boxes-and-bubbles/)
([source](https://github.com/joakin/boxes-and-bubbles/blob/master/examples/Example.elm))
of the engine in action. To run the example locally, start elm-reactor in the
`examples` directory.

It does this:

- resolve collisions between bodies of different mass and bounciness.
- gravity (ignores mass) / global time-varying forces (mass-dependent)

It doesn't do:

- arbitrary polygons
- friction / drag
- rotation
- time-integrated movement
- graphics
- colliding unstoppable forces with immovable objects (infinite masses will be
  glitchy)
