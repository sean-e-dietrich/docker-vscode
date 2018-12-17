NAME = docksal/vscode
VERSION = $$(git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3)
APP_NAME = Containerized VSCode

.PHONY: all build tag_latest release app

all: build serve

build:
	docker build -t $(NAME):$(VERSION) --rm ./

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: build tag_latest app
	docker push $(NAME)

serve:
	docker run -d -p 5901:5901 -p 6901:6901 $(NAME):$(VERSION)
