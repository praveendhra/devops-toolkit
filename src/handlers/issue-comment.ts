import { Context } from "probot";
import { CommandRegistry } from "../commands";
import { parseCommand } from "../utils/command-parser";

export function createIssueCommentHandler(registry: CommandRegistry) {
  return async (context: Context<"issue_comment.created">) => {
    const { payload } = context;

    // Only handle comments on pull requests
    if (!payload.issue.pull_request) return;

    // Ignore bot comments
    if (payload.comment.user?.type === "Bot") return;

    // Parse slash command from comment body
    const parsed = parseCommand(payload.comment.body);
    if (!parsed) return;

    // Look up the command
    const command = registry.get(parsed.name);
    if (!command) return;

    const { owner, repo } = context.repo();

    try {
      await command.execute({
        context,
        args: parsed.args,
        owner,
        repo,
        prNumber: payload.issue.number,
      });
    } catch (error) {
      context.log.error(error as Error, `Command /${parsed.name} failed`);
      await context.octokit.issues.createComment({
        owner,
        repo,
        issue_number: payload.issue.number,
        body: `❌ An unexpected error occurred while running \`/${parsed.name}\`. Check the app logs for details.`,
      });
    }
  };
}
