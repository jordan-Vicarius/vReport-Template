# Evidence Project Template

This is a template Evidence project that can be easily customized for your specific use case. It includes Docker support, environment configuration, and example data sources.

## Quick Start

### Option 1: Automated Setup (Recommended)

Run the setup script to automatically configure your project:

```bash
./setup-template.sh
```

This script will:
- Create a `.env` file from the template
- Prompt you for project-specific settings
- Install dependencies
- Build the project

### Option 2: Manual Setup

1. **Configure Environment**
   ```bash
   cp .env.template .env
   # Edit .env with your project settings
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Configure Data Sources**
   - Edit `sources/` directory with your data connections
   - Update `evidence.config.yaml` if needed

4. **Build and Run**
   ```bash
   npm run build
   docker-compose up
   ```

## Configuration

### Environment Variables

The `.env.template` file contains all configurable options:

- **Project Settings**: Name, version, container name
- **Port Configuration**: Evidence and nginx ports
- **Database Configuration**: Support for multiple database types

### Supported Databases

- SQLite (default)
- PostgreSQL
- MySQL
- SQL Server
- Snowflake
- BigQuery
- And more...

### Docker Support

The project includes both production and development Docker configurations:

#### Production (Recommended)
```bash
# Build and run with Docker (production mode)
docker-compose up --build

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f
```

#### Development (Volume Mounts)
```bash
# For development with live updates (requires build directory)
npm run build
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Rebuild Evidence when you make changes
npm run build
# Container will automatically serve updated files
```

#### Production Best Practices
- **Immutable deployments**: Build files are copied into the image
- **Security**: Runs as non-root user
- **Resource limits**: Memory limits configured
- **Health checks**: Built-in health monitoring
- **Logging**: Structured logging to mounted volume

## Project Structure

```
├── pages/                 # Evidence pages (markdown files)
├── sources/              # Data source configurations
├── build/                # Built static files
├── docker-compose.yml    # Docker configuration
├── Dockerfile           # Docker build instructions
├── nginx.conf           # Nginx configuration
├── .env.template        # Environment template
├── setup-template.sh    # Setup automation script
└── evidence.config.yaml # Evidence configuration
```

## Customization

### Adding Data Sources

1. Add your data source configuration to `sources/`
2. Update `evidence.config.yaml` if needed
3. Rebuild the project: `npm run build`

### Creating Pages

Add markdown files to the `pages/` directory. See [Evidence documentation](https://docs.evidence.dev/) for page creation guidance.

### Styling

Customize the appearance in `evidence.config.yaml` or add custom CSS.

## Development

### Local Development

```bash
npm run dev
```

### Building for Production

```bash
npm run build
```

### Testing

```bash
npm test
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Update `EVIDENCE_PORT` in `.env`
2. **Database connection**: Check your database configuration in `.env`
3. **Build errors**: Ensure all dependencies are installed with `npm install`

### Getting Help

- [Evidence Documentation](https://docs.evidence.dev/)
- [Evidence GitHub](https://github.com/evidence-dev/evidence)
- [Evidence Slack Community](https://slack.evidence.dev/)

## License

This template follows the same license as Evidence. See the [Evidence repository](https://github.com/evidence-dev/evidence) for details.
