import { Context } from "probot";

type Octokit = Context["octokit"];

export async function getPullRequest(
  octokit: Octokit,
  owner: string,
  repo: string,
  pullNumber: number
) {
  const { data } = await octokit.pulls.get({
    owner,
    repo,
    pull_number: pullNumber,
  });
  return data;
}

export async function getBranchSha(
  octokit: Octokit,
  owner: string,
  repo: string,
  branch: string
) {
  const { data } = await octokit.git.getRef({
    owner,
    repo,
    ref: `heads/${branch}`,
  });
  return data.object.sha;
}

export async function createBranch(
  octokit: Octokit,
  owner: string,
  repo: string,
  branch: string,
  sha: string
) {
  const { data } = await octokit.git.createRef({
    owner,
    repo,
    ref: `refs/heads/${branch}`,
    sha,
  });
  return data;
}

export async function mergeCommitIntoBranch(
  octokit: Octokit,
  owner: string,
  repo: string,
  base: string,
  head: string,
  commitMessage: string
) {
  const { data } = await octokit.request("POST /repos/{owner}/{repo}/merges", {
    owner,
    repo,
    base,
    head,
    commit_message: commitMessage,
  });
  return data;
}

export async function addComment(
  octokit: Octokit,
  owner: string,
  repo: string,
  issueNumber: number,
  body: string
) {
  await octokit.issues.createComment({
    owner,
    repo,
    issue_number: issueNumber,
    body,
  });
}

export async function addReaction(
  octokit: Octokit,
  owner: string,
  repo: string,
  commentId: number,
  content: "eyes" | "rocket" | "+1" | "-1" | "laugh" | "confused" | "heart" | "hooray"
) {
  await octokit.reactions.createForIssueComment({
    owner,
    repo,
    comment_id: commentId,
    content,
  });
}
