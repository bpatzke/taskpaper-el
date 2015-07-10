# taskpaper.el

This is a simple emacs mode for editing [Taskpaper] files.

The URL for this project: http://github.com/bpatzke/taskpaper-el

## Features

- Open, create, and edit taskpaper files with (soon-to-be customizable) faces for
  Projects, Tasks, Notes and Tags.
- Customization:
  - Priority levels
  - Max and min priority levels
	- Min default: 1
	- Max default: 5
- Focus on a single project or tag. (Currently disabled until I can work on it.)

### Key bindings:

	`C-c C-p`     Create a new project. Prompt for due date with prefix argument.
	`-`           New task (as the first non-whitespace character on a line, or
		          on a line with only whitespace).
	`TAB`         Indent one level. Unindent with prefix argument. [1][]
	`C-c C-d`     Mark item as done.
	`C-c C-f`     Fold project. Prefix arg -> fold all projects. [1][]
	`C-c C-x C-t` Toggle @today tag on item.
	`M-RET`       New task on the next line
	`M-<up>`      Increase priority. [2][]
	`M-<down>`    Decrease priority. [2][]
	`C-c C-x C-p` Focus on project. [1][]

### Expected behavior:
- **When you type a hyphen** (`-`)
  - On any blank line regardless of leading/trailing whitespace, or as the
	first non-whitespace character on a line that has other non-whitespace
	characters.
	- Create a new task.
	  - If the previous line is a Project, indent one level more than the
		Project.
	  - If the previous line is a Task or Note, indent to the same level as
		the previous Task line.
	  - If the item is already a task, do nothing.
	  - If the item is a project, do nothing.
	- Otherwise, just output the hyphen (`-`).
- **New Project** command (`C-c C-p`)
  - On a blank line, or a line with only whitespace, prompt for Project title
	and create new Project.
  - If the item is already a Project, do nothing.
  - If the item is a Task, convert it to a Project. (i.e. remove hyphen `-`
	and append `:`)
  - If the item is a Note, convert it to a Project. (i.e. append `:`)
- Indentation behavior:
  - `M-RET` -> new task on the next line
	- If the current line is a Project, indent the new task to the next level.
	- If the current line is a Task, indent the new task to the same level as
	  the current line.
	- If the current line is a Note, indent to the same level as the previous
	  task.
  - `TAB`
	- TBD

## To Do

- Make it stop indenting projects when I hit return at the end of the line.
- Replace **electric-mark** with **new-task** (or something) globally.
- Fix and/or verify that the "Expected behavior" behaves as expected.
- If a Project starts with a hyphen, it is treated as a task.
  - I've fixed this so that the "project" face is used, but the item still
	**behaves** like a task.
	*Related:* Make a `taskpaper-project-p` function?
- Add Project folding.
- Add a flag to control whether tasks are automatically indented after a project.
  Default = t. (maybe)
- Add bounds checking on priority levels
	- Min >= 0
	- Max <= 100(?)
- Add Customization:
  - Faces:
    - Projects
    - Tasks
    - Notes
    - Tags
  - Indentation (Default=2 spaces)

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

[1]: Still on the todo list.

[2]: Disabled temporarily while I sort out other things.
