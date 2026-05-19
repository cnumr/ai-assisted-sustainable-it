/**
 * RGAA plugin for OpenCode.ai — stub
 * Contenu fonctionnel à développer dans le spec rgaa.
 */

import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rgaaSkillsDir = path.resolve(__dirname, "../../skills");

export const RgaaPlugin = async ({ client, directory }) => {
  return {
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(rgaaSkillsDir)) {
        config.skills.paths.push(rgaaSkillsDir);
      }
    },
  };
};
