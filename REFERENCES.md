# Planar - Script References (Chetanya Section)

This document lists programming references used while building gameplay scripts for the Planar project.

## Official Documentation

1. Godot Engine Documentation (4.x)  
   https://docs.godotengine.org/en/stable/  
   Used for engine APIs, node lifecycle, physics, signals, input handling, and scene architecture.

2. GDScript Reference  
   https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html
   Used for typed GDScript syntax, arrays/dictionaries, signals, and callable/tween usage.

3. CharacterBody2D Class Reference  
   https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html  
   Used for player movement logic (`velocity`, `move_and_slide`, floor checks).

4. Input and InputMap Documentation  
   https://docs.godotengine.org/en/stable/classes/class_input.html  
   https://docs.godotengine.org/en/stable/classes/class_inputmap.html  
   Used for action mapping and keyboard input handling.

5. Area2D and CollisionShape2D Class References  
   https://docs.godotengine.org/en/stable/classes/class_area2d.html  
   https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html  
   Used for interactables, fail zones, pressure pads, and overlap detection.

6. Timer and Signal Usage  
   https://docs.godotengine.org/en/stable/classes/class_timer.html  
   https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html  
   Used for timed gates, cooldown logic, and gameplay event flow.

7. UI Nodes (Control / PanelContainer / Label / LineEdit / Button)  
   https://docs.godotengine.org/en/stable/classes/class_control.html  
   Used for puzzle modal UI and HUD interaction flow.

## Learning Videos (Code Workflow)

1. Godotneers (YouTube) - Godot 4 gameplay scripting tutorials  
   https://www.youtube.com/@Godotneers  
   Used as general reference for gameplay scripting patterns and scene organization.

2. GDQuest (YouTube) - Godot architecture and scripting practices  
   https://www.youtube.com/@Gdquest  
   Used for script structuring ideas and reusable node/component patterns.

3. Brackeys (YouTube) - Godot beginner-to-intermediate workflows  
   https://www.youtube.com/@Brackeys  
   Used for practical examples of movement, interaction loops, and game flow structure.

4. Godot official YouTube channel  
   https://www.youtube.com/@GodotEngineOfficial  
   Used for official engine feature walkthroughs and editor workflow examples.

## Development Tools

1. Godot Editor (4.6)  
   Used to write and test all GDScript files in `scripts/`.

2. Visual Studio Code  
   Used for script editing and project-wide search/navigation.

## Notes

- These references supported implementation and debugging of gameplay code patterns.
- Core game logic, level logic, and integration details were written and adapted for this project context.
