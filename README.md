# taskpaper.el

This is a simple emacs mode for editing [Taskpaper] files.

The URL for this project: http://github.com/bpatzke/taskpaper-el

## How things work now

- Open, create, and edit taskpaper files.
- Increase/decrease priority with a keystroke.
- Focus on a single project or tag.
- List of key commands:

	`C-c C-p` Create a new project.
	`C-c C-t` Create a new task. (Doesn't work -- conflict with "Focus on today".
	           Remove -- it's not needed anyway.)
	`C-c C-d` Mark task as done (Doesn't work -- just deletes the character under point.)
	`-`        Hyphen
                   On a blank line: Adds indent and `-` to make a task.
				   On a line starting with an indent: Nothing.
				   At the beginning of a "Project" line: Turns the project into a task.
	`M-RET`    Newline and hyphen. (works)
	`M-<up>`   Increase priority.
	`M-<down>` Decrease priority.
	`C-c C-f` Focus on the current project.
	`C-c C-t` Focus on today.

## What needs to be fixed

- When you hit return on a project line, the project line indents.
- When you create a project with the key binding (`C-c C-p`), it adds a blank line after
  the project line. It shouldn't.
- Tasks --  On a line starting with an indent: Add a space after the `-` to turn it into a task.
- For all function names with "electric-mark", change it to "new-task".
- If a Project starts with a hyphen, it is treated as a task. `(Partially fixed in version 20150619.)`
- You can set the priority arbitrarily high, but once you get to level 10, you get
  a second @priority tag with a new set of numbers.
- Anything other than whitepace after the `:` on a project line with cause it
  to not be a project anymore. `(Fixed in version 20150619.)`
- Remove the "Create new task" key binding. It conflicts with the "Focus on today",
  and there are plenty of other ways to accomplish the same thing. `(Fixed in version 20150619.)`
- Change the face of Projects to be bold monospace. `(Fixed in version 20150619.)`
- Change the face of "done" items to be lighter -- it's unreadable on dark backgrounds. `(Fixed in version 20150619.)`

## What should be added

- Folding.
- When creating a new project with C-c C-p, a prefix argument will prompt for a date stamp.
- Add a flag to control whether tasks are automatically indented after a project. Default = t.
- Add the ability to set colors for tags.

### New key bindings

	`C-c C-p`     Create a new project.
	`C-c C-d`     Mark task as done (Doesn't work -- just deletes the character under point.)
	`-`           New task (on a line with only whitespace).
	`M-RET`       New task
	`M-<up>`      Increase priority.
	`M-<down>`    Decrease priority.
	`C-c C-f`     Fold project.
	`C-c C-x C-p` Focus on project.
	`C-c C-x C-t` Focus on today.

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

### Tasks

A task is a line that begins with a hyphen and a space.

For tasks to be part of a Project, they **MUST** be indented. If they are flush-left,
they will be independent tasks without a project. How lonely.

### Tags

Tags begin with the `@` character, and appear at the end of Projects or Tasks.

### Notes

Anything that isn't a Project, Task or Tag is a note. Essentially, it's plain
text that doesn't start with a hyphen or end in a colon.

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
