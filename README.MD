# MIDI Game Concepts

One repository, many small games, all played with a MIDI keyboard.

## What this is for

**The goal** is to find a game that is genuinely fun to play with a MIDI keyboard or
controller — one that trains hand-to-eye coordination with the device. The long-term
ambition is a game that teaches someone to read sheet music and play it on a keyboard.
That is the destination, not the next step.

**How we get there.** Ideas are cheap and fun is unpredictable, so we prototype a lot
and judge fast. Every idea gets its own folder, a rough playable demo, and a recorded
verdict. Expect a pile of throwaway AI-generated prototypes — that is exactly what the
spike stage is for. The final product does not get built that way: once an idea proves
fun, it gets built deliberately. Slop to find the fun, craft to ship it.

## Prerequisites

| Tool | Needed for | Notes |
| --- | --- | --- |
| Chrome or Edge | browser spikes | Web MIDI is Chrome/Edge only in practice. Firefox is gated/partial, Safari has none. |
| Python 3 *or* Node | serving a spike | Any static file server works. |
| [Godot 4.7](https://godotengine.org/) | `game/` builds | Installed here at `C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe`. |
| [Blender](https://www.blender.org/) | adapting 3D assets | Only once a concept reaches the build stage. |
| A MIDI device | playing properly | Optional — every spike must also work without one. |

## Quickstart — play a concept

```powershell
# 1. serve the spike (Web MIDI refuses to run from file://, it needs localhost)
python -m http.server 8000 --directory concepts/001-example/spike

# 2. open http://localhost:8000 in Chrome or Edge, allow MIDI access when asked
```

Each concept's own `README.md` gives the exact command and the controls. If a concept has
reached the build stage, run it natively instead — Godot's Web export has no MIDI input:

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path concepts/001-example/game
```

## Repository layout

```
concepts/
  _template/            copy this to start a new concept
  001-some-idea/
    README.md           the concept card — pitch, controls, run command, verdict
    spike/              stage 1: the throwaway demo that answers "is this fun?"
    game/               stage 3: the real Godot project (only after a Keep verdict)
    assets/             sprites, tiles, models — plus CREDITS.md for their licences
CLAUDE.md               working agreement for Claude Code and other agents
```

One idea per folder. A concept folder runs on its own and can be deleted on its own.

## The concept lifecycle

| Stage | What happens | Done when |
| --- | --- | --- |
| **1. Card** | Write the pitch: the fun hypothesis, the MIDI verb, the likeliest way it flops. | `README.md` exists in the concept folder. |
| **2. Spike** | Build the smallest playable thing that tests the hypothesis. Dealer's choice of tech — browser and Web MIDI is the default because it is the fastest path to hands-on. | Someone can play it for 60 seconds from one command. |
| **3. Verdict** | A human plays it and writes **Keep / Fold / Fork** into the card, with one line of why. | The verdict is in the card. |
| **4. Build** | Only for a Keep. Godot project, Blender assets, written with care. | It is a game, not a demo. |

Most concepts should end at Fold. That is a working repository, not a failing one — the
verdict is the output.

## Adding a concept

1. `cp -r concepts/_template concepts/00N-your-idea` (three digits, kebab-case, never reused).
2. Fill in the card. The fun hypothesis goes first, before any code.
3. Build the spike. Placeholder graphics, no menus, no settings, no polish.
4. Play it. Write the verdict. Add a row to the log below.

## Assets: find them, don't generate them

Prefer real assets made by real artists — tiles, sprites, models, sounds. They look better
than anything generated on the spot, they are consistent with each other, and packs come
with the variants a game actually needs. Generated art is the fallback for when nothing
suitable exists, not the default.

| Looking for | Go to | Licence |
| --- | --- | --- |
| 2D sprites, tiles, UI, audio | [Kenney](https://kenney.nl/assets) | CC0 |
| Low-poly 3D models | [Poly Pizza](https://poly.pizza), [Quaternius](https://quaternius.com) | CC0 / CC-BY |
| Textures, HDRIs, scanned models | [Poly Haven](https://polyhaven.com) | CC0 |
| Anything else 3D | [Sketchfab](https://sketchfab.com) | **mixed — check every model** |
| Mixed 2D art | [OpenGameArt](https://opengameart.org), itch.io asset packs | **mixed — check** |
| Icons | [game-icons.net](https://game-icons.net) | CC-BY |

Poly Haven, Poly Pizza and Sketchfab are searchable and downloadable directly through the
Blender MCP server, so an agent can pull a model into the scene without leaving the editor.

Two standing rules:

- **Prefer CC0.** It removes every future question about shipping, forking or rewriting.
- **Record what you used.** Every `assets/` folder gets a `CREDITS.md` listing source URL,
  author and licence per file. Do it at download time; reconstructing it later is miserable,
  and CC-BY assets are unusable without it.

Placeholder coloured rectangles are perfectly fine in a spike. Grab real art when the
concept survives its verdict — or earlier, if the look *is* the hypothesis being tested.

## Rules that keep this repo usable

- **Self-contained folders.** No imports across concepts. Copy code instead of sharing it —
  a shared library makes deleting a dead concept scary, and dead concepts must stay cheap to delete.
- **Every spike works without a MIDI device.** Map computer keys as a fallback. Otherwise
  nobody without hardware in front of them — including Claude — can check that it even runs.
- **Verdicts are written by humans.** Nobody and nothing else can judge whether a thing is fun.
- **Never renumber a concept.** Numbers are identity; gaps are fine.
- **Downloaded art beats generated art.** Search the CC0 packs first; generate only when the
  search genuinely comes up empty.
- **Slop belongs in `spike/`, never in `game/`.**

## Concept log

| # | Concept | Stage | Verdict |
| --- | --- | --- | --- |
| — | _no concepts yet_ | — | — |

## Working with Claude Code

[CLAUDE.md](CLAUDE.md) holds the working agreement: conventions, the MIDI gotchas that
waste the most time, and how to drive the Godot and Blender MCP servers. Read it before
asking an agent to build a concept.
