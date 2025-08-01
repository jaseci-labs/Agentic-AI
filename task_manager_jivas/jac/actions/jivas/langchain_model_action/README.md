# LangChain Model Action

![GitHub release (latest by date)](https://img.shields.io/github/v/release/TrueSelph/langchain_model_action)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/TrueSelph/langchain_model_action/test-langchain_model_action.yaml)
![GitHub issues](https://img.shields.io/github/issues/TrueSelph/langchain_model_action)
![GitHub pull requests](https://img.shields.io/github/issues-pr/TrueSelph/langchain_model_action)
![GitHub](https://img.shields.io/github/license/TrueSelph/langchain_model_action)

This action provides a JIVAS action wrapper for the LangChain library to invoke LLM calls, facilitating abstracted interfacing with large language models (LLMs). As a core action, it simplifies and streamlines interactions with LLMs. The package is a singleton and requires the Jivas library version 2.1.0. It also depends on various Python packages for its functionality, including `openai` and different components of the LangChain ecosystem.

Additionally, this action supports streaming responses when the `streaming` flag is set in the interact configuration, enabling real-time output from the underlying LLM.

## Package Information

- **Name:** `jivas/langchain_model_action`
- **Author:** [V75 Inc.](https://v75inc.com/)
- **archetype:** `LangChainModelAction`

## Meta Information

- **Title:** LangChain Model Action
- **Group:** core
- **Type:** action

## Configuration

- **Singleton:** true

## Dependencies

- **Jivas:** `^2.1.0`
- **Pip:**
  - `openai`: `>=1.68.2`
  - `langchain`: `>=0.3.21`
  - `langchain-community`: `>=0.3.20`
  - `langchain-core`: `>=0.3.47`
  - `langchain-experimental`: `>=0.3.4`
  - `langchain-openai`: `>=0.3.9`

---

## How to Use

Below is detailed guidance on how to configure and use the LangChain Model Action.

### Overview

The LangChain Model Action provides an abstraction layer for interacting with large language models (LLMs). It supports multiple configurations for various use cases, including:

- **Custom prompts** for specific tasks.
- **Integration** with OpenAI and other LLM providers.
- **Pipeline management** for chaining multiple LLM calls.

---

### Configuration Structure

The configuration consists of the following properties:

#### `provider` (str)
Specifies the LLM provider. Supported values: `"chatopenai"` (default) or `"azurechatopenai"`.

#### `api_key` (str)
API key for authenticating with the provider.

#### `api_version` (str)
API version to use (required for Azure OpenAI).

#### `azure_endpoint` (str)
Azure endpoint URL (required for Azure OpenAI).

#### `model_name` (str)
Name of the model to use. Default: `"gpt-4o"`.

#### `model_temperature` (float)
Sampling temperature for the model. Default: `0.4`.

#### `model_max_tokens` (int)
Maximum number of tokens in the response. Default: `4096`.

---

### Example Configuration

#### Basic Configuration for OpenAI

```python
model_settings = {
    "provider": "chatopenai",
    "api_key": "your_openai_api_key",
    "model_name": "gpt-4o",
    "model_temperature": 0.4,
    "model_max_tokens": 4096
}
```

#### Configuration for Azure OpenAI

```python
model_settings = {
    "provider": "azurechatopenai",
    "api_key": "your_azure_api_key",
    "api_version": "2024-02-15-preview",
    "azure_endpoint": "https://your-resource-name.openai.azure.com/",
    "model_name": "gpt-4o",
    "model_temperature": 0.4,
    "model_max_tokens": 4096
}
```

### Best Practices
- Validate your API keys and model parameters before deployment.
- Test pipelines in a staging environment before production use.

---

## 🔰 Contributing

- **🐛 [Report Issues](https://github.com/TrueSelph/langchain_model_action/issues)**: Submit bugs found or log feature requests for the `langchain_model_action` project.
- **💡 [Submit Pull Requests](https://github.com/TrueSelph/langchain_model_action/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your GitHub account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone https://github.com/TrueSelph/langchain_model_action
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
    <a href="https://github.com/TrueSelph/langchain_model_action/graphs/contributors">
        <img src="https://contrib.rocks/image?repo=TrueSelph/langchain_model_action" />
   </a>
</p>
</details>

## 🎗 License

This project is protected under the Apache License 2.0. See [LICENSE](../LICENSE) for more information.