# NGINX reverse proxy with security headers
FROM nginx:1.27-alpine

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom config
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/

# Security: remove server tokens
RUN sed -i 's/worker_processes  1/worker_processes auto/' /etc/nginx/nginx.conf

# Create cache directory
RUN mkdir -p /var/cache/nginx && \
    chown -R nginx:nginx /var/cache/nginx

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget -q --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
