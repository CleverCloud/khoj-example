# Deploy Khoj on Clever Cloud
[![Clever Cloud - PaaS](https://img.shields.io/badge/Clever%20Cloud-PaaS-orange)](https://clever-cloud.com)

This repository deploys a self-hosted [Khoj](https://khoj.dev) instance on Clever Cloud. Khoj is an AI-powered personal knowledge assistant – a "second brain" that provides chat and semantic search across your documents and the web, backed by the LLM provider of your choice.

The example runs Khoj (pinned to `khoj==1.42.10`) on the Clever Cloud **Python 3.12** runtime, stores its data in a **PostgreSQL** add-on (with the `pgvector` extension), and listens on `0.0.0.0:9000` behind the runtime's Nginx front (port 8080).

### Key features of Khoj

- **AI-powered chat**: talk to various LLMs (GPT, Claude, Gemini, Llama, Mistral, any OpenAI-compatible API) to get answers from your documents and the internet
- **Semantic search**: find relevant information quickly across your knowledge base
- **Multi-format support**: PDFs, Markdown, Word documents, Notion pages, org-mode files and plain text
- **Multiple interfaces**: web browser, desktop app, Obsidian plugin, Emacs package, WhatsApp
- **Custom agents**: specialized AI agents with their own knowledge bases, personas and tools
- **Privacy-focused**: self-hosted, so your personal data stays under your control
- **Research automation**: schedule automated research tasks and receive personalized newsletters

## How it works

- `requirements.txt` pins the `khoj` package from PyPI. During the build, Clever Cloud's Python runtime installs it with `pip`, along with its dependencies (Django, PyTorch, sentence-transformers…).
- `CC_RUN_COMMAND=./run.sh` tells Clever Cloud to start the app with `run.sh`, which launches the Khoj server on `0.0.0.0:9000` – the Python runtime runs Nginx on the public port 8080 and forwards requests to port 9000 – in anonymous mode (no login required) and non-interactive mode (no setup prompts).
- On first start, Khoj runs its Django migrations against the PostgreSQL add-on (enabling the `pgvector` extension) and creates the admin account from `KHOJ_ADMIN_EMAIL` / `KHOJ_ADMIN_PASSWORD`.
- Khoj reads the database connection from `POSTGRES_*` variables, which you copy from the `POSTGRESQL_ADDON_*` variables injected by the linked add-on.
- LLM providers are configured with environment variables (`OPENAI_API_KEY`, `OPENAI_BASE_URL`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`).

## Project structure

```
.
├── requirements.txt   # Pinned Khoj version, installed by pip at build time
├── run.sh             # Start script (CC_RUN_COMMAND): runs Khoj on 0.0.0.0:9000
├── assets/            # Image assets
├── CHANGELOG.md       # Maintenance history
└── .last-checked      # Date of the last maintenance check
```

## Prerequisites

- A [Clever Cloud](https://www.clever-cloud.com/) account
- [Clever Tools](https://github.com/CleverCloud/clever-tools) installed and logged in:

  ```bash
  npm install -g clever-tools
  clever login
  ```

- An API key for at least one LLM provider:
  - OpenAI: [get an API key](https://platform.openai.com/)
  - Anthropic: [get an API key](https://console.anthropic.com/)
  - Gemini: [get an API key](https://aistudio.google.com/)
  - Any OpenAI-compatible provider, such as Clever AI from Clever Cloud (API key and base URL)
- A domain name (optional, recommended for production use)

## Deployment steps

In the commands below, replace:

- `<my_app_name>` with your application name (e.g. `my-khoj`)
- `<my_postgresql_name>` with your database add-on name (e.g. `my-khoj-pg`)
- `<my_domain>` with your domain name, or the default `app-<id>.cleverapps.io` domain shown by `clever domain`

### 1. Create and configure the application

```bash
# Create a new Python application
clever create --type python --region par <my_app_name>

# Scale the application to the M flavor AT MINIMUM (Khoj needs ~4 GB of RAM)
clever scale --flavor M

# Add a domain (optional but recommended)
clever domain add <my_domain>
```

### 2. Set up the PostgreSQL database

Khoj needs the `pgvector` extension, so use a dedicated plan (not the shared `dev` plan):

```bash
# Create the PostgreSQL add-on
clever addon create postgresql-addon --plan xxs_sml --region par <my_postgresql_name>

# Link the PostgreSQL add-on to your application
clever service link-addon <my_postgresql_name>
```

### 3. Configure the platform environment

```bash
# Platform settings
clever env set CC_PYTHON_VERSION 3.12
clever env set CC_RUN_COMMAND ./run.sh
clever env set CC_TROUBLESHOOT true

# Database settings, copied from the PostgreSQL add-on variables
clever env set POSTGRES_DB `clever env | awk -F = '/POSTGRESQL_ADDON_DB/ { gsub(/"/, "", $2); print $2}'`
clever env set POSTGRES_HOST `clever env | awk -F = '/POSTGRESQL_ADDON_HOST/ { gsub(/"/, "", $2); print $2}'`
clever env set POSTGRES_PORT `clever env | awk -F = '/POSTGRESQL_ADDON_PORT/ { gsub(/"/, "", $2); print $2}'`
clever env set POSTGRES_USER `clever env | awk -F = '/POSTGRESQL_ADDON_USER/ { gsub(/"/, "", $2); print $2}'`
clever env set POSTGRES_PASSWORD `clever env | awk -F = '/POSTGRESQL_ADDON_PASSWORD/ { gsub(/"/, "", $2); print $2}'`
```

`CC_PYTHON_VERSION` must stay on 3.12: Khoj 1.x requires Python `>=3.10,<3.13`.

### 4. Configure Khoj

```bash
clever env set KHOJ_DJANGO_SECRET_KEY <my_django_secret_key>   # e.g. `openssl rand -hex 32`
clever env set KHOJ_DEBUG True
clever env set KHOJ_DOMAIN <my_domain>
clever env set KHOJ_ADMIN_EMAIL <my_admin_email>
clever env set KHOJ_ADMIN_PASSWORD <my_admin_password>
```

### 5. Configure AI services

```bash
# OpenAI (or any OpenAI-compatible provider)
clever env set OPENAI_API_KEY <my_openai_api_key>

# Custom OpenAI-compatible base URL (required for Clever AI and other providers)
# clever env set OPENAI_BASE_URL <my_openai_base_url>

# Other optional providers
# clever env set ANTHROPIC_API_KEY <my_anthropic_api_key>
# clever env set GEMINI_API_KEY <my_gemini_api_key>
```

### 6. Deploy

```bash
clever deploy
clever open
```

The first build takes several minutes: `pip` installs PyTorch (CPU-only build, see `requirements.txt`) and the other machine-learning dependencies of Khoj.

## Running locally

Khoj 1.x requires Python 3.10 to 3.12 and a PostgreSQL server with the `pgvector` extension.

```bash
python3.12 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt

export POSTGRES_HOST=localhost POSTGRES_PORT=5432 POSTGRES_DB=khoj POSTGRES_USER=postgres POSTGRES_PASSWORD=postgres
export KHOJ_DJANGO_SECRET_KEY=dev-secret KHOJ_DEBUG=True
export KHOJ_ADMIN_EMAIL=admin@example.com KHOJ_ADMIN_PASSWORD=admin
export OPENAI_API_KEY=<my_openai_api_key>

./run.sh
```

Then open <http://localhost:9000>.

## Troubleshooting

- **Check the logs**: `clever logs`
- **Check the environment variables**: `clever env`
- **The app is not reachable**: Khoj must listen on `0.0.0.0:9000` (Nginx listens on 8080 and forwards to it), which is what `run.sh` does; binding Khoj to 8080 fails with `address already in use`
- **`Permission denied` on `run.sh`**: make it executable with `git update-index --chmod=+x run.sh`
- **Out of memory / the instance restarts**: use at least an M instance (2 vCPUs, 4 GB of RAM)
- **`DisallowedHost` errors**: set `KHOJ_DOMAIN` to the domain you use to reach the app
- **Database errors about `vector`**: use a PostgreSQL plan that supports extensions (not `dev`)

## Contributing

Contributions are welcome: open an issue or a pull request on [GitHub](https://github.com/CleverCloud/khoj-example).

## License

Khoj itself is licensed under the [AGPL-3.0](https://github.com/khoj-ai/khoj/blob/master/LICENSE). This example repository does not ship a license file of its own yet.
