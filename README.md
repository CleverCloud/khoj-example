# Khoj Test Application

[![Clever Cloud - PaaS](https://img.shields.io/badge/Clever%20Cloud-PaaS-orange)](https://clever-cloud.com)

## What is Khoj?

Khoj is an advanced AI-powered personal knowledge assistant that serves as your second brain. It's designed to extend your capabilities by providing intelligent search and chat functionality across your personal data and the web.

### Key Features

- **AI-Powered Chat**: Interact with various LLMs (including GPT, Claude, Gemini, Llama3, Mistral) to get answers from your documents and the internet
- **Semantic Search**: Find relevant information quickly using advanced semantic search across your knowledge base
- **Multi-Format Support**: Process and understand PDFs, Markdown, Word documents, Notion pages, org-mode files, and plain text
- **Multiple Interfaces**: Access through web browser, desktop app, Obsidian plugin, Emacs package, or even WhatsApp
- **Custom Agents**: Create specialized AI agents with custom knowledge bases, personas, and tools
- **Privacy-Focused**: Self-hostable solution that keeps your personal data under your control
- **Research Automation**: Schedule automated research tasks and receive personalized newsletters

## Overview

This repository contains a ready-to-deploy Khoj application configured specifically for Clever Cloud's PaaS environment. Khoj requires a PostgreSQL database and proper environment configuration to function correctly. The deployment steps below will guide you through setting up all necessary components.

By deploying Khoj on Clever Cloud, you benefit from:

- **Scalable Infrastructure**: Easily scale your Khoj instance as your needs grow
- **Managed PostgreSQL**: Utilize Clever Cloud's managed PostgreSQL add-on
- **Continuous Deployment**: Seamlessly update your Khoj instance with new changes
- **High Availability**: Benefit from Clever Cloud's reliable infrastructure
- **Monitoring**: Access logs and performance metrics through Clever Cloud's dashboard

## Prerequisites

1. **A [Clever Cloud](https://www.clever-cloud.com/) account**: Sign up at [clever-cloud.com](https://www.clever-cloud.com/) if you don't have an account.

2. **A domain name (optional, but recommended for production use)**

3. **[Clever Tools CLI](https://github.com/CleverCloud/clever-tools)**: Install the Clever Cloud CLI tool:

   ```bash
   npm install -g clever-tools
   ```

4. **Login to Clever Cloud**:

   ```bash
   clever login
   ```


## Deploying in Clever Cloud

This section explains how to deploy this application to Clever Cloud using the Clever CLI.


### Before You Begin

Before starting the deployment process, you'll need to decide on:

- **Application Name**: Choose a unique name for your n8n application (e.g., `my-khoj`)
- **Domain Name**: Optionally, choose a domain name for your application

You'll use these values throughout the deployment process. In the commands below, replace:
- `<my_app_name>` with your chosen application name
- `<my_domain>` with your domain name (if applicable)

You will also need API keys for at least one LLM provider:

    - OpenAI : [Get API key](https://platform.openai.com/) and in the commands below, replace `<my_openai_api_key>` with your API key
    - Anthropic : [Get API key](https://console.anthropic.com/) and in the commands below, replace `<my_anthropic_api_key>` with your API key
    - Gemini : [Get API key](https://console.gemini.com/) and in the commands below, replace `<my_gemini_api_key>` with your API key
    - Any OpenAI compatible provider, like Clever AI from Clever Cloud, and in the commands below, replace `<my_openai_api_key>` with your API key and `<my_openai_base_url>` with your base URL

### Deployment Steps

#### 1. Create and Configure Application

```bash
# Create a new Python application
clever create --type python --region par <my_app_name>

# Scale the application to medium size AT MINUMUM
clever scale --app <my_app_name> --flavor M

# Add a domain (optional but recommended)
clever domain add <my_domain>
```

#### 2. Set Up PostgreSQL Database

```bash
# Create PostgreSQL add-on
clever addon create postgresql-addon --plan xxs_med --region par <my_postgresql_name>

# Link the PostgreSQL add-on to your application
clever service link-addon <my_postgresql_name>
```

#### 3. Configure Platform Environment

```bash
# Set platform environment variables
clever env set CC_PYTHON_VERSION 3.12
clever env set CC_RUN_COMMAND ./run.sh
clever env set CC_TROUBLESHOOT true

# Configure database environment variables (automatically from PostgreSQL add-on)
clever env set POSTGRES_DB `clever env | awk -F = '/POSTGRESQL_ADDON_DB/ { gsub(/"/, "", $2); print $2}'`
clever env set POSTGRES_HOST `clever env | awk -F = '/POSTGRESQL_ADDON_HOST/ { gsub(/"/, "", $2); print $2}'`
clever env set POSTGRES_PORT `clever env | awk -F = '/POSTGRESQL_ADDON_PORT/ { gsub(/"/, "", $2); print $2}'`
clever env set POSTGRES_USER `clever env | awk -F = '/POSTGRESQL_ADDON_USER/ { gsub(/"/, "", $2); print $2}'`
clever env set POSTGRES_PASSWORD `clever env | awk -F = '/POSTGRESQL_ADDON_PASSWORD/ { gsub(/"/, "", $2); print $2}'`
```

#### 4. Configure Khoj Application

```bash
# Set Khoj environment variables
clever env set KHOJ_DJANGO_SECRET_KEY <my_django_secret_key>
clever env set KHOJ_DEBUG True
clever env set KHOJ_DOMAIN <my_domain>
clever env set KHOJ_ADMIN_EMAIL <my_admin_email>
clever env set KHOJ_ADMIN_PASSWORD <my_admin_password>
```

#### 5. Configure AI Services

```bash
# Set OpenAI configuration
clever env set OPENAI_API_KEY <my_openai_api_key>

# Optionally set custom OpenAI base URL (required for Clever Cloud AI services)
# clever env set OPENAI_BASE_URL <my_openai_base_url>

# Other optional AI providers (uncomment as needed)
# clever env set ANTHROPIC_API_KEY <my_anthropic_api_key>
# clever env set GEMINI_API_KEY <my_gemini_api_key>

#### 6. Deploy

```bash
# Deploy the application
clever deploy
```

## Important Notes

- **Minimum Instance Requirements**: To run Khoj smoothly, ensure you deploy it in an instance with at least 2 vCPUs and 4GB of RAM (e.g., an M instance)

### Troubleshooting

If you encounter issues during deployment:

1. Check your application logs: `clever logs`
2. Verify your environment variables: `clever env`
3. Ensure your run.sh file has execute permissions: `git update-index --chmod=+x run.sh`
