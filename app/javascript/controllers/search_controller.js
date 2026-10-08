import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["username", "results"]

  async submit(event) {
    event.preventDefault()
    const username = this.usernameTarget.value.trim()

    try {
      const response = await fetch(`/api/repositories?username=${encodeURIComponent(username)}`)
      const data = await response.json()

      if (!response.ok) {
        this.resultsTarget.textContent = data.error
      } else if (data.repositories.length === 0) {
        this.resultsTarget.textContent = "No public repositories found."
      } else {
        this.renderRepositories(data.repositories)
      }
    } catch {
      this.resultsTarget.textContent = "Unable to load GitHub repositories."
    }
  }

  renderRepositories(repositories) {
    const list = document.createElement("ul")

    for (const repository of repositories) {
      const item = document.createElement("li")
      const heading = document.createElement("h2")
      const link = document.createElement("a")
      link.href = repository.html_url
      link.textContent = repository.name
      heading.append(link)
      item.append(heading)

      if (repository.description) {
        const description = document.createElement("p")
        description.textContent = repository.description
        item.append(description)
      }

      const metadata = document.createElement("dl")
      for (const [label, value] of [
        ["Language", repository.language || "Not specified"],
        ["Stars", repository.stargazers_count],
        ["Updated", repository.updated_at.slice(0, 10)]
      ]) {
        const entry = document.createElement("div")
        const term = document.createElement("dt")
        const detail = document.createElement("dd")
        term.textContent = label
        detail.textContent = value
        entry.append(term, detail)
        metadata.append(entry)
      }
      item.append(metadata)
      list.append(item)
    }

    this.resultsTarget.replaceChildren(list)
  }
}
