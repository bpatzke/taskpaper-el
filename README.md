# taskpaper.el

This is a simple emacs mode for editing [Taskpaper] files.

The URL for this project: http://github.com/bpatzke/taskpaper-el

## Features

- Open, create, and edit taskpaper files with (soon-to-be customizable)
  faces for Projects, Tasks, Notes and Tags.
- Customizable priority range. (There's no sanity checking on this... yet.)
- Focus on a single project or tag. (Currently disabled until I can work on it.)

### List of key commands:

#### Working key bindings

	`C-c C-p`     Create a new project.
	`C-c C-x C-t` Toggle @today tag on item.
	`-`           New task (on a line with only whitespace).
	`M-RET`       New task
	`M-<up>`      Increase priority.
	`M-<down>`    Decrease priority.

#### Broken or not-yet-implemented key bindings

	`C-c C-d`     Mark task as done (The function istelf doesn't work.)
	`C-c C-f`     Fold project.
	`C-c C-i`     Make sub-item (i.e. indent one level)
	`C-c TAB`     Make sub-item (i.e. indent one level)
	`C-c C-x C-p` Focus on project.

## What needs to be fixed

- When you hit return on a project line, the project line indents.
- When you create a project with the key binding (`C-c C-p`), it adds a
  blank line after the project line. It shouldn't.
- Tasks --  On a line starting with an indent: Add a space after the `-` to
  turn it into a task.
- Replace "electric-mark" with "new-task" (or something) globally.
- If a Project starts with a hyphen, it is treated as a task. I've fixed this
  so the "project" face is used, but the item still "behaves" like a task.
  `(Partially fixed in version 20150619.)`

### Finished

- Anything other than whitepace after the `:` on a project line will cause it
  to not be a project anymore. `(Fixed in version 20150619.)`
- Remove the "Create new task" key binding. It conflicts with the
  "Focus on today", and there are plenty of other ways to accomplish
  the same thing. `(Fixed in version 20150619.)`
- Change the face of Projects to be bold monospace.
  `(Fixed in version 20150619.)`
- Change the face of "done" items to be lighter -- it's unreadable on dark
  backgrounds. `(Fixed in version 20150619.)`
- You can set the priority arbitrarily high, but once you get to level 10,
  you get a second @priority tag with a new set of numbers.
  `(Fixed in version 20150625.)`

## What should be added

- Folding. `(C-c TAB (C-i))` At least Project folding, if not task folding.
- When creating a new project with `C-c C-p`, a prefix argument will prompt for
  a date stamp.
- Add a flag to control whether tasks are automatically indented after a
  project. Default = t.
- Customization:
  - Faces:
    - Projects
    - Tasks
    - Notes
    - Tags
  - Priority levels `(Added in version 20150625.)`
- Make max and min priority levels, and give them customization options.
  `(Added in version 20150625.)`
  - Min default: 1
  - Max default: 5

## TaskPaper format

This definition was taken from this [Macdrifter] article. I'll see if I can find
a more "official" definition.

Unfortunately, almost all of the definitions below confilct with eachother.
That means I'll need to impose some sort of precedence system.

To make things simple, I'll ignore tags when deciding whether something should
be a Project or a Task, as that's probably what the original designers intended.
Tags are useful decorations, not defining structures.

Fortunately, that makes the hierarchy simple. I'll just use

	Projects > Tasks

This may seem obvious, but if I define it, then there's no ambiguity. I hate
abmiguity.

### Projects

A project is a line that ends with a colon (:).

Keeping with a strict application of this definition, then any `@` tags applied
to a project should go **before** the colon.

However, it doesn't really make sense to force users to ensure that tags come
before the colon (:). Therefore, this mode will accept tags after the colon (:).

This make the full definition:

	A project is a line that ends with a colon (:), optionally followed by one
	or more tags.

### Tasks

A task is a line that begins with a hyphen and a space.

For tasks to be part of a Project, they **MUST** be indented. If they are flush-left,
they will be independent tasks without a project. How lonely.

### Tags

Tags begin with the `@` character, and appear at the end of Projects or Tasks.

### Notes

Anything that isn't a Project, Task or Tag is a note. Essentially, it's plain
text that doesn't start with a hyphen or end in a colon.

## Ideas and notes

Check pre-defined faces to see if I should use them.

## Authors

This was originally written in 2008 by [Kentaro Kuribayashi].

Modified in 2010 by [Jonas Oberschweiber].

Modified in 2010 by [Ted Roden].

Updated in 2015 by me ([Bryan Patzke]).

[Taskpaper]: http://www.hogbaysoftware.com/products/taskpaper/
[Macdrifter]: http://www.macdrifter.com/2014/01/deconstructing-my-omnifocus-dependency.html
[Kentaro Kuribayashi]: http://coderepos.org/share/browser/lang/elisp/taskpaper/trunk/taskpaper.el
[Jonas Oberschweiber]: http://github.com/jonasoberschweiber/taskpaper-el
[Ted Roden]: https://github.com/tedroden/taskpaper-el
[Bryan Patzke]: https://github.com/bpatzke/taskpaper-el
