{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      vulkan-headers = super.vulkan-headers.overrideAttrs (oldAttrs: rec {
        version = "1.1.114.0";
        src = self.fetchFromGitHub {
          owner = "KhronosGroup";
          repo = "Vulkan-Headers";
          rev = "sdk-${version}";
          sha256 = "0fdvh26nxibylh32lj8b62d9nf9j25xa0il9zg362wmr2zgm8gka";
        };
      });

      vulkan-tools = super.vulkan-tools.overrideAttrs (oldAttrs: rec {
        version = "1.1.114.0";
        src = self.fetchFromGitHub {
          owner = "KhronosGroup";
          repo = "Vulkan-Tools";
          rev = "sdk-${version}";
          sha256 = "1d4fcy11gk21x7r7vywdcc1dy9j1d2j78hvd5vfh3vy9fnahx107";
        };
      });

    })
  ];
}
