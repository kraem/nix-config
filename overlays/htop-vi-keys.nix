{ config, pkgs, fetchpatch, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      htop = super.htop.overrideAttrs (oldAttrs: rec {
        patches = [
          (super.fetchpatch {
            # https://github.com/hishamhm/htop/issues/98#issuecomment-487454186
            name = "vi-keys.patch";
            url = "https://gist.githubusercontent.com/bbugyi200/c066a5b56819c629f41f8805804e5204/raw/e8e1b09a66d9de44d2447b3ebecc29f92923b7ac/htop-vim.patch";
            sha256 = "05yc63zs5i3ay3hnfl0z1za6ls6cpv26acxkripv3c5bn2y65drh";
          })
        ];
      });
    })
  ];
}
