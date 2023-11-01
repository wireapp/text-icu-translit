# ICU transliteration for Haskell

    >>> IO.putStrLn $ transliterate (trans "name-any; ru") "\\N{RABBIT FACE} Nu pogodi!"
    🐰 Ну погоди!

    >>> IO.putStrLn $ transliterate (trans "nl-title") "gelderse ijssel"
    Gelderse IJssel

    >>> IO.putStrLn $ transliterate (trans "ja") "Amsterdam"
    アムステルダム

## Developing

- to see available outputs (targets), run 
  ```sh
  nix flake show --allow-import-from-derivation
  ```
- with `flakes` and `nix command` enabled, run
  ```sh
  nix develop -Lv
  ```
  to be dropped into a `devShell` or, alternatively, if you use `direnv`, run
  ```sh
  direnv allow
  ```
- to build and run the tests, run
  ```sh
  nix build -Lv
  ```
- refer to the [flake parts](https://flake.parts) and the [haskell flake](https://zero-to-flakes.com/haskell-flake/) documentations if you want to change the flake configs
