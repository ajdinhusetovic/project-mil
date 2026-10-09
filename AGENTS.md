# UI authoring

Create and change game UI through Roblox Studio's Command Bar in Edit mode.
Save screens, buttons, cards, and feedback templates in StarterGui so the user
can edit them in Explorer. Runtime controllers must wait for the authored UI;
do not create fallback screens, duplicate StarterGui manually, or apply builder
styles during Play. Runtime code may update state, bind input, animate, resize,
and clone authored templates for changing inventory and temporary effects.
