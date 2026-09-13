# CLAUDE.md

Working agreement for Claude Code in this repository. Read [README.MD](README.MD) first for
what the project is trying to find; this file is how to work on it.

## The constraint that shapes everything

You cannot tell whether a game is fun. Only a human playing it can. So the job is never
"finish the game" — it is **get something playable in front of the user as fast as possible,
then stop and hand over.** Ship the spike, state the one command that runs it, and let them
judge. Never write a verdict into a concept card; that is the user's line to write.

Corollary: time spent on menus, settings screens, difficulty curves, save systems or polish
before a verdict is time spent on a concept that will probably be folded.

## Concept layout

Every idea lives in `concepts/NNN-kebab-slug/` and must run on its own:

```
concepts/003-note-runner/
  README.md      concept card — pitch, controls, run command, verdict log (required)
  spike/         stage 1 throwaway demo
  game/          stage 3 Godot project (project.godot lives here) — only after a Keep
  assets/        art and audio + CREDITS.md
```

- Three-digit prefix, kebab-case slug. Never renumber, never reuse a number; gaps are fine.
- **No imports across concept folders.** Copy code between concepts instead of extracting a
  shared library. Concepts must stay cheap to delete and cheap to fork.
- Start from `concepts/_template/`. Fill in the card *before* writing code — if the fun
  hypothesis cannot be written in two sentences, the concept is not ready to build.
- Add a row to the concept log table in [README.MD](README.MD) when you create a concept.

## Stage 1 — the spike

Default to a **browser + Web MIDI** spike: one `index.html`, inline CSS and JS, no build
step, no framework, no `package.json`. It is the shortest path from idea to hands-on, and
Web MIDI handles MIDI input better than Godot does. Dealer's choice, though — if a concept is
clearly a 3D idea, going straight to Godot is fine. Never add a build toolchain to a spike.

Run it with a static server; `file://` breaks Web MIDI:

```powershell
python -m http.server 8000 --directory concepts/NNN-slug/spike
```

A spike is done when:

- One documented command starts it, and the concept card carries that command and the controls.
- It is playable for 60 seconds — win, lose, or score, something that closes the loop.
- **It works with no MIDI device connected**, via a computer-keyboard fallback. Non-negotiable:
  without it neither you nor a reviewer without hardware can confirm it even runs. Show which
  input is live on screen.
- Nothing is in it that does not test the hypothesis.

### Web MIDI essentials

```js
// Secure context required: http://localhost works, file:// does not.
navigator.requestMIDIAccess().then(midi => {
  for (const input of midi.inputs.values()) input.onmidimessage = onMidi;
  // devices plugged in after load:
  midi.onstatechange = e => {
    if (e.port.type === 'input' && e.port.state === 'connected') e.port.onmidimessage = onMidi;
  };
}).catch(() => useKeyboardFallback());   // no device, no permission, wrong browser

function onMidi({ data, timeStamp }) {
  const [status, note, velocity] = data;   // note 60 === middle C
  const type = status & 0xf0;              // low nibble is the channel
  if (type === 0x90 && velocity > 0) noteOn(note, velocity, timeStamp);
  else if (type === 0x80 || type === 0x90) noteOff(note, timeStamp);  // 0x90 vel 0 IS note-off
}
```

- Note-on with velocity 0 means note-off. Most keyboards send it that way. Miss this and
  notes stick on forever.
- Use `event.timeStamp` for input timing, not the render loop — it is far more accurate.
- `AudioContext` must be created or resumed inside a user gesture, or there is no sound.
- Schedule audio against `audioCtx.currentTime`, never `setTimeout`.
- Chrome and Edge only in practice. Say so in the concept card.

## Stage 3 — the Godot build

Only after a Keep verdict. Godot 4.7 at `C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe`.

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path concepts/NNN-slug/game
```

### Godot MIDI essentials

```gdscript
func _ready() -> void:
    OS.open_midi_inputs()   # REQUIRED — without it no InputEventMIDI ever arrives

