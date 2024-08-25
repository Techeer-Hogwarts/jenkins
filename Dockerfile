# 젠킨스 이미지
FROM jenkins/jenkins:latest

# 유저 루트 (권한 이슈)
USER root

# 도커 관련 라이브러리 설치
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    && wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz \
    && rm go1.23.0.linux-amd64.tar.gz \
    nodejs \
    npm

ENV PATH="/usr/local/go/bin:${PATH}"

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.60.1

# 도커 gpg key 저장소
RUN mkdir -p /etc/apt/keyrings

# 도커 gpg key 다운로드
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 도커 저장소 등록
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 도커 & 컴포즈 설치
RUN apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

RUN usermod -aG docker jenkins && \
    usermod -aG users jenkins

# 루트 권한 회수
USER jenkins
