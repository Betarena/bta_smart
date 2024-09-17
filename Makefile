include .env

# ╭──────────────────────────────────────────────────────────────────────────────────╮
# │ ⛑️ │ HARDHAT   							  																   								 │
# ╰──────────────────────────────────────────────────────────────────────────────────╯

.ONESHELL:
hardhat-contract-compile:
	@
	# ╭──────────────────────────────────────────────────────────────────╮
	# │ NOTE: │ DESCRIPTION																						   │
	# │ > custom hardhat compile.																			   │
	# ╰──────────────────────────────────────────────────────────────────╯

	echo -e \
		"\
		\n╭──────────────────────────────────────────────────────────────────╮\
		\n│ ⚙️ Compile contract(s)                                            │\
		\n╰──────────────────────────────────────────────────────────────────╯"
	#

	npx hardhat \
		compile \
		--force
#

.ONESHELL:
hardhat-contract-flatten:
	@
	# ╭──────────────────────────────────────────────────────────────────╮
	# │ NOTE: │ DESCRIPTION																						   │
	# │ > custom hardhat flatten.																			   │
	# ╰──────────────────────────────────────────────────────────────────╯

	npx hardhat \
		flatten contracts/BetarenaBank.sol > flattened.sol
#

hardhat-contract-test:
	@echo ""
	# ▓ DESCRIPTION
	# ▓ > custom hardhat run test(s).
	@echo ""

	@npx hardhat test \
		test/BetarenaBank.test.ts
#

.ONESHELL:
hardhat-contract-deploy:
	@
	# ╭──────────────────────────────────────────────────────────────────╮
	# │ NOTE: │ DESCRIPTION																						   │
	# │ > custom hardhat deployment -> localhost.                        │
	# │ > 🔗 read-more :|: https://github.com/nvm-sh/nvm							   │
	# ╰──────────────────────────────────────────────────────────────────╯

	echo -e \
		"\
		\n╭──────────────────────────────────────────────────────────────────╮\
		\n│ 🟢 Deploy contract                                               │\
		\n│ $(ENV_CONTRACT_TARGET) \
		\n│ $(ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET) \
		\n╰──────────────────────────────────────────────────────────────────╯"
	#

	dot_clean .

	npx hardhat run \
		scripts/$(ENV_CONTRACT_TARGET) \
		--network $(ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET) \
		--show-stack-traces
	#
#

.ONESHELL:
hardhat-contract-verify-public-chain:
	@
	# ╭──────────────────────────────────────────────────────────────────╮
	# │ NOTE: │ DESCRIPTION																						   │
	# │ > custom hardhat deployment -> localhost.                        │
	# │ > 🔗 read-more :|: https://github.com/nvm-sh/nvm							   │
	# ╰──────────────────────────────────────────────────────────────────╯

	if [ ! $(address) ]; then\
		echo "Please supply a target contract ERC-20 address via address=(..)";\
		exit 1;\
		echo "";\
	fi

	echo -e \
		"\
		\n╭──────────────────────────────────────────────────────────────────╮\
		\n│ 🔍 Verify contract                                               │\
		\n│ $(address) \
		\n│ $(ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET) \
		\n╰──────────────────────────────────────────────────────────────────╯"
	#

	npx hardhat verify \
		"$(address)" \
		--network $(ENV_NETWORK_HARDHAT_DEPLOYMENT_TARGET) \
		--show-stack-traces
	#
#

.ONESHELL:
hardhat-node-initialize:
	@
	# ╭──────────────────────────────────────────────────────────────────╮
	# │ NOTE: │ DESCRIPTION																						   │
	# │ > custom hardhat deployment -> localhost.								         │
	# ╰──────────────────────────────────────────────────────────────────╯

	@npx hardhat@ node \
		--show-stack-traces
#

.ONESHELL:
hardhat-task-accounts:
	@
	# ╭──────────────────────────────────────────────────────────────────╮
	# │ NOTE: │ DESCRIPTION																						   │
	# │ > custom hardhat task.  																			   │
	# ╰──────────────────────────────────────────────────────────────────╯

	if [ ! $(address) ]; then\
		echo "Please supply a target contract ERC-20 address via address=(..)";\
		exit 1;\
		echo "";\
	fi

	_TEMP_ADDRESS=$(address) npx hardhat accounts
#

# ╭──────────────────────────────────────────────────────────────────────────────────╮
# │ 💠 │ HARDHAT (PLUGIN) ETHERNAL  															   								 │
# ╰──────────────────────────────────────────────────────────────────────────────────╯

.ONESHELL:
ethernal-contract-verify:
	@
	# ╭──────────────────────────────────────────────────────────────────╮
	# │ NOTE: │ DESCRIPTION																						   │
	# │ > does not appear to work, getting wierd error.				           │
	# │ > 🔗 read-more :|: https://github.com/tryethernal/ethernal-cli   │
	# ╰──────────────────────────────────────────────────────────────────╯

	npx ethernal verify \
		--name="BitarenaToken" \
		--address=$(shell tail -n 1 ./logs/contract-address-deploy.log | grep -e "[^|-|]*$$" -o) \
		--path="contracts/BitarenaToken.sol" \
		--slug="ethernal" \
		--compiler="0.8.24+commit.e11b9ed9" \
		--optimizer=true
	#
#
