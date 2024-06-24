#!/usr/bin/make -f

NETWORK = local

FOUNDER = $(shell dfx identity get-principal)

.PHONY: all
all: deploy init

.PHONY: deploy
deploy:
	dfx deploy -vv

.PHONY: fabricate-cycles
	dfx ledger fabricate-cycles --amount 1000000000 --canister main

.PHONY: init
init: fabricate-cycles init-main init-battery init-CanDBIndex init-NacDBIndex init-items init-call init-createItemData

.PHONY: init-main
init-main:
	dfx canister --network $(NETWORK) call main init '()'

#	. ./.env && dfx canister call --network $(NETWORK) payments init "(vec { principal \"$(FOUNDER)\"; principal \"$$CANISTER_ID_MAIN\" })"

.PHONY: init-CanDBIndex
init-CanDBIndex:
	. ./.env && dfx canister call --network $(NETWORK) CanDBIndex init "(vec { principal \"$(FOUNDER)\"; principal \"$$CANISTER_ID_MAIN\"; principal \"$$CANISTER_ID_BATTERY\"; principal \"$$CANISTER_ID_ITEMS\"; principal \"$$CANISTER_ID_PERSONHOOD\" })"

.PHONY: init-NacDBIndex
init-NacDBIndex:
	. ./.env && dfx canister call --network $(NETWORK) NacDBIndex init "(vec { principal \"$(FOUNDER)\"; principal \"$$CANISTER_ID_MAIN\"; principal \"$$CANISTER_ID_BATTERY\"; principal \"$$CANISTER_ID_ITEMS\" })"

.PHONY: init-items
init-items:
	. ./.env && dfx canister call --network $(NETWORK) items init "(vec { principal \"$(FOUNDER)\"; principal \"$$CANISTER_ID_MAIN\"; })"

.PHONY: init-users
init-users:
	. ./.env && dfx canister call --network $(NETWORK) users init "(vec { principal \"$(FOUNDER)\"; principal \"$$CANISTER_ID_MAIN\"; })"

.PHONY: init-call
init-call:
	. ./.env && dfx canister call --network $(NETWORK) call init "(vec { principal \"$(FOUNDER)\"; principal \"$$CANISTER_ID_MAIN\"; principal \"$$CANISTER_ID_ITEMS\"; })"

.PHONY: init-battery
init-battery:
	. ./.env && dfx canister call --network $(NETWORK) battery init "(vec { principal \"$(FOUNDER)\"; })"

.PHONY: init-createItemData
init-createItemData:
	mainItem=`dfx canister call --network $(NETWORK) items createItemData \
	  'record { data = record{price = 0.0; locale = "en"; title = "The homepage"; description = ""; details = variant { folder = null }}; communal = true }'`; \
	  dfx canister call --network $(NETWORK) main setRootItem "$$mainItem"
