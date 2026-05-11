import { Context } from "probot";

export interface CommandContext {
  context: Context<"issue_comment.created">;
  args: string[];
  owner: string;
  repo: string;
  prNumber: number;
}

export interface Command {
  name: string;
  description: string;
  execute(ctx: CommandContext): Promise<void>;
}
