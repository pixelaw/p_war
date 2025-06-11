// switchDependencies.js
import fs from "fs";
import path from "path";

const useWorkspace = process.argv.includes("--workspace");

const packageJsonPath = path.join(process.cwd(), "package.json");
const workspaceYamlDisabled = path.join(
  process.cwd(),
  "pnpm-workspace.disabled.yaml",
);
const workspaceYamlEnabled = path.join(process.cwd(), "pnpm-workspace.yaml");

// Use dynamic import for JSON files
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8"));

const submodulePaths = {
  "@pixelaw/core": "workspace:*",
  "@pixelaw/core-dojo": "workspace:*",
  "@pixelaw/core-mud": "workspace:*",
  "@pixelaw/react": "workspace:*",
  "@pixelaw/react-dojo": "workspace:*",
};

function newWorkspaceFile(filename) {
  const yamlContent = `packages:\n  - "."\n  - "../pixelaw.js/packages/*"\n`;
  fs.writeFileSync(filename, yamlContent);
}

if (useWorkspace) {
  Object.keys(submodulePaths).forEach((dep) => {
    packageJson.dependencies[dep] = submodulePaths[dep];
  });
  // Rename to enable submodules
  if (fs.existsSync(workspaceYamlDisabled)) {
    fs.renameSync(workspaceYamlDisabled, workspaceYamlEnabled);
  } else {
    newWorkspaceFile(workspaceYamlEnabled);
  }
} else {
  // Revert to regular versions
  packageJson.dependencies["@pixelaw/core"] = "^0.6.7";
  packageJson.dependencies["@pixelaw/core-dojo"] = "^0.6.7";
  packageJson.dependencies["@pixelaw/core-mud"] = "^0.6.7";
  packageJson.dependencies["@pixelaw/react"] = "^0.6.7";
  packageJson.dependencies["@pixelaw/react-dojo"] = "^0.6.7";

  if (fs.existsSync(workspaceYamlEnabled)) {
    fs.renameSync(workspaceYamlEnabled, workspaceYamlDisabled);
  } else {
    newWorkspaceFile(workspaceYamlDisabled);
  }
}

fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2));
console.log(
  `Switched to ${useWorkspace ? "submodules" : "regular"} dependencies.`,
);
