# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Certbot
# Website: https://certbot.eff.org/
# Repository: https://github.com/certbot/certbot
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready Certbot for automatic SSL certificate management
# · DESIGN PHILOSOPHY: Self-contained with security configurations
# · COMBINATION: Use standalone for SSL certificate automation
# · SECURITY: Secure certificate storage, access control
# · BEST PRACTICES: Automatic renewal, certificate backup, monitoring
# · OFFICIAL SOURCES: Certbot documentation and Let's Encrypt guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Official Certbot with Alpine (smallest)
FROM certbot/certbot:v2.0

# Option 2: Certbot with specific version
# FROM certbot/certbot:v2.0-alpine

# Option 3: Specific version with SHA
# FROM certbot/certbot:v2.0@sha256:abc123...

# Option 4: Certbot with DNS plugins
# FROM certbot/dns-cloudflare:v2.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG CERTBOT_VERSION=v2.0
ARG CERTBOT_EMAIL=admin@example.com
ARG CERTBOT_STAGING=false
ARG CERTBOT_RSA_KEY_SIZE=4096

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV CERTBOT_VERSION=${CERTBOT_VERSION} \
  CERTBOT_EMAIL=${CERTBOT_EMAIL} \
  CERTBOT_STAGING=${CERTBOT_STAGING} \
  CERTBOT_RSA_KEY_SIZE=${CERTBOT_RSA_KEY_SIZE} \
  CERTBOT_CONFIG_DIR=/etc/letsencrypt \
  CERTBOT_WORK_DIR=/var/lib/letsencrypt \
  CERTBOT_LOGS_DIR=/var/log/letsencrypt \
  CERTBOT_WEBROOT_PATH=/var/www/certbot \
  CERTBOT_DEPLOY_HOOK=/etc/letsencrypt/renewal-hooks/deploy/00-reload-services.sh \
  TZ=UTC \
  LANG=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create non-root user for Certbot
RUN addgroup -g 1001 -S certbot && \
  adduser -S -u 1001 -G certbot certbot

# Create directories with proper permissions
RUN mkdir -p ${CERTBOT_CONFIG_DIR} ${CERTBOT_WORK_DIR} ${CERTBOT_LOGS_DIR} ${CERTBOT_WEBROOT_PATH} && \
  chown -R certbot:certbot ${CERTBOT_CONFIG_DIR} ${CERTBOT_WORK_DIR} ${CERTBOT_LOGS_DIR} ${CERTBOT_WEBROOT_PATH} && \
  chmod -R 750 ${CERTBOT_CONFIG_DIR} ${CERTBOT_WORK_DIR} ${CERTBOT_LOGS_DIR} && \
  chmod 755 ${CERTBOT_WEBROOT_PATH}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CERTBOT CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create Certbot configuration file
RUN echo "# Certbot Configuration" > ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "email = ${CERTBOT_EMAIL}" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "rsa-key-size = ${CERTBOT_RSA_KEY_SIZE}" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "agree-tos = true" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "authenticator = webroot" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "webroot-path = ${CERTBOT_WEBROOT_PATH}" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "deploy-hook = ${CERTBOT_DEPLOY_HOOK}" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "renew-hook = ${CERTBOT_DEPLOY_HOOK}" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "keep-until-expiring = true" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "preferred-challenges = http-01" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "key-type = rsa" >> ${CERTBOT_CONFIG_DIR}/cli.ini && \
  echo "server = https://acme-v02.api.letsencrypt.org/directory" >> ${CERTBOT_CONFIG_DIR}/cli.ini

# Configure staging server if requested
RUN if [ "${CERTBOT_STAGING}" = "true" ]; then \
  echo "server = https://acme-staging-v02.api.letsencrypt.org/directory" >> ${CERTBOT_CONFIG_DIR}/cli.ini; \
  fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RENEWAL HOOKS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create renewal hooks directory
RUN mkdir -p ${CERTBOT_CONFIG_DIR}/renewal-hooks/deploy ${CERTBOT_CONFIG_DIR}/renewal-hooks/post ${CERTBOT_CONFIG_DIR}/renewal-hooks/pre

# Create deploy hook script
RUN echo "#!/bin/sh" > ${CERTBOT_DEPLOY_HOOK} && \
  echo "# Deploy hook for Certbot renewal" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "# This script runs after certificate renewal" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "echo \"Certificate renewed for domains: \$RENEWED_DOMAINS\"" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "# Example: Reload Nginx" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "# if nginx -t; then" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "#   nginx -s reload" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "#   echo \"Nginx reloaded successfully\"" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "# else" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "#   echo \"Nginx configuration test failed\"" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "#   exit 1" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "# fi" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "# Example: Restart Docker containers" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "# docker restart nginx-proxy" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "" >> ${CERTBOT_DEPLOY_HOOK} && \
  echo "exit 0" >> ${CERTBOT_DEPLOY_HOOK}

# Set proper permissions for hook scripts
RUN chmod +x ${CERTBOT_DEPLOY_HOOK} && \
  chown -R certbot:certbot ${CERTBOT_CONFIG_DIR}/renewal-hooks

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BACKUP CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create backup directory
RUN mkdir -p /backup/letsencrypt && \
  chown -R certbot:certbot /backup/letsencrypt && \
  chmod 750 /backup/letsencrypt