func _input(event: InputEvent) -> void:
    if not event is InputEventMIDI:
        return
    var midi := event as InputEventMIDI
    if midi.message == MIDI_MESSAGE_NOTE_ON and midi.velocity > 0:
        _note_on(midi.pitch, midi.velocity)    # pitch 60 == middle C
    elif midi.message == MIDI_MESSAGE_NOTE_OFF or midi.message == MIDI_MESSAGE_NOTE_ON:
        _note_off(midi.pitch)                  # note-on with velocity 0 IS a note-off
```

- Forgetting `OS.open_midi_inputs()` is the most common failure here: input silently never
  arrives and nothing errors. `OS.get_connected_midi_inputs()` confirms the device is seen.
- **Godot's Web export has no MIDI input.** Godot concepts are desktop-run. If a concept must
  be shareable in a browser, keep it as a web spike.
- For rhythm timing use the audio clock (`AudioServer.get_time_since_last_mix()` and
  `AudioServer.get_output_latency()`), not accumulated `delta` — frame time drifts against
  the music.
- Keep `project.godot` at `concepts/NNN-slug/game/` so the project opens standalone.

## Assets — search first, generate last

The user's standing preference: **use human-made assets.** Search the CC0 packs before making
anything. Generated 3D and AI art is the fallback for when a search genuinely comes up empty,
not the starting point.

- 3D via the Blender MCP: `search_polyhaven_assets` / `download_polyhaven_asset` (CC0
  textures, HDRIs, models), `search_polypizza_models` / `download_polypizza_model` (CC0/CC-BY
  low-poly), `search_sketchfab_models` / `download_sketchfab_model` (**mixed licences — read
  the licence before downloading**). If a search fails, check `get_polyhaven_status` /
  `get_polypizza_status` / `get_sketchfab_status`; these sources are toggled per session.
- 2D sprites, tiles, UI and sound effects: [Kenney](https://kenney.nl/assets) (CC0) first,
  then OpenGameArt or itch.io packs. Fetch these yourself — no MCP covers them.
- `generate_hyper3d_model_via_text` and `generate_hunyuan3d_model` exist. Treat them as a last
  resort, and say you are using them rather than quietly generating.
- Every download gets a line in `concepts/NNN-slug/assets/CREDITS.md`: file, source URL,
  author, licence. Write it at download time. CC-BY assets are unusable without attribution.
- Coloured rectangles remain the right call for a spike, unless the look *is* the hypothesis.

## MCP servers

Both are configured in [.mcp.json](.mcp.json).

**Blender** — requires Blender to be open with the BlenderMCP addon started and connected.
If tools fail to connect, that is why; ask the user to start it rather than retrying.
`execute_blender_code` runs arbitrary Python against their live session, so check
`get_scene_info` first and tell them to save before anything destructive. Export finished
assets as `.glb` into the concept's `assets/`, and commit the `.blend` source alongside.

**Godot** — `run_project` plus `get_debug_output` is the useful loop: launch, read stdout and
errors, fix, relaunch. Always `stop_project` when finished; leaving instances running blocks
the next launch. `create_scene` and `add_node` only cover simple cases — write `.tscn` and
`.gd` files directly for anything real, and use the MCP to run and observe.

The claude.ai connectors listed in this environment (Asana, Figma, Jira, Sentry…) are not
authorised and are irrelevant here. Do not attempt them.

## Anti-slop boundary

Throwaway, AI-written, barely-structured code is *correct* in `spike/` — the spike exists to
be deleted. In `game/` it is not: that code is written deliberately, reviewed, and kept small.
When promoting a concept, rewrite it rather than porting the spike's shortcuts across.

## Housekeeping

- Commits: `concept(003): add falling-notes spike`, `concept(003): verdict — fold`, or
  `docs:` / `chore:` outside a concept. One concept per commit.
- Commit `.blend` sources and exported `.glb`; `.godot/`, `node_modules/` and `*.blend1` are
  ignored.
- Do not commit anything under a concept that the concept's own README does not explain how
  to run.
