BSB  = docker-compose run --rm bsb
YARN = $(BSB) yarn
SLS  = docker-compose run --rm serverless

depsMacOS.zip:
	@yarn install --modules-folder depsCache/node_modules
	@cd depsCache && zip -rq ../depsMacOS.zip node_modules

depsLinux.zip:
	@$(YARN) install --modules-folder depsCache/node_modules
	@cd depsCache && zip -rq ../depsLinux.zip node_modules

prepareDepsCache: cleanDeps
	@mkdir -p depsCache/node_modules
	@make depsMacOS.zip
	@rm -rf depsCache/node_modules/*
	@make depsLinux.zip
	@rm -rf depsCache

switchDepsMac:
	@rm -rf node_modules
	@unzip -q depsMacOS.zip -d .

switchDepsLinux:
	@rm -rf node_modules
	@unzip -q depsLinux.zip -d .

yarn.lock:
	@$(YARN) install

deps: yarn.lock

cleanDeps:
	@rm -rf node_modules
	@rm -f yarn.lock depsLinux.zip depsMacOS.zip

cleanJSOutputs:
	@find src -iname "*.js" -exec rm {} \;

cleanEverything: cleanJSOutputs cleanDeps

build: switchDepsLinux
	@$(YARN) build

watch: switchDepsMac
	@yarn start

shell:
	@$(BSB) ash

dist: switchDepsLinux
	@$(BSB) make _dist

_build:
	./node_modules/bs-platform/lib/bsb.exe -make-world

_dist: _build
	@rm -fr dist dist.zip
	@mkdir -p dist/src
	@cp package.json dist
	@find src -iname "*.js" -exec cp {} dist/src \;
	@cd dist && yarn install --production --no-bin-links && \
	parcel build src/Identity.js
	@cd dist/dist && zip -rq ../../dist.zip .
	@rm -rf dist

deploy:
	@rm -rf .serverless
	@$(SLS) deploy -v

deleteStack:
	@$(SLS) remove -v
