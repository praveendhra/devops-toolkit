import { Probot } from "probot";
import { createCommandRegistry } from "./commands";
import { createIssueCommentHandler } from "./handlers/issue-comment";

export default function app(probot: Probot): void {
  const registry = createCommandRegistry();

  probot.on("issue_comment.created", createIssueCommentHandler(registry));

  probot.log.info("DevOps Toolkit bot loaded");
}
