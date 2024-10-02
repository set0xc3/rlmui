{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      system = system;
    };

    libs = [
      pkgs.xorg.libX11
      pkgs.libGL
    ];
  in {
    devShells.${system}.default = pkgs.mkShell {
      LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath libs}";

      packages = [
        pkgs.SDL2
        pkgs.odin
      ];

      shellHook = ''
      '';
    };
  };
}
