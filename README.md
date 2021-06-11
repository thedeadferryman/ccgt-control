# CCGT Control - OpenComputers dashboard for IT CCGT cycle

> **WARNING!** This was developed entirely in emulator and is not tested in-game yet!

## What?

[Immersive Technology](https://github.com/tgstyle/MCT-Immersive-Technology) is an addon for [Immersive Engineering](https://github.com/BluSunrize/ImmersiveEngineering) mod that adds a bunch of useful machines, including CCGT (Combined Cycle Gas Turbine) generator cycle.

## Why?

The complete CCGT cycle is pretty complex to build and even more complex to control. You should enable and disable machines and parts in the right order to bring the cycle to stable working state. Also, it would be useful to monitor the charasteristics of cycle components in a single place.

## How?

### Dependencies

- **OpenOS** (>= v1.7.5)
  - It may work on older versions, but it is not tested. (Well, it is not fully tested at all :grin:).
- **Fingercomp's [lua-objects](https://github.com/Fingercomp/lua-objects)** (v0.1.0)
- **IgorTimofeev's [GUI.lua](https://github.com/IgorTimofeev/GUI/tree/043b5948fafd28aa90da1a3814cb0631b7caf227)** (`tree 043b5948fa`)
- **Mechina** (included)

### Hardware

Max-tier computer is highly recommended since dashboard rendering takes many computational resources (and, well, I didn't test it on low-tier computer yet :upside_down_face:).

### Installation

1. Clone the repository using `gitrepo`:

   ```sh
   gitrepo thedeadferryman/ccgt-control /home/ccgt-control
   ```

2. Install dependencies listed above.

   - To install `lua-objects`, just download the lua file from the repository to `/usr/lib` folder using `wget`.

3. Link the `lib` folder to the library search path (I recommend making a symlink (or just copying) to `/home/lib`).
   - Note that there shouldn't be `lib/lib` in the path, e.g. for `/home/lib` and `windowed_list.lua` the path should be `/home/lib/windowed_list.lua`.
4. Create a Mechina profile using `bin/configure.lua` (you will see a GUI where you will be able to select component addresses and tweak some other parameters related to components).
5. To run the dashboard, use `bin/monitor.lua`.
6. Congrats, you're there!

## TODOs

- [ ] Extract Mechina to a separate library (to use in other projects) and widen its functionality.
- [ ] Implement supportive strategies (monitor all parameters automatically and keep system stable in case of problems).
- [ ] Join `monitor` and `configure` to a single executable, handle profiles inside the application.
- [ ] Compile source files to single file to provide simpler way to install and avoid library conflicts.
- [ ] Implement automatic installer.

Well, this is very nice list, but I'm not sure I will complete anything from it (maybe excluding the first one). However, contributions are always welcome :blush:.
