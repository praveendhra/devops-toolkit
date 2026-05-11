export interface ParsedCommand {
  name: string;
  args: string[];
}

export function parseCommand(body: string): ParsedCommand | null {
  const match = body.match(/^\/(\S+)(?:\s+(.*))?$/m);
  if (!match) return null;

  const name = match[1];
  const args = match[2]?.trim().split(/\s+/).filter(Boolean) ?? [];

  return { name, args };
}
