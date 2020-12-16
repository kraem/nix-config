{ config, pkgs, ... }:

{


  fonts = {
    fonts = with pkgs; [
      iosevka
      #iosevka-custom
      #iosevka-custom-fixed
    ];
  };

  nixpkgs.config = {
    packageOverrides = super:
      let self = super.pkgs; in
      {

        iosevka-custom-fixed = self.iosevka.override {
          set = "custom";
          privateBuildPlan = {

            family = "Iosevka Custom Fixed";

            design = [
              #"term" "v-l-italic" "v-i-italic" "v-g-singlestorey" "v-zero-dotted"
              #"v-asterisk-high" "v-at-long" "v-brace-straight"
              #"extended"
              "sp-fixed"
              "cv04"
              "cv08"
              "cv14"
              "cv19"
              "cv21"
              "cv36"
              "cv54"
            ];

          };
        };

        iosevka-custom = self.iosevka.override {
          set = "custom";
          privateBuildPlan = {

            family = "Iosevka Custom";

            design = [
              #"term" "v-l-italic" "v-i-italic" "v-g-singlestorey" "v-zero-dotted"
              #"v-asterisk-high" "v-at-long" "v-brace-straight"
              "cv04"
              "cv08"
              "cv14"
              "cv19"
              "cv21"
              "cv36"
              "cv54"
            ];

          };
        };
      };
  };

}
