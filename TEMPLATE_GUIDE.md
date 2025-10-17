# Template Usage Guide

This directory contains an Evidence project template that can be used to create new Evidence dashboards.

## How to Use This Template

### Method 1: Direct Copy
```bash
# Copy the entire directory
cp -r my-project/ your-new-project/
cd your-new-project/

# Run the setup script
./setup-template.sh
```

### Method 2: Using gettemplate.sh (if available)
```bash
# If you have a gettemplate.sh script that downloads this template
./gettemplate.sh your-project-name
cd your-project-name/
./setup-template.sh
```

## What Gets Customized

The setup script will prompt you for:
- Project name
- Project version  
- Container name
- Port number

And will automatically:
- Create `.env` file from `.env.template`
- Update `package.json` with your project details
- Install npm dependencies
- Build the Evidence project

## After Setup

1. **Configure your data sources** in the `sources/` directory
2. **Customize your pages** in the `pages/` directory
3. **Update database connections** in `.env` file
4. **Run with Docker**: `docker-compose up`

## Template Files

- `.env.template` - Environment configuration template
- `setup-template.sh` - Automated setup script
- `docker-compose.yml` - Docker configuration with environment variables
- `package.json` - Uses template variables for project name/version
- `README.md` - Comprehensive usage instructions

## Important Notes

- The template excludes `package-lock.json` - users will generate their own
- All build artifacts are excluded from the template
- Environment files are excluded for security
- Users should customize the `sources/` directory for their data
