{
  description = "Claude Code skill: review a PR together with the user, who reads and judges the code while the agent investigates on demand and applies small fixes on the branch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./nix/package.nix { };
      });

      overlays.default = final: _prev: {
        ai-assisted-code-review = final.callPackage ./nix/package.nix { };
      };

      # Uncomment if the project ships NixOS / Home Manager modules:
      # nixosModules.default = ./nix/module.nix;
      # homeManagerModules.default = ./nix/hm-module.nix;

      checks = forAllSystems (pkgs: {
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });
    };
}