# Create backup script
RUN echo "#!/bin/sh" > /usr/local/bin/backup-certificates.sh && \
  echo "# Backup Let's Encrypt certificates" >> /usr/local/bin/backup-certificates.sh && \
  echo "" >> /usr/local/bin/backup-certificates.sh && \
  echo "BACKUP_DIR=\"/backup/letsencrypt/backup-\$(date +%Y%m%d-%H%M%S)\"" >> /usr/local/bin/backup-certificates.sh && \
  echo "mkdir -p \${BACKUP_DIR}" >> /usr/local/bin/backup-certificates.sh && \
  echo "" >> /usr/local/bin/backup-certificates.sh && \
  echo "# Backup configuration" >> /usr/local/bin/backup-certificates.sh && \
  echo "cp -r ${CERTBOT_CONFIG_DIR}/* \${BACKUP_DIR}/" >> /usr/local/bin/backup-certificates.sh && \
  echo "" >> /usr/local/bin/backup-certificates.sh && \
  echo "# Create archive" >> /usr/local/bin/backup-certificates.sh && \
  echo "tar -czf \${BACKUP_DIR}.tar.gz -C /backup/letsencrypt \$(basename \${BACKUP_DIR})" >> /usr/local/bin/backup-certificates.sh && \
  echo "rm -rf \${BACKUP_DIR}" >> /usr/local/bin/backup-certificates.sh && \
  echo "" >> /usr/local/bin/backup-certificates.sh && \
  echo "echo \"Backup created: \${BACKUP_DIR}.tar.gz\"" >> /usr/local/bin/backup-certificates.sh && \
  echo "exit 0" >> /usr/local/bin/backup-certificates.sh

RUN chmod +x /usr/local/bin/backup-certificates.sh && \
  chown certbot:certbot /usr/local/bin/backup-certificates.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Declare persistent data volume
VOLUME /etc/letsencrypt

# Switch to non-root user
USER certbot

# Health check for container orchestration
HEALTHCHECK --interval=24h --timeout=30s --start-period=30s --retries=3 \
  CMD certbot certificates --config-dir ${CERTBOT_CONFIG_DIR} --work-dir ${CERTBOT_WORK_DIR} --logs-dir ${CERTBOT_LOGS_DIR} || exit 1

# Default command: show help
CMD ["certbot", "--help"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CRON CONFIGURATION FOR AUTOMATIC RENEWAL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install cron (optional - uncomment if needed)
# USER root
# RUN apk add --no-cache cron
#
# # Create cron job for automatic renewal
# RUN echo "0 0,12 * * * certbot renew --quiet --config-dir ${CERTBOT_CONFIG_DIR} --work-dir ${CERTBOT_WORK_DIR} --logs-dir ${CERTBOT_LOGS_DIR}" > /etc/crontabs/certbot
#
# # Set proper permissions for cron job
# RUN chown certbot:certbot /etc/crontabs/certbot && \
#   chmod 600 /etc/crontabs/certbot
#
# USER certbot
#
# # Alternative command for cron-based renewal
# # CMD ["crond", "-f", "-l", "2"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Obtain certificate for single domain
# docker run --rm \
#   -v certbot_config:/etc/letsencrypt \
#   -v certbot_webroot:/var/www/certbot \
#   certbot/certbot:v2.0 certonly \
#   --domain example.com \
#   --email admin@example.com \
#   --agree-tos \
#   --non-interactive

# Example 2: Obtain certificate for multiple domains
# docker run --rm \
#   -v certbot_config:/etc/letsencrypt \
#   -v certbot_webroot:/var/www/certbot \
#   certbot/certbot:v2.0 certonly \
#   --domain example.com \
#   --domain www.example.com \
#   --domain api.example.com \
#   --email admin@example.com \
#   --agree-tos \
#   --non-interactive

# Example 3: Test with staging server (no rate limits)
# docker run --rm \
#   -v certbot_config:/etc/letsencrypt \
#   -v certbot_webroot:/var/www/certbot \
#   certbot/certbot:v2.0 certonly \
#   --staging \
#   --domain example.com \
#   --email admin@example.com \
#   --agree-tos \
#   --non-interactive

# Example 4: Renew all certificates
# docker run --rm \
#   -v certbot_config:/etc/letsencrypt \
#   -v certbot_webroot:/var/www/certbot \
#   certbot/certbot:v2.0 renew \
#   --quiet

# Example 5: Run with Nginx companion (automatic configuration)
# docker run --rm \
#   -v nginx_conf:/etc/nginx/conf.d \
#   -v certbot_config:/etc/letsencrypt \
#   -v certbot_webroot:/var/www/certbot \
#   --volumes-from nginx-container \
#   certbot/certbot:v2.0 certonly \
#   --webroot \
#   --webroot-path /var/www/certbot \
#   --domain example.com \
#   --email admin@example.com \
#   --agree-tos \
#   --non-interactive

# Best Practices:
# 1. Always test with staging server first
# 2. Set up automatic renewal (cron job)
# 3. Backup certificates regularly
# 4. Monitor certificate expiration
# 5. Use strong RSA key sizes (4096 bits)
# 6. Set up proper deploy hooks for service reload
#
