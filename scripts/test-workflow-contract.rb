# frozen_string_literal: true

require "minitest/autorun"

ROOT = File.expand_path("..", __dir__)

class WorkflowContractTest < Minitest::Test
  ACTION = /^\s*-?\s*uses:/
  PINNED_ACTION = /^\s*-?\s*uses:\s*[^@\s]+@[0-9a-f]{40}(?:\s+#.*)?$/

  def test_update_verifies_exact_release_before_app_authenticated_pr
    workflow = File.read(File.join(ROOT, ".github/workflows/update.yml"))
    assert_includes workflow, "EXPECTED_COMMIT"
    assert_includes workflow, "gh attestation verify"
    assert_includes workflow, '--source-digest "${EXPECTED_COMMIT}"'
    assert_includes workflow, "cosign verify-blob"
    assert_includes workflow, "token: ${{ steps.app-token.outputs.token }}"
    assert_includes workflow, "--label automated-release"
    assert_includes workflow, "darwin-amd64 darwin-arm64 linux-amd64 linux-arm64"
    assert_equal workflow.scan(ACTION).length, workflow.scan(PINNED_ACTION).length
  end

  def test_auto_merge_is_narrowed_to_successful_package_prs
    workflow = File.read(File.join(ROOT, ".github/workflows/auto-merge.yml"))
    assert_includes workflow, "workflow_run.conclusion == 'success'"
    assert_includes workflow, "^package/v"
    assert_includes workflow, 'any(.name == "automated-release")'
    assert_includes workflow, "headRepositoryOwner"
  end
end
