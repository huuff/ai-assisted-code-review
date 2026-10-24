_:

{
  languages.nix.enable = true;

  git-hooks.hooks = {
    # --- secrets: never commit credentials ---
    ripsecrets.enable = true;
    detect-private-keys.enable = true;

    # --- hygiene ---
    check-added-large-files.enable = true;
    check-merge-conflicts.enable = true;
    end-of-file-fixer.enable = true;
    trim-trailing-whitespace.enable = true;

    # --- static analysis: nix ---
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;

    # --- static analysis: shell ---
    shellcheck.enable = true;
    shfmt.enable = true;

    # --- commit messages: Conventional Commits ---
    commitizen.enable = true;
  };

  enterTest = ''
    nix flake check --no-build
  '';
}
