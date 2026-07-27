# Emacs configuration module.
# Manages the Emacs package with extra packages while allowing the user
# to manage their own .emacs.d (e.g., from a git repo).
{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-pgtk;

    # Let the user manage .emacs.d themselves (from their own git repo),
    # but have nix install all the packages that config needs.
    extraPackages = epkgs: with epkgs; [
      # Core package management
      use-package
      diminish
      gcmh

      # Minibuffer / completion
      vertico
      orderless
      marginalia
      embark
      embark-consult
      consult
      corfu
      cape
      yasnippet
      company

      # LSP / Language support
      eglot
      flymake
      flymake-actionlint
      flymake-flycheck
      flymake-ruff

      # Git
      magit
      forge
      git-timemachine
      diff-hl
      git-link
      git-modes
      github-clone
      github-review
      magit-todos
      yagist
      vc-darcs

      # Project
      projectile
      projectile-rails
      rg

      # Editing / UI
      which-key
      avy
      multiple-cursors
      move-dup
      whole-line-or-region
      unfill
      switch-window
      rainbow-delimiters
      rainbow-mode
      page-break-lines
      highlight-quoted
      highlight-escape-sequences
      disable-mouse
      symbol-overlay
      anzu
      aggressive-indent
      auto-compile
      vlf
      browse-kill-ring
      list-unicode-display
      windswap
      pulsar
      puni
      origami
      expreg

      # Org mode
      org
      org-pomodoro
      org-cliplink

      # Markdown / text
      markdown-mode
      textile-mode
      crontab-mode
      csv-mode

      # Languages - functional
      haskell-mode
      tuareg
      ocaml-ts-mode
      rust-mode
      go-mode
      lua-mode
      j-mode
      elm-mode
      elm-test-runner
      purescript-mode
      nim-mode
      erlang
      elixir-mode

      # Languages - config / devops
      terraform-mode
      nix-mode
      nixfmt
      nixpkgs-fmt
      yaml-mode
      toml-mode
      json-mode
      docker
      dockerfile-mode
      docker-compose-mode

      # Web development (note: html-mode, css-mode, js-mode are built-in)
      scss-mode
      sass-mode
      less-css-mode
      haml-mode
      php-mode
      js2-mode
      typescript-mode
      web-mode

      # Ruby / Rails
      ruby-hash-syntax
      inf-ruby
      robe
      rspec-mode
      ruby-compilation

      # Lisp / Clojure / SLY (note: paredit is in nixpkgs but elisp-mode is built-in)
      sly
      sly-asdf
      sly-macrostep
      sly-repl-ansi-color
      cider
      clojure-mode
      clojure-ts-mode
      cljsbuild-mode

      # Python (note: python-mode is built-in)
      eat

      # Build / Format
      prettier-js
      ruff-format
      sqlformat
      dune
      dune-format

      # Flycheck
      flycheck-clojure
      flycheck-ledger
      flycheck-nim
      flycheck-rust
      flycheck-relint

      # Misc modes
      restclient
      httprepl
      ledger-mode
      diredfl
      mmm-mode
      just-mode
      justl
      just-ts-mode
      nginx-mode
      pip-requirements

      # Tools / Utilities
      exec-path-from-shell
      default-text-scale
      mode-line-bell
      dimmer
      writeroom-mode

      # Themes
      color-theme-sanityinc-solarized
      color-theme-sanityinc-tomorrow

      # Helpful
      helpful
      elisp-slime-nav
      macrostep

      # ibuffer
      ibuffer-vc
      ibuffer-projectile

      # Misc packages
      sudo-edit
      htmlize
      immortal-scratch
      envrc
      gnu-elpa-keyring-update
      package-lint-flymake
      cask-mode
      cl-libify
      dash-at-point
    ];
  };
}
