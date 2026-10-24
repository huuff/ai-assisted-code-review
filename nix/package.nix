{
  stdenvNoCC,
  lib,
}:

stdenvNoCC.mkDerivation {
  pname = "ai-assisted-code-review";
  version = "0.1.0";

  # Only the skill files; devenv/flake scaffolding is not part of the package.
  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../SKILL.md
      ../RATIONALE.md
    ];
  };

  installPhase = ''
    mkdir -p $out/share/agent-skills
    cp -r . $out/share/agent-skills/ai-assisted-code-review
  '';

  meta = {
    description = "Claude Code skill: review a PR together with the user, who reads and judges the code while the agent investigates on demand and applies small fixes on the branch";
    license = lib.licenses.mit;
  };
}
