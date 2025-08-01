# Getting Started with JIVAS

Welcome to your JIVAS AI project boilerplate!

## Command Reference

This section provides a comprehensive guide to all available JVCLI commands, their options, and examples of their usage.

### Authentication Commands

Authentication commands help you create and manage your Jivas Package Repository account.

#### `jvcli signup`

Create a new account on the Jivas Package Repository. This command will prompt you for your username, email, and password if not provided as options.

```sh
# Interactive signup with prompts
jvcli signup

# Providing all parameters directly
jvcli signup --username myusername --email user@example.com --password mypassword
```

Options:
- `--username`: Your desired username for the JPR account
- `--email`: Your email address
- `--password`: Your password (will be hidden during input)

After successful signup, your authentication token will be automatically saved to your local configuration.

#### `jvcli login`

Log in to your existing Jivas Package Repository account. This command authenticates you and saves the authentication token locally for future commands.

```sh
# Interactive login with prompts
jvcli login

# Providing credentials directly
jvcli login --username user@example.com --password mypassword
```

Options:
- `--username`: Your email address or username
- `--password`: Your password (will be hidden during input)

Upon successful login, your token will be saved locally and you'll see a confirmation message.

#### `jvcli logout`

Log out from the Jivas Package Repository by removing your local authentication token.

```sh
jvcli logout
```

This command doesn't require any options and will clear all local authentication data.

### Project Management Commands

These commands help you manage your Jivas projects, from initial setup to maintenance.

#### `jvcli startproject`

Create a new Jivas project with all necessary scaffolding and folder structure. This command sets up a complete project template with all required files.

```sh
# Create a new project with default settings
jvcli startproject my_project

# Create a project with a specific Jivas version
jvcli startproject my_project --version 2.0.0

# Create a project without generating an environment file
jvcli startproject my_project --no-env
```

Options:
- `--version`: Specify the Jivas project version to use for scaffolding (default: latest supported version)
- `--no-env`: Skip generating the .env file with default configurations

This command creates a directory structure with:
- Actions directory for custom actions
- DAF directory for agent packages
- Main JAC file for your JIVAS application
- Configuration files and shell scripts for easy management

### Create Commands

Create commands help you generate new resources like actions, agents, and namespaces with the proper structure and configuration.

#### `jvcli create action`

Create a new action with its folder structure, configuration files, and code templates. Actions are modular components that can be used by agents to perform specific tasks.

```sh
# Create a basic action with interactive prompts
jvcli create action

# Create an action with a specific name
jvcli create action --name custom_action

# Create a fully customized action
jvcli create action \
  --name custom_action \
  --version 1.0.0 \
  --description "A custom action for processing data" \
  --type interact_action \
  --jivas_version 2.0.0 \
  --singleton true \
  --path ./my_actions \
  --namespace my-namespace
```

Options:
- `--name`: Name of the action (must be snake_case) - will be prompted if not provided
- `--version`: Version of the action (default: 0.0.1)
- `--jivas_version`: Version of Jivas to target (default: latest supported)
- `--description`: Detailed description of the action's purpose
- `--type`: Type of action - can be one of:
  - `action`: Standard action (default)
  - `interact_action`: Action that can interact with users
  - `vector_store_action`: Action for vector database operations
- `--singleton`: Whether the action should be singleton (default: true)
- `--path`: Directory to create the action folder in (default: ./actions)
- `--namespace`: Namespace for the action (defaults to your username from token)

The command creates:
- Action directory structure
- info.yaml configuration file
- JAC files with code templates
- Streamlit app files for the action's UI
- README and CHANGELOG files

#### `jvcli create agent`

Create a new agent (DAF package) with all necessary configuration files. Agents are the main building blocks of JIVAS applications.

```sh
# Create a basic agent with interactive prompts
jvcli create agent

# Create an agent with a specific name
jvcli create agent --name custom_agent

# Create a fully customized agent
jvcli create agent \
  --name custom_agent \
  --version 1.0.0 \
  --description "A custom JIVAS agent for customer support" \
  --jivas_version 2.0.0 \
  --path ./my_agents \
  --namespace my-namespace
```

Options:
- `--name`: Name of the agent (must be snake_case) - will be prompted if not provided
- `--version`: Version of the agent (default: 0.0.1)
- `--jivas_version`: Version of Jivas to target (default: latest supported)
- `--description`: Detailed description of the agent's purpose (default: "A jivas agent autocreated by the jvcli")
- `--path`: Directory to create the agent in (default: ./daf)
- `--namespace`: Namespace for the agent (defaults to your username from token)

The command creates:
- Agent directory structure
- info.yaml package configuration
- descriptor.yaml defining agent behavior
- knowledge.yaml for agent knowledge base
- memory.yaml for agent memory storage
- README and CHANGELOG files

#### `jvcli create namespace`

Create a new namespace through the API to organize your packages. Namespaces help you group related packages and manage permissions.

