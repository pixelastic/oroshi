FROM alpine:3.22

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apk add --no-cache openssh-server rsync

# Create mock user with host UID/GID and unlock the account
RUN addgroup -g ${GROUP_ID} mock && \
    adduser -D -u ${USER_ID} -G mock mock && \
    passwd -u mock

# Set up SSH key authentication
RUN mkdir -p /home/mock/.ssh && \
    chown mock:mock /home/mock/.ssh && \
    chmod 700 /home/mock/.ssh

COPY keys/id_mock.pub /home/mock/.ssh/authorized_keys
RUN chown mock:mock /home/mock/.ssh/authorized_keys && \
    chmod 600 /home/mock/.ssh/authorized_keys

# Stable host key (committed) and sshd config
COPY keys/host_mock /etc/ssh/ssh_host_ed25519_key
COPY keys/host_mock.pub /etc/ssh/ssh_host_ed25519_key.pub
RUN chmod 600 /etc/ssh/ssh_host_ed25519_key && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo 'HostKey /etc/ssh/ssh_host_ed25519_key' >> /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
