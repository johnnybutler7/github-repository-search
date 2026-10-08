require "application_system_test_case"

class RepositorySearchTest < ApplicationSystemTestCase
  test "search renders repositories without leaving the home page" do
    repository = {
      name: "hello-world",
      html_url: "https://github.com/octocat/hello-world",
      description: "A small example repository.",
      language: "Ruby",
      stargazers_count: 42,
      updated_at: "2026-10-01T12:00:00Z"
    }
    stub_request(:get, "https://api.github.com/users/octocat/repos?per_page=100")
      .to_return(status: 200, body: [ repository ].to_json)

    search_for "octocat"

    assert_link "hello-world", href: "https://github.com/octocat/hello-world"
    assert_text "A small example repository."
    assert_text "Language Ruby", normalize_ws: true
    assert_text "Stars 42", normalize_ws: true
    assert_text "Updated 2026-10-01", normalize_ws: true
    assert_current_path "/"
  end

  test "search shows a message for a user with no public repositories" do
    stub_request(:get, "https://api.github.com/users/octocat/repos?per_page=100")
      .to_return(status: 200, body: [].to_json)

    search_for "octocat"

    assert_text "No public repositories found."
  end

  test "search shows a message when GitHub fails" do
    stub_request(:get, "https://api.github.com/users/octocat/repos?per_page=100")
      .to_return(status: 500)

    search_for "octocat"

    assert_text "Unable to load GitHub repositories."
  end

  private

  def search_for(username)
    visit "/"
    fill_in "Enter a GitHub username", with: username
    click_on "Search"
  end
end
