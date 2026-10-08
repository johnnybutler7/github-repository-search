require "test_helper"

class GithubClientTest < ActiveSupport::TestCase
  test "returns public repositories from GitHub" do
    repository = {
      "name" => "example",
      "html_url" => "https://github.com/example/example",
      "description" => nil,
      "language" => "Ruby",
      "stargazers_count" => 42,
      "updated_at" => "2026-10-01T12:00:00Z"
    }
    request = stub_request(:get, "https://api.github.com/users/octocat/repos?per_page=100")
      .with(headers: {
        "Accept" => "application/vnd.github+json",
        "User-Agent" => "github-repository-search",
        "X-GitHub-Api-Version" => "2026-03-10"
      })
      .to_return(status: 200, body: [ repository.merge("id" => 123, "private" => false) ].to_json)

    result = GithubClient.new.repositories("octocat")

    assert_equal [ repository ], result
    assert_requested request, times: 1
  end

  test "raises UserNotFound when the GitHub user does not exist" do
    stub_request(:get, "https://api.github.com/users/missing/repos?per_page=100")
      .to_return(status: 404)

    error = assert_raises(GithubClient::UserNotFound) { GithubClient.new.repositories("missing") }

    assert_equal "GitHub user not found.", error.message
  end

  test "raises the generic Error when a GitHub request times out" do
    stub_request(:get, "https://api.github.com/users/example/repos?per_page=100")
      .to_raise(Net::ReadTimeout)

    error = assert_raises(GithubClient::Error) { GithubClient.new.repositories("example") }

    assert_instance_of GithubClient::Error, error
    assert_equal "Unable to load repositories from GitHub. Please try again.", error.message
  end

  test "raises the generic Error for other unsuccessful responses" do
    stub_request(:get, "https://api.github.com/users/example/repos?per_page=100")
      .to_return(status: 500)

    error = assert_raises(GithubClient::Error) { GithubClient.new.repositories("example") }

    assert_instance_of GithubClient::Error, error
    assert_equal "Unable to load repositories from GitHub. Please try again.", error.message
  end
end
