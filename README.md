# termbox_menu

**Basic TUI menus with termbox.**

## Installation

Before using this library, you need to have [`termbox`](https://github.com/nsf/termbox) installed.
Once that's done, clone and install (it's not yet available on Nimble):

```sh
git clone https://github.com/christopher-dG/termbox_menu
cd termbox_menu
nimble install
```

## Usage

```nim
import termbox_menu

var menu = Menu(header: "Test Menu", options: @["Option 1", "Second option", "Number 3"])
let choice = menu.choose()

# choice is an int, it's the index of the chosen option.
```
