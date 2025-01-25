#let dot_radius = 0.4em
#let dot_stroke = 0.1em
#let dot_spacing = 0.3em
#let half_spacing = 0.4em
#let tab_spacing = 0.7em
#let tuning = "d"

#let draw_tab(tab) = {
  assert(type(tab) == str, message: "Expected string, got " + type(tab))
  assert(tab.len() == 6, message: "Expected 6 items, got " + str(tab.len()))
  stack(
    dir: ttb, spacing: dot_stroke + dot_spacing, ..for i in range(0, tab.len()) {
      let item = tab.at(i)
      let fill = if item == "x" { black } else if item == "o" { none } else if item == "c" { gradient.linear(black, white).sharp(2) } else { panic("Unexpected symbol in tab description: " + str(item)) }
      (circle(radius: dot_radius, fill: fill, stroke: dot_stroke + black),)
      if i == 2 {
        (v(dot_stroke + dot_spacing + half_spacing),)
      }
    },
  )
}
#let silence = stack(
  dir: ttb, spacing: dot_stroke + dot_spacing, ..for i in range(0, 6) {
    (
      box(
        width: dot_radius, circle(radius: dot_radius, stroke: dot_stroke + black, inset: 0pt)[
          #place(left, line(length: dot_radius, end: (100%, 100%)))
          #place(bottom, line(length: dot_radius, end: (100%, -100%)))
        ],
      ),
    )
    if i == 2 {
      (v(dot_stroke + dot_spacing + half_spacing),)
    }
  },
)

#let tabs_d = (
  "x": silence, "d": draw_tab("xxxxxx"), "d#": draw_tab("xxxxxc"), "e": draw_tab("xxxxxo"), "f": draw_tab("xxxxco"), "f#": draw_tab("xxxxoo"), "g": draw_tab("xxxooo"), "g#": draw_tab("xxcooo"), "a": draw_tab("xxoooo"), "a#": draw_tab("xoxooo"), "b": draw_tab("xooooo"), "c": draw_tab("oxxooo"), "c#": draw_tab("oooooo"), "D+": draw_tab("oxxxxx"), "D#+": draw_tab("xxxxxc"), "E+": draw_tab("xxxxxo"), "F+": draw_tab("xxxxco"), "F#+": draw_tab("xxxxoo"), "G+": draw_tab("xxxooo"), "G#+": draw_tab("xxoxxo"), "A+": draw_tab("xxoooo"), "A#+": draw_tab("xoxooo"), "B+": draw_tab("xooooo"), "C+": draw_tab("cooooo"), "C#+": draw_tab("oooooo"), "D++": draw_tab("oxxxxx"), "E++": draw_tab("xxxxxo"), "F#++": draw_tab("xxxxox"), "G++": draw_tab("xxxoox"),
)

#let tabs = tabs_d;

#let note_duration = ("0": " ", "1": "𝅝", "2": "𝅗𝅥", "4": "𝅘𝅥", "8": "𝅘𝅥𝅮")

#let show_note(note, show_notes: true, show_pitch: true) = {
  assert(type(note) == str, message: "Expected string, got " + type(note))
  let parts = note.match(regex("^(\d*)([a-zA-Z]\#?\+*)$"))
  assert(parts != none, message: "Invalid tab format, found for " + note)
  let parts = parts.captures
  let duration = if (parts.at(0) == "") { "0" } else { parts.at(0) }
  let pitch = parts.at(1)
  let octave = none

  if "+" in note {
    pitch = upper(pitch)
  } else {
    pitch = lower(pitch)
  }
  assert(
    duration in note_duration, message: "Invalid note duration for " + note,
  )
  assert(pitch in tabs, message: "Invalid tab pitch " + note)

  let pitch_note = pitch.trim("+")
  let pitch_octave = pitch.trim(regex("[^+]"))

  block(
    width: (dot_radius) * 2 + dot_stroke + tab_spacing, align(
      center, stack(
        text(size: 2em, if show_notes { note_duration.at(duration) }), v(8pt), tabs.at(pitch), pitch_octave, if show_pitch { pitch_note },
      ),
    ),
  )
}

#let show_tabs(tabs, show_notes: true, show_pitch: true) = {
  assert(type(tabs) == str, message: "Expected string, got " + type(tabs))
  let tab_groups = tabs.trim(regex("\s")).split(regex("\s{2,}"))
  let notes = tabs.trim(regex("\s")).split(regex("\s+"))

  block(for (i, tab_group) in tab_groups.enumerate() {
    let notes = tab_group.split(regex("\s+"))

    box(stack(dir: ltr, ..for note in notes {
      (show_note(note, show_notes: show_notes, show_pitch: show_pitch),)
    }))
    h(2 * dot_radius + dot_stroke + tab_spacing, weak: true)
  })
}

#let song(name, author: none, rythm: none, bpm: none) = {
  block(
    sticky: true,
  )[
    #block(width: 100%)[
      #align(left, circle(text(size: 1.5em, strong(upper(tuning)))))
      #place(center + horizon, text(size: 1.5em, heading(name, depth: 1)))
    ]

    #if not(author == none and rythm == none and bpm == none) {
      grid(
        align: horizon, columns: (2em, 1fr, auto), if rythm != none {
          text(size: 1.5em, strong(stack(str(rythm.at(0)), str(rythm.at(1)))))
        }, if bpm != none and rythm != none {
          let bpm_unit = ("2": "𝅗𝅥", "4": "𝅘𝅥", "8": "𝅘𝅥.")
          text(size: 1.5em, bpm_unit.at(str(rythm.at(1)))) + " = " + str(bpm) + " bpm"
        }, if author != none {
          author
        },
      )
    }
  ]
}

