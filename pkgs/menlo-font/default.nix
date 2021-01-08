{ stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "Menlo";
  version = "20200106";

  srcs = [
    (fetchurl {
      url="https://github.com/kraem/fonts/raw/master/Menlo-Regular.ttf";
      sha256="0xbgbdqi9mp7ahd8q8lmfgyfmmpjzy00w8lgs3qwcn2yffp242fv";
    })
    (fetchurl {
      url="https://github.com/kraem/fonts/raw/master/Menlo-Bold.ttf";
      sha256="1w1iz3w8mpilqwhhdlndk7y2bbbckcwvyza908632gmr7lmqwplw";
    })
    (fetchurl {
      url="https://github.com/kraem/fonts/raw/master/Menlo-Italic.ttf";
      sha256="0sz912b9pwc1npf6nj99jxxjr68z5yhnns05dcbrsiaj0m8cgmns";
    })
    (fetchurl {
      url="https://github.com/kraem/fonts/raw/master/Menlo-BoldItalic.ttf";
      sha256="04pn3bldrllcxwcdficr25akg6pb2m245varddp794bj6g84s3rv";
    })
  ];

  sourceRoot = "./";

  unpackCmd = ''
    ttfName=$(basename $(stripHash $curSrc))
    cp $curSrc ./$ttfName
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp -a *.ttf $out/share/fonts/truetype/
  '';
}
