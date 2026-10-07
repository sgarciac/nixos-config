# Emacs configuration module for Emacs Bedrock.
# Uses only packages from the Emacs Bedrock starter kit.
{ pkgs, inputs, ... }:

{
  programs.emacs = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.emacs31-pgtk;

    # Packages from Emacs Bedrock config
    extraPackages = epkgs: with epkgs; [
      # --- Core package management ---
      use-package # Declarative package configuration macro

      # --- Minibuffer / completion (extras/base.el) ---
      vertico # Vertical completion UI
      orderless # Alternative completion style (fuzzy matching)
      marginalia # Annotations for completion candidates
      embark # Keyboard-driven context menu for completions
      consult # Useful commands (buffer switch, grep, etc.)
      corfu # Completion-at-point popup
      cape # Completion at point extensions

      # --- Navigation (extras/base.el) ---
      avy # Quick jump to characters/lines anywhere
      which-key # Popup showing available keybindings

      # --- Git (extras/dev.el) ---
      magit # Git interface (best in the universe)

      # --- Templates (extras/dev.el) ---
      tempel # Lightweight template library

      # --- Vim emulation (extras/vim-like.el) ---
      evil # Vim keybindings in Emacs
      evil-collection # Evil bindings for built-in modes
      evil-leader # Leader key support for Evil

      # --- Academic tools (extras/researcher.el) ---
      citar # Bibliography management and citation insertion
      denote # Simple note-taking with backlinks

      # --- Writing aids (extras/writer.el) ---
      jinx # Fast spell checker using hunspell
      olivetti # Centered text with balanced margins
    ];
  };
}
