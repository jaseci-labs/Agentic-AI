# Custom Actions

This directory is designated for custom or downloaded actions.

## Instructions

1. **Create Your Custom Actions**: Place your custom action scripts in this folder.
2. **Naming Convention**: Use clear and descriptive names for your action files to ensure they are easily identifiable.
3. **Permissions**: Ensure your scripts have the appropriate permissions to be executed.

## Creating a Custom Action with jvcli

To create a custom action using `jvcli`, follow these steps:

1. **Run the Command**: Use the following command to create a new action:
    ```sh
    jvcli create action --name your_action_name --description "Your action description"
    ```
    Replace `your_action_name` with the desired name for your action in snake_case.

2. **Options**: You can customize the creation process with various options:
    - `--version`: Specify the version of the action. Default is `0.0.1`.
    - `--jivas_version`: Specify the version of Jivas. Default is `2.1.0`.
    - `--type`: Define the type of action (`action`, `interact_action`, or `vector_store_action`). Default is `action`.
    - `--singleton`: Indicate if the action is singleton. Default is `True`.
    - `--path`: Directory to create the action folder in. Default is `./actions`.
    - `--namespace`: Namespace for the action. Defaults to the username in the token.

3. **Example**:
    ```sh
    jvcli create action --name my_custom_action --description "This is a custom action" --type action
    ```

For more information, refer to the project's documentation.

## Notes

- Custom actions should be thoroughly tested before deployment.
- Follow best practices for scripting and error handling.

For more information, refer to the project's documentation.