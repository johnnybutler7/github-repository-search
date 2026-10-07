require "test_helper"

class Api::RepositoriesTest < ActionDispatch::IntegrationTest
  test "returns repositories as JSON" do
    repository = {
      "name" => "example",
      "html_url" => "https://github.com/example/example",
      "description" => nil,
      "language" => "Ruby",
      "stargazers_count" => 42,
      "updated_at" => "2026-10-01T12:00:00Z"
    }
    stub_request(:get, "https://api.github.com/users/example/repos?per_page=100")
      .to_return(status: 200, body: [ repository.merge("id" => 123) ].to_json)

    get "/api/repositories", params: { username: "example" }

    assert_response :success
    assert_equal "application/json", response.media_type
    assert_equal({ "repositories" => [ repository ] }, response.parsed_body)
  end

  test "returns 404 when the GitHub user does not exist" do
    stub_request(:get, "https://api.github.com/users/missing/repos?per_page=100")
      .to_return(status: 404)

    get "/api/repositories", params: { username: "missing" }

    assert_response :not_found
    assert_equal({ "error" => "GitHub user not found." }, response.parsed_body)
  end

  test "maps a GitHub client error to 502" do
    stub_request(:get, "https://api.github.com/users/example/repos?per_page=100")
      .to_return(status: 500)

    get "/api/repositories", params: { username: "example" }

    assert_response :bad_gateway
    assert_equal({ "error" => "Unable to load GitHub repositories." }, response.parsed_body)
  end
end
