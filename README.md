# That Old CRT
That dusty, old CRT ain't ready to die just yet. It wants to live on in your terminal, in your projects and even in videos.

## What it is?
It's a CRT shader. There's a lot of CRT shaders. This one is being made for use across a bunch of tools like Windows Terminal, Shadertoy and FL Studio's ZGameEditor.

The Shadertoy version lives [here](https://www.shadertoy.com/view/lXyGWm).

## It's old as dirt, shouldn't it be free?
Yes.

## Issues
- The reflection on the frame is inaccurate. If the border value is set (via borderSize), the reflection will deviate by increments based on this value as it moves toward center. The corners also inaccurately reflect the screen contents.

Please feel free to provide solutions via pull requests.

## Credits
- Thanks to Shadertoy and shader coders for providing years of code for AI to learn from.
- Thanks to Windows Terminal team for the bloom effect from retro.hlsl. It's been included with slight modifications for easy configuration.