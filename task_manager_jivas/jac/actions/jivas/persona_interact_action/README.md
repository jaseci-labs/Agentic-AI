# Persona Interact Action

![GitHub release (latest by date)](https://img.shields.io/github/v/release/TrueSelph/persona_interact_action)
![GitHub issues](https://img.shields.io/github/issues/TrueSelph/persona_interact_action)
![GitHub pull requests](https://img.shields.io/github/issues-pr/TrueSelph/persona_interact_action)
![GitHub](https://img.shields.io/github/license/TrueSelph/persona_interact_action)

This action is designed to enhance large language model (LLM) interactions by providing a structured prompt with role, history, and context elements. As a core interact action, it serves a critical role in shaping conversations and facilitating retrieval-augmented generation. Configured as a singleton, it ensures dedicated handling of interaction flow, requiring the Jivas library version 2.0.0 and depending on the `langchain_model_action` for comprehensive functionality.

Now supports streaming responses when the `streaming` flag is set on interact calls, enabling real-time output for improved user experience.

## Package Information

- **Name:** `jivas/persona_interact_action`
- **Author:** [V75 Inc.](https://v75inc.com/)
- **archetype:** `PersonaInteractAction`

## Meta Information

- **Title:** Persona Interact Action
- **Group:** core
- **Type:** interact_action

## Configuration

- **Singleton:** true

## Dependencies

- **Jivas:** `^2.0.0-alpha.43`
- **Actions:**
  - `jivas/langchain_model_action`: `~0.0.7`

---

### Best Practices
- Validate your API keys and model parameters before deployment.
- Test pipelines in a staging environment before production use.

---

## 🔰 Contributing

- **🐛 [Report Issues](https://github.com/TrueSelph/persona_interact_action/issues)**: Submit bugs found or log feature requests for the `persona_interact_action` project.
- **💡 [Submit Pull Requests](https://github.com/TrueSelph/persona_interact_action/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your GitHub account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone https://github.com/TrueSelph/persona_interact_action
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
    <a href="https://github.com/TrueSelph/persona_interact_action/graphs/contributors">
        <img src="https://contrib.rocks/image?repo=TrueSelph/persona_interact_action" />
   </a>
</p>
</details>

## 🎗 License

This project is protected under the Apache License 2.0. See [LICENSE](../LICENSE) for more information.
