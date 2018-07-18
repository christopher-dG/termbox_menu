# termbox_menu
# Copyright Chris de Graaf
# Basic TUI menus with termbox

import nimbox

type Menu* = object of RootObj
  ## A TUI menu for making a choice from a list of options.
  header*: string  ## Message which is displayed at the top of the menu.
  options*: seq[string]  ## List of options to choose from.
  position: int  ## Current cursor position.
  start: int  ## Index of the option to be shown at the top of the screen.

proc render(m: Menu, nb: Nimbox) =
  ## Renders the menu on screen.
  let header = m.header & "(" & $m.position & "/" & $(len(m.options) - 1) & ")"
  nb.clear()
  nb.print(0, 0, header, clr_default, clr_default, sty_underline)
  var s: Style
  for i, opt in m.options:
    if i < m.start: continue
    if i > m.start + nb.height(): break
    s = if i == m.position: sty_reverse else: sty_none
    nb.print(0, i - m.start + 1, m.options[i], clr_default, clr_default, s)
  nb.present()

proc inc(m: var Menu, nb: Nimbox) =
  ## Moves the cursor down.
  if m.position < len(m.options) - 1:
     inc(m.position)
  if m.position - m.start > nb.height() - 2:
    inc(m.start)

proc dec(m: var Menu) =
  ## Moves the cursor up.
  if m.position > 0:
     dec(m.position)
  if m.start > m.position:
    dec(m.start)

proc choose*(m: var Menu): int =
  ## Displays the menu and returns the choice as the option index.
  m.header = if m.header == nil: "" else: m.header & " "
  let nb = newNimbox()
  defer: nb.shutdown()
  m.render(nb)
  var e: Event
  while true:
    e = nb.poll_event()
    case e.kind
    of Key:
      case e.sym
      of Character:
        # Alt is always in the mod list, at least on my machine.
        if Ctrl in e.mods and e.ch == 'C': return -1
        elif Ctrl in e.mods and e.ch == 'P': m.dec()
        elif Ctrl in e.mods and e.ch == 'N': m.inc(nb)
      of Up: m.dec()
      of Down: m.inc(nb)
      of Enter: return m.position
      # Alt+Shift+key triggers Escape for some reason.
      # of Escape: return -1
      else: discard
    else: discard
    m.render(nb)