```sh
# Create a namespace with interactive prompt
jvcli create namespace

# Create a namespace with a specific name
jvcli create namespace --name my-namespace
```

Options:
- `--name`: Name of the namespace (must be lowercase with only letters, numbers, and hyphens)

This command requires you to be authenticated with the JPR. After creating the namespace, it will be added to your account's permissions.

### Publish Commands

Publish commands allow you to package and publish your actions and agents to the Jivas Package Repository.

#### `jvcli publish action`

Package and publish an action to the Jivas Package Repository. This makes your action available for others to download and use.

```sh
# Publish an action
jvcli publish action --path ./actions/my_action

# Publish with specific visibility
jvcli publish action --path ./actions/my_action --visibility private

# Generate package without publishing
jvcli publish action --path ./actions/my_action --package-only --output ./packages

# Publish a pre-packaged tarball with explicit namespace
jvcli publish action --path ./packages/my_action.tar.gz --namespace my-namespace
```

Options:
- `--path`: Path to the directory containing the action to publish (or path to a tarball)
- `--visibility`: Visibility of the published action (`public` or `private`, default: `public`)
- `--package-only`: Only generate the package without publishing to JPR
- `--output`, `-o`: Output path for the generated package (used with `--package-only`)
- `--namespace`: Namespace of the package (required when `--path` is a tarball)

The command will validate your action's structure, create a tarball package, and upload it to the JPR unless `--package-only` is specified.

#### `jvcli publish agent`

Package and publish an agent (DAF) to the Jivas Package Repository. This makes your agent available for others to download and use.

```sh
# Publish an agent
jvcli publish agent --path ./daf/my_agent

# Publish with specific visibility
jvcli publish agent --path ./daf/my_agent --visibility private

# Generate package without publishing
jvcli publish agent --path ./daf/my_agent --package-only --output ./packages

# Publish a pre-packaged tarball with explicit namespace
jvcli publish agent --path ./packages/my_agent.tar.gz --namespace my-namespace
```

Options:
- `--path`: Path to the directory containing the agent to publish (or path to a tarball)
- `--visibility`: Visibility of the published agent (`public` or `private`, default: `public`)
- `--package-only`: Only generate the package without publishing to JPR
- `--output`, `-o`: Output path for the generated package (used with `--package-only`)
- `--namespace`: Namespace of the package (required when `--path` is a tarball)

The command will validate your agent's structure, create a tarball package, and upload it to the JPR unless `--package-only` is specified.

### Download Commands

Download commands let you retrieve actions and agents from the Jivas Package Repository.

#### `jvcli download action`

Download a JIVAS action package from the repository to your local environment.

```sh
# Download the latest version of an action
jvcli download action my_namespace/custom_action

# Download a specific version
jvcli download action my_namespace/custom_action 1.0.0

# Download to a custom directory
jvcli download action my_namespace/custom_action --path ./my_custom_actions

# Download a specific version to a custom directory
jvcli download action my_namespace/custom_action 1.0.0 --path ./my_custom_actions
```

Arguments:
- `name`: Name of the action to download (including namespace)
- `version`: Version of the action (optional, default: latest)

Options:
- `--path`: Directory to download the action to (optional, default: ./actions)

The downloaded action will be extracted to a directory named after the action in the specified path.

#### `jvcli download agent`

Download a JIVAS agent package (DAF) from the repository to your local environment.

```sh
# Download the latest version of an agent
jvcli download agent my_namespace/custom_agent

# Download a specific version
jvcli download agent my_namespace/custom_agent 1.0.0

# Download to a custom directory
jvcli download agent my_namespace/custom_agent --path ./my_custom_agents

# Download a specific version to a custom directory
jvcli download agent my_namespace/custom_agent 1.0.0 --path ./my_custom_agents
```

Arguments:
- `name`: Name of the agent to download (including namespace)
- `version`: Version of the agent (optional, default: latest)

Options:
- `--path`: Directory to download the agent to (optional, default: ./daf)

The downloaded agent will be extracted to a directory named after the agent in the specified path.

### Info Commands

Info commands provide detailed information about packages in the Jivas Package Repository.

#### `jvcli info action`

Get detailed information about an action package in the repository. This includes metadata, dependencies, and configuration details.

```sh
# Get info for the latest version of an action
jvcli info action my_namespace/custom_action

# Get info for a specific version
jvcli info action my_namespace/custom_action 1.0.0
```

Arguments:
- `name`: Name of the action (including namespace)
- `version`: Version of the action (optional, default: latest)

The output displays the complete package information in YAML format, including:
- Package metadata (name, version, author)
- Description and title
- Dependencies and compatibility information
- Configuration details

#### `jvcli info agent`

Get detailed information about an agent package in the repository. This includes metadata, dependencies, and configuration details.

```sh
# Get info for the latest version of an agent
jvcli info agent my_namespace/custom_agent

# Get info for a specific version
jvcli info agent my_namespace/custom_agent 1.0.0
```

