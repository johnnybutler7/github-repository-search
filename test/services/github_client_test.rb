require "test_helper"

class GithubClientTest < ActiveSupport::TestCase
  test "fetches public repositories with the requested headers and projects fields" do
    repository = {
      "name" => "example",
      "html_url" => "https://github.com/example/example",
      "description" => nil,
      "language" => "Ruby",
      "stargazers_count" => 42,
      "updated_at" => "2026-10-01T12:00:00Z"
    }
    request = stub_request(:get, "https://api.github.com/users/some+user%2F%2B/repos")
      .with(query: { "per_page" => "100" }, headers: {
        "Accept" => "application/vnd.github+json",
        "User-Agent" => "github-repository-search",
        "X-GitHub-Api-Version" => "2026-03-10"
      })
      .to_return(status: 200, body: [ repository.merge("id" => 123, "private" => false) ].to_json)

    assert_equal [ repository ], GithubClient.new.repositories("some user/+")
    assert_requested request, times: 1
  end

  test "raises UserNotFound for a 404" do
    stub_request(:get, "https://api.github.com/users/missing/repos?per_page=100")
      .to_return(status: 404)

    assert_raises(GithubClient::UserNotFound) { GithubClient.new.repositories("missing") }
  end

  test "raises Error for another unsuccessful response" do
    stub_request(:get, "https://api.github.com/users/example/repos?per_page=100")
      .to_return(status: 500)

    assert_raises(GithubClient::Error) { GithubClient.new.repositories("example") }
  end
end
