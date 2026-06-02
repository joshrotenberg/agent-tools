# Changelog

## [0.2.0](https://github.com/joshrotenberg/agent-tools/compare/v0.1.0...v0.2.0) (2026-06-02)


### Features

* add allowed-tools frontmatter and dynamic context injection examples (closes [#36](https://github.com/joshrotenberg/agent-tools/issues/36)) ([#76](https://github.com/joshrotenberg/agent-tools/issues/76)) ([72b70c7](https://github.com/joshrotenberg/agent-tools/commit/72b70c7293744a90b372470223c98611490c2f02))
* add allowed-tools frontmatter to draft-pr-first, git-branch-pr-workflow, sandbox-preflight; add dynamic context injection note to runner-issue-authority ([#82](https://github.com/joshrotenberg/agent-tools/issues/82)) ([9a4998e](https://github.com/joshrotenberg/agent-tools/commit/9a4998e56a44d25a3be6187549c9daeca2c07494))
* add durable-context skill (closes [#74](https://github.com/joshrotenberg/agent-tools/issues/74)) ([#80](https://github.com/joshrotenberg/agent-tools/issues/80)) ([040f05d](https://github.com/joshrotenberg/agent-tools/commit/040f05dbc3d3accef0de87f31e3d6e3f6fd2cbca))
* add non-pr-output-conventions skill and update dispatcher/orchestration-patterns (closes [#28](https://github.com/joshrotenberg/agent-tools/issues/28)) ([#67](https://github.com/joshrotenberg/agent-tools/issues/67)) ([c31ef0f](https://github.com/joshrotenberg/agent-tools/commit/c31ef0fe09b02dc37669e59e4f885c67794228ed))
* add workflow-basics skill (closes [#72](https://github.com/joshrotenberg/agent-tools/issues/72)) ([#92](https://github.com/joshrotenberg/agent-tools/issues/92)) ([d42ed58](https://github.com/joshrotenberg/agent-tools/commit/d42ed588334b5aedd7d12a5fbdc5132be47d625b))
* dispatcher sets model and effort on dispatches based on issue labels (closes [#93](https://github.com/joshrotenberg/agent-tools/issues/93)) ([#98](https://github.com/joshrotenberg/agent-tools/issues/98)) ([579f915](https://github.com/joshrotenberg/agent-tools/commit/579f915308d9ac66367fdd92d57f110ea4fe8235))


### Bug Fixes

* add bump-minor-pre-major flags to release-please (closes [#105](https://github.com/joshrotenberg/agent-tools/issues/105)) ([#107](https://github.com/joshrotenberg/agent-tools/issues/107)) ([12b8d7f](https://github.com/joshrotenberg/agent-tools/commit/12b8d7f4eef1b7f3c247d7bc217a7d21fd1ad868))
* fall back to line-count estimates when API unavailable (quota/model access) ([#103](https://github.com/joshrotenberg/agent-tools/issues/103)) ([eb66afd](https://github.com/joshrotenberg/agent-tools/commit/eb66afd3afca5e32b38e023b0d1c7ae095fa990b))
* re-invoke key skills after /compact in dispatcher step 1 (closes [#81](https://github.com/joshrotenberg/agent-tools/issues/81)) ([#88](https://github.com/joshrotenberg/agent-tools/issues/88)) ([d68d941](https://github.com/joshrotenberg/agent-tools/commit/d68d9418d926018937b33720fc29bbdfcc186eeb))
* remove invalid release-please v4 params (closes [#116](https://github.com/joshrotenberg/agent-tools/issues/116)) ([#118](https://github.com/joshrotenberg/agent-tools/issues/118)) ([fd1e2c1](https://github.com/joshrotenberg/agent-tools/commit/fd1e2c132bc384583afde329b866a4309d865191))
* remove live !command syntax from runner-issue-authority -- breaks preloaded runner dispatches ([#84](https://github.com/joshrotenberg/agent-tools/issues/84)) ([98add0c](https://github.com/joshrotenberg/agent-tools/commit/98add0c65287b298103a8525aa07f46aa2ee6be5))
* show actual API error body when count_tokens call fails ([#99](https://github.com/joshrotenberg/agent-tools/issues/99)) ([0a3f662](https://github.com/joshrotenberg/agent-tools/commit/0a3f662dddf2ea5c389c71c4e240080a01715478))
* suppress repeated API fallback warnings (show once then silent) ([#104](https://github.com/joshrotenberg/agent-tools/issues/104)) ([a3187c3](https://github.com/joshrotenberg/agent-tools/commit/a3187c3f1ce91f6a47c05fa983072d68b2e070dd))
* try sonnet model + add token-counting beta header ([#102](https://github.com/joshrotenberg/agent-tools/issues/102)) ([c0ab3e7](https://github.com/joshrotenberg/agent-tools/commit/c0ab3e732566b6fb3540c65278af8d9cc28edde8))
* use claude-3-haiku-20240307 for token counting -- 3-5-haiku not available on all plans ([#101](https://github.com/joshrotenberg/agent-tools/issues/101)) ([14e851e](https://github.com/joshrotenberg/agent-tools/commit/14e851e3cafc1c86bc20db9e321612316366e6d4))
* worker should ask about CLAUDE.md update before committing (closes [#75](https://github.com/joshrotenberg/agent-tools/issues/75)) ([#79](https://github.com/joshrotenberg/agent-tools/issues/79)) ([2125704](https://github.com/joshrotenberg/agent-tools/commit/2125704d84356b6010a98bcbcf293fb84a41e47a))
