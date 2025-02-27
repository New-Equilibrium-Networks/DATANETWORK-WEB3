.PHONY: generate
generate:
	$(GO) generate ./...

.PHONY: mocks
mocks: $(MOCKERY) modvendor
	$(MOCKERY) --case=underscore --dir vendor/github.com/cosmos/cosmos-sdk/x/bank/types --output testutil/cosmos_mock        --name QueryClient --outpkg cosmos_mocks --keeptree
	$(MOCKERY) --case=underscore --dir client/broadcaster                               --output client/broadcaster/mocks    --name Client
	$(MOCKERY) --case=underscore --dir client                                           --output client/mocks/               --name QueryClient
	$(MOCKERY) --case=underscore --dir client                                           --output client/mocks/               --name Client
	$(MOCKERY) --case=underscore --dir x/escrow/keeper                                  --output x/escrow/keeper/mocks       --name BankKeeper
	$(MOCKERY) --case=underscore --dir x/deployment/handler                             --output x/deployment/handler/mocks  --name AuthzKeeper

.PHONY: proto-gen
proto-gen: $(PROTOC) $(GRPC_GATEWAY) $(PROTOC_GEN_GOCOSMOS) modvendor
	./script/protocgen.sh

.PHONY: proto-swagger-gen
proto-swagger-gen: $(PROTOC) $(PROTOC_SWAGGER_GEN) $(SWAGGER_COMBINE) modvendor
	./script/protoc-swagger-gen.sh

.PHONY: update-swagger-docs
update-swagger-docs: $(STATIK) proto-swagger-gen
	$(STATIK) -src=client/docs/swagger-ui -dest=client/docs -f -m
	@if [ -n "$(git status --porcelain)" ]; then \
		echo "\033[91mSwagger docs are out of sync!!!\033[0m"; \
		exit 1; \
	else \
		echo "\033[92mSwagger docs are in sync\033[0m"; \
	fi

.PHONY: codegen
codegen: generate proto-gen update-swagger-docs mocks
