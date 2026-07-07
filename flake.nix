{
  description = "Development shell for building gamescope";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        x11Deps = with pkgs; [
          libx11
          libxdamage
          libxcomposite
          libxcursor
          libxrender
          libxext
          libxfixes
          libxxf86vm
          libxtst
          libxres
          libxmu
          libxi
          libxcb
        ];

        buildDeps = with pkgs; [
          # Core build tooling
          meson
          ninja
          pkg-config
          cmake
          git
          python3

          # Code generators / headers
          wayland-scanner
          wayland-protocols
          glslang
          vulkan-headers

          # Project dependencies
          vulkan-loader
          wayland
          wlroots_0_19
          libdisplay-info_0_2
          libdrm
          libxkbcommon
          pipewire
          hwdata
          libcap
          SDL2
          libavif
          pixman
          libinput
          systemd.dev # libudev.pc
          libdecor
          libei
          luajit
          openvr
          catch2_3
          gbenchmark
        ] ++ x11Deps;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = buildDeps;

          # Meson debug builds use -O0, while Nix's default fortify hardening
          # emits a warning at -O0. Some subprojects build with -Werror, so
          # disable fortify for this development shell.
          hardeningDisable = [ "fortify" ];

          # Makes running freshly built binaries from ./build work without
          # installing them first.
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildDeps;

          shellHook = ''
            echo "gamescope development shell"
            echo
            echo "Typical build:"
            echo "  git submodule update --init --recursive"
            echo "  meson setup build --wrap-mode=default"
            echo "  ninja -C build"
            echo
            echo "If you want a smaller/faster local build:"
            echo "  meson setup build --wrap-mode=default -Denable_tests=false -Denable_openvr_support=false"
          '';
        };
      });
}
