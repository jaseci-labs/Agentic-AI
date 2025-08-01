# Intro Interact Action

![GitHub release (latest by date)](https://img.shields.io/github/v/release/TrueSelph/intro_interact_action)
![GitHub issues](https://img.shields.io/github/issues/TrueSelph/intro_interact_action)
![GitHub pull requests](https://img.shields.io/github/issues-pr/TrueSelph/intro_interact_action)
![GitHub](https://img.shields.io/github/license/TrueSelph/intro_interact_action)

This action triggers upon a first-time user message by dispatching an introductory prompt directive to the `persona_response_action`. As a core interact action, it ensures that new users receive an engaging and informative initial interaction. The package is a singleton, and it requires the Jivas library version 2.0.0 and depends on the `persona_interact_action` for executing its introductory directive.

## Package Information

- **Name:** `jivas/intro_interact_action`
- **Author:** [V75 Inc.](https://v75inc.com/)
- **archetype:** `IntroInteractAction`

## Meta Information

- **Title:** Intro Interact Action
- **Group:** core
- **Type:** action

## Configuration

- **Singleton:** true

## Dependencies

- **Jivas:** `^2.1.0`
- **Actions:**
  - `jivas/persona_interact_action`: `>=0.1.0`

---

### Best Practices
- Validate your API keys and model parameters before deployment.
- Test pipelines in a staging environment before production use.

---

## 🔰 Contributing

- **🐛 [Report Issues](https://github.com/TrueSelph/intro_interact_action/issues)**: Submit bugs found or log feature requests for the `intro_interact_action` project.
- **💡 [Submit Pull Requests](https://github.com/TrueSelph/intro_interact_action/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your GitHub account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone https://github.com/TrueSelph/intro_interact_action
   ```
3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.
   ```sh
   git checkout -b new-feature-x
   ```
4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.
   ```sh
   git commit -m 'Implemented new feature x.'
   ```
6. **Push to GitHub**: Push the changes to your forked repository.
   ```sh
   git push origin new-feature-x
   ```
7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.
8. **Review**: Once your PR is reviewed and approved, it will be merged into the main branch. Congratulations on your contribution!
</details>

<details open>
<summary>Contributor Graph</summary>
<br>
<p align="left">
    <a href="https://github.com/TrueSelph/intro_interact_action/graphs/contributors">
        <img src="https://contrib.rocks/image?repo=TrueSelph/intro_interact_action" />
   </a>
</p>
</details>

## 🎗 License

This project is protected under the Apache License 2.0. See [LICENSE](../LICENSE) for more information.
