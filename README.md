# That Old CRT
That dusty, old CRT ain't ready to die just yet. It wants to live on in your terminal, in your projects and even in videos.

## What it is?
It's a CRT shader. There's a lot of CRT shaders. This one is being made for use across a bunch of tools like Windows Terminal, Shadertoy and FL Studio's ZGameEditor.

The Shadertoy version lives [here](https://www.shadertoy.com/view/lXyGWm).

## Wait! Shadertoy link isn't public? What's right with you?
Right. The Shadertoy code is listed as private mainly because it's designed for easy portability to tools like ZGameEditor and Windows Terminal, so variables such as ZGEborderSize would seem strange and even inefficient to typical Shadertoy users.

## It's old as dirt, shouldn't it be free?
Yes.

## Issues
- The reflection on the frame is inaccurate. The corners noticably reflect the screen contents inaccurately. Also, if the border value is set (via borderSize), the reflection will deviate by increments based on this value as it moves toward center. This is a feature, since accurate reflections would ensure this project never sees the light of day.
- Mouse coordinates are slightly skewed in Windows Terminal based on frame/border size and curvature settings in the shader.

Please feel free to suggest fixes via pull requests.

## Credits
- Thanks to Shadertoy and shader coders for providing years of code for AI to learn from.
- Thanks to AI developers for using the amazing contributions of outstanding coders to provide powerful tools based on their extraordinary accomplishments, without which very much less would be possible.
- Thanks to Windows Terminal team for the bloom effect from retro.hlsl. It's been included with slight modifications for easy configuration.
- Thanks to [Lenzatic](https://pixabay.com/users/lenzatic-15400574/) for the ultimate [background](https://pixabay.com/photos/abandoned-explore-vacant-dark-4894406/) for a CRT shader.