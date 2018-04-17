IMG     = glibc

VERSION = 2.27
SRC     = glibc-$(VERSION)-wml.tar.gz
SRC_URL = https://github.com/willmarkley/wml/releases/download/glibc-$(VERSION)/$(SRC)

BUILD_DIR = build
DOCKER    = /usr/bin/docker


all: build-docker

build-docker: Dockerfile $(BUILD_DIR)
	$(DOCKER) build -t $(IMG) .

$(BUILD_DIR): $(SRC)
	-rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -xzf $(SRC) -C $(BUILD_DIR)
	rm -rf $(BUILD_DIR)/dev
	rm -rf $(BUILD_DIR)/etc
	rm -rf $(BUILD_DIR)/proc
	rm -rf $(BUILD_DIR)/sys
	
$(SRC):
	wget -q $(SRC_URL)

deploy:
	$(DOCKER) tag $(IMG) willmarkley/$(IMG)
	@echo "$(DOCKER_PASSWORD)" | docker login -u "$(DOCKER_USERNAME)" --password-stdin
	$(DOCKER) push willmarkley/$(IMG)

clean:
	-rm -rf $(BUILD_DIR) build-docker setup $(SRC)
	-$(DOCKER) rmi $(IMG)
	-$(DOCKER) rmi willmarkley/$(IMG)
