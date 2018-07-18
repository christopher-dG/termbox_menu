# termbox_menu
# Copyright Chris de Graaf
# Basic TUI menus with termbox

import nimbox

type Menu* = object of RootObj
  header*: string
  options*: seq[string]
  position: int
  start: int


proc render(m: Menu, nb: Nimbox) =
  let label = m.header & " (" & $m.position & "/" & $(len(m.options) - 1) & ")"

  nb.clear()
  nb.print(0, 0, label, clr_default, clr_default, sty_underline)

  var s: Style
  for i, opt in m.options:
    if i < m.start: continue
    if i > m.start + nb.height(): break

    if i == m.position: s = sty_reverse
    else: s = sty_none
    nb.print(0, i - m.start + 1, m.options[i], clr_default, clr_default, s)

  nb.present()


proc inc(m: var Menu, nb: Nimbox) =
  if m.position < len(m.options) - 1:
     inc(m.position)
  if m.position - m.start > nb.height() - 2:
    inc(m.start)


proc dec(m: var Menu) =
  if m.position > 0:
     dec(m.position)
  if m.start > m.position:
    dec(m.start)


proc choose*(m: var Menu): int =
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
        elif Ctrl in e.mods and e.ch == 'P': dec(m)
        elif Ctrl in e.mods and e.ch == 'N': inc(m, nb)
      of Up: dec(m)
      of Down: inc(m, nb)
      of Enter: return m.position
      # Alt+Shift+key triggers Escape for some reason.
      # of Escape: return -1
      else: discard
    else: discard

    m.render(nb)
