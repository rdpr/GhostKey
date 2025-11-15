# [](https://github.com/rdpr/GhostKey/compare/v1.0.0-beta.1...v) (2025-11-15)


### Bug Fixes

* add version keys to Info.plist ([25bb5f4](https://github.com/rdpr/GhostKey/commit/25bb5f47032f3ce2258e30417baeeaacde2ed91a))
* disable Sparkle installer launcher service for unsigned apps ([4421c5a](https://github.com/rdpr/GhostKey/commit/4421c5a96a2f815ad257f02d18ee6ee69cd8d9c0))
* explicitly strip all code signatures from app bundle ([8ef1f4b](https://github.com/rdpr/GhostKey/commit/8ef1f4be7dfee91d8d67c577d460aa94ff4de316))
* pass version as xcodebuild parameters and add verification ([cfa204e](https://github.com/rdpr/GhostKey/commit/cfa204ea344443e6f8b38609f8a28042807af088))
* properly extract Sparkle signature and set app version ([94b913f](https://github.com/rdpr/GhostKey/commit/94b913fa0b3ef9e87ad171b61ce5083c6cd0190a))
* properly install Sparkle CLI tools for ZIP signing ([278be12](https://github.com/rdpr/GhostKey/commit/278be12323029d3866474e060b938bb008f18c54))
* replace heredocs with echo commands to fix YAML syntax ([c06cf30](https://github.com/rdpr/GhostKey/commit/c06cf30adc4490490e59d723cad77d3bde6ed993))
* revert to manual signing - generate_appcast requires code-signed apps ([63e495d](https://github.com/rdpr/GhostKey/commit/63e495d99676099dcd6367ca8f32dcc9bc6e1330))
* use --ed-key-file flag for sign_update ([bce136f](https://github.com/rdpr/GhostKey/commit/bce136facb30735162a34366e57ca7869ad494ec))
* use ditto for ZIP creation and add integrity verification ([f836cfe](https://github.com/rdpr/GhostKey/commit/f836cfe086c2e9d9f30857b8b60203728df441f2))
* use generate_appcast tool instead of manual appcast generation ([edda469](https://github.com/rdpr/GhostKey/commit/edda4695c0a7fd784a0777faefec533dbf8fdcd6))


### Features

* implement full code signing and notarization (v1.1.0) ([bf50550](https://github.com/rdpr/GhostKey/commit/bf50550539b83477925e099d935dce6a5b5df0e4))



# [1.0.0-beta.1](https://github.com/rdpr/GhostKey/compare/v1.0.0-beta...v1.0.0-beta.1) (2025-11-12)


### Bug Fixes

* allow builds without Sparkle signature verification ([7cf60f4](https://github.com/rdpr/GhostKey/commit/7cf60f49a362132f6db39cf2aeeb7f555c34cc3a))
* inject Sparkle public key before building app ([fa3478c](https://github.com/rdpr/GhostKey/commit/fa3478c4c793d817efc548fde2b9338cac45b4a7))
* prevent Sparkle diagnostics from failing the build ([1b853a0](https://github.com/rdpr/GhostKey/commit/1b853a029e2567554780796ff4075c9cf5275fa0))
* resolve YAML syntax error in release workflow ([8a43696](https://github.com/rdpr/GhostKey/commit/8a43696ce3cbd889f95e150815f5dfb5e0743ead))
* use echo commands to avoid YAML parsing issues with XML ([cfb1c6c](https://github.com/rdpr/GhostKey/commit/cfb1c6cdb3fcded2aee4d9b4dd67a1d7307658a0))



# [1.0.0-beta](https://github.com/rdpr/GhostKey/compare/v1.0.0-alpha...v1.0.0-beta) (2025-11-11)



# 1.0.0-alpha (2025-11-10)



