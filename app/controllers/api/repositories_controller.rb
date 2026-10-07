module Api
  class RepositoriesController < ApplicationController
    def index
      repositories = GithubClient.new.repositories(params[:username].to_s.strip)
      render json: { repositories: repositories }
    rescue GithubClient::UserNotFound
      render json: { error: "GitHub user not found." }, status: :not_found
    rescue GithubClient::Error
      render json: { error: "Unable to load GitHub repositories." }, status: :bad_gateway
    end
  end
end
