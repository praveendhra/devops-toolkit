import { Command, CommandContext } from "./types";
import * as github from "../services/github";

const VALID_BRANCH_NAME = /^[\w.\-/]+$/;

export const cherryPickCommand: Command = {
  name: "cherry-pick",
  description: "Cherry-pick a merged PR to a target branch",

  async execute(ctx: CommandContext): Promise<void> {
    const { context, args, owner, repo, prNumber } = ctx;
    const octokit = context.octokit;

    // --- Validate arguments ---
    if (args.length === 0) {
      await github.addComment(
        octokit, owner, repo, prNumber,
        "❌ Usage: `/cherry-pick <target-branch>`"
      );
      return;
    }

    const targetBranch = args[0];

    if (!VALID_BRANCH_NAME.test(targetBranch)) {
      await github.addComment(
        octokit, owner, repo, prNumber,
        "❌ Invalid branch name. Branch names may only contain alphanumeric characters, hyphens, dots, underscores, and forward slashes."
      );
      return;
    }

    // --- Acknowledge the command ---
    await github.addReaction(
      octokit, owner, repo,
      context.payload.comment.id,
      "eyes"
    );

    // --- Verify the PR is merged ---
    const pr = await github.getPullRequest(octokit, owner, repo, prNumber);

    if (!pr.merged || !pr.merge_commit_sha) {
      await github.addComment(
        octokit, owner, repo, prNumber,
        "❌ This PR has not been merged yet. Cherry-pick is only available for merged PRs."
      );
      return;
    }

    // --- Verify target branch exists ---
    let targetBranchSha: string;
    try {
      targetBranchSha = await github.getBranchSha(octokit, owner, repo, targetBranch);
    } catch {
      await github.addComment(
        octokit, owner, repo, prNumber,
        `❌ Target branch \`${targetBranch}\` not found.`
      );
      return;
    }

    // --- Create the cherry-pick branch ---
    const cherryPickBranch = `cherry-pick/pr-${prNumber}-to-${targetBranch}`;

    try {
      await github.createBranch(octokit, owner, repo, cherryPickBranch, targetBranchSha);
    } catch (error: any) {
      if (error.status === 422) {
        await github.addComment(
          octokit, owner, repo, prNumber,
          `❌ Branch \`${cherryPickBranch}\` already exists. Delete it first and try again.`
        );
        return;
      }
      throw error;
    }

    // --- Merge the PR's merge commit into the cherry-pick branch ---
    const mergeCommitSha = pr.merge_commit_sha;

    try {
      await github.mergeCommitIntoBranch(
        octokit, owner, repo,
        cherryPickBranch,
        mergeCommitSha,
        `Cherry-pick: ${pr.title} (#${prNumber})`
      );
    } catch (error: any) {
      if (error.status === 409) {
        await github.addComment(
          octokit, owner, repo, prNumber,
          `⚠️ Cherry-pick to \`${targetBranch}\` resulted in merge conflicts.\n\n` +
          `The branch \`${cherryPickBranch}\` has been created from \`${targetBranch}\`. ` +
          `You can resolve the conflicts manually:\n\n` +
          "```bash\n" +
          `git fetch origin\n` +
          `git checkout ${cherryPickBranch}\n` +
          `git cherry-pick ${mergeCommitSha}\n` +
          `# Resolve conflicts, then:\n` +
          `git push origin ${cherryPickBranch}\n` +
          "```"
        );
        return;
      }
      throw error;
    }

    // --- Post success comment with PR creation link ---
    const compareUrl =
      `https://github.com/${owner}/${repo}/compare/${targetBranch}...${cherryPickBranch}` +
      `?expand=1` +
      `&title=${encodeURIComponent(`[Cherry-pick] ${pr.title}`)}` +
      `&body=${encodeURIComponent(`Cherry-pick of #${prNumber} to \`${targetBranch}\``)}`;

    await github.addComment(
      octokit, owner, repo, prNumber,
      `✅ Cherry-pick branch \`${cherryPickBranch}\` created successfully!\n\n` +
      `[🔗 Create Cherry-Pick PR to \`${targetBranch}\`](${compareUrl})`
    );
  },
};
