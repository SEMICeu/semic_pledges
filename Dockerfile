FROM alpine

# Create a new user 'pledges' with user ID 1001
RUN adduser -D -u 1001 pledges

# Copy files
COPY pledges /opt/pledges
COPY web/ /opt/web/

RUN touch /opt/.env

# Change ownership of the /opt directory to the new user
RUN chown -R pledges:pledges /opt

WORKDIR /opt

# Switch user
USER pledges

ENTRYPOINT ["/opt/pledges"]