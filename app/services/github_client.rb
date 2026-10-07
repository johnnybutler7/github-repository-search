require "net/http"

class GithubClient
  HEADERS = {
    "Accept" => "application/vnd.github+json",
    "User-Agent" => "github-repository-search",
    "X-GitHub-Api-Version" => "2026-03-10"
  }.freeze

  class Error < StandardError; end
  class UserNotFound < Error; end

  def repositories(username)
    response = get(repository_uri(username))

    raise UserNotFound, "GitHub user not found" if response.is_a?(Net::HTTPNotFound)
    raise Error, "GitHub request failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).map do |repository|
      repository.slice("name", "html_url", "description", "language", "stargazers_count", "updated_at")
    end
  end

  private

  def repository_uri(username)
    encoded_username = URI.encode_www_form_component(username)
    URI("https://api.github.com/users/#{encoded_username}/repos?per_page=100")
  end

  def get(uri)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 5) do |http|
      http.request(request_for(uri))
    end
  end

  def request_for(uri)
    Net::HTTP::Get.new(uri, HEADERS)
  end
end