Arguments:
- `name`: Name of the agent (including namespace)
- `version`: Version of the agent (optional, default: latest)

The output displays the complete package information in YAML format, including:
- Package metadata (name, version, author)
- Description and title
- Dependencies and compatibility information
- Configuration details

### Update Commands

Update commands allow you to modify existing resources like namespaces.

#### `jvcli update namespace`

Perform update operations on a specified namespace, such as inviting users or transferring ownership.

```sh
# Invite a user to a namespace
jvcli update namespace my-namespace --invite user@example.com

# Transfer ownership of a namespace
jvcli update namespace my-namespace --transfer newowner@example.com
```

Arguments:
- `namespace`: Name of the namespace to update

Options:
- `--invite`: Email address of a user to invite to the namespace
- `--transfer`: Email address of a user to transfer namespace ownership to

Note: The `--invite` and `--transfer` options are mutually exclusive - you can only use one at a time.

### Server Commands

Server commands help you manage the Jivas Server, including launching, authentication, and agent management.

#### `jvcli server launch`

Launch the Jivas Server by running a specified JAC file. This starts the server for local development and testing.

```sh
# Launch the server with the default main.jac file
jvcli server launch

# Launch the server with a custom JAC file
jvcli server launch --jac-file custom.jac
```

Options:
- `--jac-file`: Path to the JAC file to run (default: main.jac in the current directory)

This command starts the Jivas Server, which will listen for connections on the default port (usually 8000).

#### `jvcli server login`

Log in to a running Jivas Server and get an authentication token. This token can be used for subsequent API calls.

```sh
# Interactive login with prompts
jvcli server login

# Providing credentials directly
jvcli server login --email admin@example.com --password mypassword
```

Options:
- `--email`: Email address for Jivas login (defaults to JIVAS_USER env var if set)
- `--password`: Password for Jivas login (defaults to JIVAS_PASSWORD env var if set)

Upon successful login, the token will be printed and stored in the JIVAS_TOKEN environment variable.

#### `jvcli server createadmin`

Create a system administrator account on a running Jivas Server. This is useful for initial setup.

```sh
# Interactive createadmin with prompts
jvcli server createadmin

# Providing credentials directly
jvcli server createadmin --email admin@example.com --password mypassword
```

Options:
- `--email`: Email address for the system admin (defaults to JIVAS_USER env var if set)
- `--password`: Password for the system admin (defaults to JIVAS_PASSWORD env var if set)

This command behaves differently based on your database configuration:
- With MongoDB configured: Uses the `jac create_system_admin` command
- Without MongoDB: Uses the server's API signup endpoint

#### `jvcli server initagents`

Initialize agents in the Jivas system. This command reloads all agents and their actions, useful after making changes.

```sh
jvcli server initagents
```

This command:
1. Checks if the server is running
2. Logs in to the server
3. Sends a request to the server to reinitialize all agents

#### `jvcli server importagent`

Import an agent from a DAF package into a running Jivas server. This allows you to add new agents to your system.

```sh
# Import the latest version of an agent
jvcli server importagent my_namespace/custom_agent

# Import a specific version
jvcli server importagent my_namespace/custom_agent 1.0.0
```

Arguments:
- `agent_name`: Name of the agent to import (including namespace)
- `version`: Version of the agent (optional, default: latest)

This command:
1. Checks if the server is running
2. Logs in to the server
3. Sends a request to import the specified agent
4. Displays the agent ID upon successful import

### Studio Commands

Studio commands help you manage the Jivas Studio, a web-based development environment for Jivas.

#### `jvcli studio launch`

Launch the Jivas Studio on a specified port. Jivas Studio provides a visual interface for building and managing agents.

```sh
# Launch with default settings
jvcli studio launch

# Launch on a custom port
jvcli studio launch --port 9000

# Launch with authentication required
jvcli studio launch --require-auth
```

Options:
- `--port`: Port for the studio to launch on (default: 8989)
- `--require-auth`: Require authentication for studio API access (default: false)

When launched, the Studio will be accessible via a web browser at `http://localhost:<port>`.

### Client Commands

Client commands help you manage the Jivas Client, which provides a user interface for interacting with agents.

#### `jvcli client launch`

Launch the Jivas Client, which provides a web interface for configuring and chatting with agents.

```sh
# Launch with default settings
jvcli client launch

# Launch on a custom port
jvcli client launch --port 9001

# Launch with custom server URLs
jvcli client launch \
  --jivas_url http://my-server:8000 \
  --studio_url http://my-studio:8989
```

Options:
- `--port`: Port for the client to launch on (default: 8501)
- `--jivas_url`: URL for the Jivas API (default: http://localhost:8000 or JIVAS_BASE_URL env var)
- `--studio_url`: URL for the Jivas Studio (default: http://localhost:8989 or JIVAS_STUDIO_URL env var)

When launched, the Client will be accessible via a web browser at `http://localhost:<port>`.
