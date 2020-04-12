# MIDI CC Mapper X : Function Library

## What's this ? 

This documentation explains how to extend the `MIDI CC Mapper X` JSFX with your own additional curves, which are functions from [0..1] to [0..1] that will be proposed in `MIDI CC Mapper X`s UI.

These features are demonstrated by the 

    lib.txt

file, that implements the default library of sets of functions ; so you can have a look at it for reference, but don't modify it, since an update of the plugin may squash the file.

All your tweaks should thus be made with a text editor, in a separate file that uses the same features. You just have to create it aside (for example by duplicating the original `lib.txt`) and call it :

    user_lib.txt

If that file exists, it will supersede the default `lib.txt` file and be used instead.

When making changes to your library files, you can reload the full library directly from the plugin. Go to `Global Settings` (bottom right corner) and press the `Reload function library` button. Since the loaded functions are shared between all instances of MIDI CC Mapper X, all the opened instances will be up-to-date after the reload.

If you want to check what's in the default lib (after a reapack update for example, or because you've been working with a minimalistic `user_lib.txt`, you can temporarily rename your `user_lib.txt` to something else, and reload the function library. This will default back to the original `lib.txt`.

## File format 

All files used by MIDI CC Mapper X (`lib.txt`, `user_lib.txt`, and function files) are .txt files, for human readability and easiness of use.

### `lib.txt` and `user_lib.txt`  

These files may contain comments (ignored lines beginning with # or @).

They can also contain commands to populate the lib. Commands are written with the following generic syntax :

    command|param1|param2|etc...

The possible commands are listed below.

#### `addpset` : add a parametric set

Syntax

    addpset|pid
  
Adds a parametric set to the UI. These sets can't be modified or expanded since they are procedural. 

`pid` can have one of the three values 

- `linear` (a parametric set based on lines)
- `expnx` (a parametric set based on the exp(n.x) functions family 
- `xn` (a parametric set based on the x^n function family)

#### `addset` : add a set

Syntax

    addset|set_id|set_tab|description

Declares a set, with the id `set_id`, tab label 'set_tab' and description `description`.

`set_id` is an id for the set, it will be used by other commands to reference it, so avoid using strange characters there. `set_id` is limited to 10 chars.

`set_tab` is what's displayed in the UI tab corresponding to the set. It's limited to 8 chars.

`description` is what will be displayed in the UI. It's limited to 50 chars.

#### `addfunc` : add a curve/function

Syntax

    addfunc|set_id|row_num|col_num|sub/path/to/function

Loads the function `sub/path/to/function` and adds it to the set `set_id`, at `row_num`/`col_num` in the UI grid.

The referenced set `set_id` should have already been declared with `addset` or this command will be ignored.

The referenced function should exist as a file located at the subpath : 

    `func/sub/path/to/function.txt`. 

Note that the file name should have the `.txt` extension, but this extension is omitted in the `addfunc` parameter. Also note that the sub path is relative to the `func` directory (take example on `lib.txt`). This allows you to import some of the default functions from the default lib in your own sets, if you want for example to create your own 'speed dial' of favorites, or rearrange the disposition of things to your will.

The function file format is described below.

### `func/.../func_name.txt`

These are the function files. 

They may contain comments (lines beginning with # or @).

Additionally, the only valid other lines are floating numbers, and there should be exactly 128 lines of them. Each one represents the y value for x=n/127.0 with n being a growing integer in the range [0..127].

E.g., for the identity function, the file will look like this :

```
0
0.007874015748031496
0.015748031496062992
0.023622047244094488
..
..etc..
..
1.0
```

You may want to create those files manually, or automatically from any software/script/whatever, or using the `export` feature of MIDI CC Mapper X (see below). Don't forget to reference the function from your `user_lib.txt` file with `addfunc` (and possibly `addset` if the set is new and not yet declared).

## Exporting a function from MIDI CC Mapper X

You may want to export the current function/curve displayed in MIDI CC Mapper X (because you've drawn it or have modified a pre-defined one with the smooth button for example).

A helper script is thus provided with MIDI CC Mapper X for that purpose. It can be called from the actions window : search for `MIDI CC Mapper X - Dump Current Function`. A dialog will open and you will have to provide a `sub/path/to/function`.

This will create the function file :

    func/user_lib/sub/path/to/function.txt

that you will have to reference from your `user_lib.txt` file with `addfunc` (and possibly `addset` if the set is new and not yet declared). After having edited your `user_lib.txt` file, you can press the `Global settings > Reload function library` button to have it immediately in the UI.

Please note that `func/user_lib` is prepended, to prevent you from messing accidentally with the default `func/lib` directory (it contains the default lib files, so ideally you should leave them intact and work inside `func/user_lib`).


