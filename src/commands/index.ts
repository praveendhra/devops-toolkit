import { CommandRegistry } from "./registry";
import { cherryPickCommand } from "./cherry-pick";

export function createCommandRegistry(): CommandRegistry {
  const registry = new CommandRegistry();
  registry.register(cherryPickCommand);
  return registry;
}

export { CommandRegistry } from "./registry";
export type { Command, CommandContext } from "./types";
