# Changelog

## [0.3.1](https://github.com/joshrotenberg/agent-tools/compare/v0.3.0...v0.3.1) (2026-06-03)


### Bug Fixes

* add Elixir and Java/Kotlin language coverage to skills (closes [#134](https://github.com/joshrotenberg/agent-tools/issues/134)) ([#135](https://github.com/joshrotenberg/agent-tools/issues/135)) ([0bd7b89](https://github.com/joshrotenberg/agent-tools/commit/0bd7b89303b2eff2bf731409fd04a41acdfa5bf1))
* skill preload audit -- add 3 missing, remove 1 obsolete (closes [#130](https://github.com/joshrotenberg/agent-tools/issues/130)) ([#131](https://github.com/joshrotenberg/agent-tools/issues/131)) ([0dd15ec](https://github.com/joshrotenberg/agent-tools/commit/0dd15ecfbbce97c1b28743dfcd9386f59d2b40ee))

## [0.3.0](https://github.com/joshrotenberg/agent-tools/compare/v0.2.0...v0.3.0) (2026-06-02)


### Features

* add agent-feedback skill (closes [#15](https://github.com/joshrotenberg/agent-tools/issues/15)) ([#16](https://github.com/joshrotenberg/agent-tools/issues/16)) ([ce25c67](https://github.com/joshrotenberg/agent-tools/commit/ce25c67f6a11b61d5a1d411b4fa33e710a073f4a))
* add AGENTS.md (closes [#6](https://github.com/joshrotenberg/agent-tools/issues/6)) ([#12](https://github.com/joshrotenberg/agent-tools/issues/12)) ([0f658b9](https://github.com/joshrotenberg/agent-tools/commit/0f658b9e7dbfc8f1fdd9ab6a155e2be59ba3a07e))
* add allowed-tools frontmatter and dynamic context injection examples (closes [#36](https://github.com/joshrotenberg/agent-tools/issues/36)) ([#76](https://github.com/joshrotenberg/agent-tools/issues/76)) ([72b70c7](https://github.com/joshrotenberg/agent-tools/commit/72b70c7293744a90b372470223c98611490c2f02))
* add allowed-tools frontmatter to draft-pr-first, git-branch-pr-workflow, sandbox-preflight; add dynamic context injection note to runner-issue-authority ([#82](https://github.com/joshrotenberg/agent-tools/issues/82)) ([9a4998e](https://github.com/joshrotenberg/agent-tools/commit/9a4998e56a44d25a3be6187549c9daeca2c07494))
* add durable-context skill (closes [#74](https://github.com/joshrotenberg/agent-tools/issues/74)) ([#80](https://github.com/joshrotenberg/agent-tools/issues/80)) ([040f05d](https://github.com/joshrotenberg/agent-tools/commit/040f05dbc3d3accef0de87f31e3d6e3f6fd2cbca))
* add field-feedback skill for dispatch-time issue reporting (closes [#32](https://github.com/joshrotenberg/agent-tools/issues/32)) ([#42](https://github.com/joshrotenberg/agent-tools/issues/42)) ([da46c9f](https://github.com/joshrotenberg/agent-tools/commit/da46c9fea7ecd22c26b605de822137eb0488b332))
* add non-pr-output-conventions skill and update dispatcher/orchestration-patterns (closes [#28](https://github.com/joshrotenberg/agent-tools/issues/28)) ([#67](https://github.com/joshrotenberg/agent-tools/issues/67)) ([c31ef0f](https://github.com/joshrotenberg/agent-tools/commit/c31ef0fe09b02dc37669e59e4f885c67794228ed))
* add reviewer agent and pr-review skill (closes [#38](https://github.com/joshrotenberg/agent-tools/issues/38)) ([#39](https://github.com/joshrotenberg/agent-tools/issues/39)) ([4e370de](https://github.com/joshrotenberg/agent-tools/commit/4e370de9945ed0ba07e372f3387637f6769ddf92))
* add triage skill and dispatcher integration (closes [#43](https://github.com/joshrotenberg/agent-tools/issues/43)) ([#51](https://github.com/joshrotenberg/agent-tools/issues/51)) ([4bbd4a1](https://github.com/joshrotenberg/agent-tools/commit/4bbd4a11795b262a63794bb620b57d97cd438bf8))
* add versioned releases with release-please and install artifacts (closes [#59](https://github.com/joshrotenberg/agent-tools/issues/59)) ([#66](https://github.com/joshrotenberg/agent-tools/issues/66)) ([0a16011](https://github.com/joshrotenberg/agent-tools/commit/0a160114f1d93e457441da1a00b46a07991dcc75))
* add worker agent for direct code-change tasks (closes [#40](https://github.com/joshrotenberg/agent-tools/issues/40)) ([#45](https://github.com/joshrotenberg/agent-tools/issues/45)) ([78d0acb](https://github.com/joshrotenberg/agent-tools/commit/78d0acbb33c8ae381e8040df79f0f8f73e6659d1))
* add workflow-basics skill (closes [#72](https://github.com/joshrotenberg/agent-tools/issues/72)) ([#92](https://github.com/joshrotenberg/agent-tools/issues/92)) ([d42ed58](https://github.com/joshrotenberg/agent-tools/commit/d42ed588334b5aedd7d12a5fbdc5132be47d625b))
* apply and document PR labels for size, blocked, and no-auto-merge (closes [#54](https://github.com/joshrotenberg/agent-tools/issues/54)) ([#60](https://github.com/joshrotenberg/agent-tools/issues/60)) ([349678c](https://github.com/joshrotenberg/agent-tools/commit/349678c03f141f447177328796ef30411e0be8b0))
* default to auto-merge on CI pass in runner lifecycle (closes [#17](https://github.com/joshrotenberg/agent-tools/issues/17)) ([#26](https://github.com/joshrotenberg/agent-tools/issues/26)) ([9f7a4f2](https://github.com/joshrotenberg/agent-tools/commit/9f7a4f2256af7343886f371d4c5ba9232b3e6a6e))
* default to worktree-isolated dispatch for same-repo work (closes [#22](https://github.com/joshrotenberg/agent-tools/issues/22)) ([#27](https://github.com/joshrotenberg/agent-tools/issues/27)) ([0f83acb](https://github.com/joshrotenberg/agent-tools/commit/0f83acbddbcd56278f168ccb69fee79b095b6421))
* dispatcher sets model and effort on dispatches based on issue labels (closes [#93](https://github.com/joshrotenberg/agent-tools/issues/93)) ([#98](https://github.com/joshrotenberg/agent-tools/issues/98)) ([579f915](https://github.com/joshrotenberg/agent-tools/commit/579f915308d9ac66367fdd92d57f110ea4fe8235))
* document Monitor tool in dispatch-wait-react skill (closes [#34](https://github.com/joshrotenberg/agent-tools/issues/34)) ([#41](https://github.com/joshrotenberg/agent-tools/issues/41)) ([e0752f8](https://github.com/joshrotenberg/agent-tools/commit/e0752f8abc1095fc7fe482de5469ab8fb4101377))
* document workspace-level CLAUDE.md gap in workspace-survey skill (closes [#29](https://github.com/joshrotenberg/agent-tools/issues/29)) ([#62](https://github.com/joshrotenberg/agent-tools/issues/62)) ([afd6d4c](https://github.com/joshrotenberg/agent-tools/commit/afd6d4cbf9bff48caf0be8fb4a7f3cce7b168d2c))


### Bug Fixes

* add bump-minor-pre-major flags to release-please (closes [#105](https://github.com/joshrotenberg/agent-tools/issues/105)) ([#107](https://github.com/joshrotenberg/agent-tools/issues/107)) ([12b8d7f](https://github.com/joshrotenberg/agent-tools/commit/12b8d7f4eef1b7f3c247d7bc217a7d21fd1ad868))
* audit skill descriptions for trigger-condition compliance (closes [#8](https://github.com/joshrotenberg/agent-tools/issues/8)) ([#19](https://github.com/joshrotenberg/agent-tools/issues/19)) ([f3656ad](https://github.com/joshrotenberg/agent-tools/commit/f3656adeca0b1cbd9ae7f7d4a48ff5fc31b40d71))
* document required dispatcher permissions in runner AGENT.md (closes [#5](https://github.com/joshrotenberg/agent-tools/issues/5)) ([#23](https://github.com/joshrotenberg/agent-tools/issues/23)) ([3251db5](https://github.com/joshrotenberg/agent-tools/commit/3251db54b29bfca45a086b57368165513814724a))
* enforce conventional commit style on issue titles (closes [#53](https://github.com/joshrotenberg/agent-tools/issues/53)) ([#64](https://github.com/joshrotenberg/agent-tools/issues/64)) ([95153a7](https://github.com/joshrotenberg/agent-tools/commit/95153a76ce62e720b80465201c16202e14615e9b))
* fall back to line-count estimates when API unavailable (quota/model access) ([#103](https://github.com/joshrotenberg/agent-tools/issues/103)) ([eb66afd](https://github.com/joshrotenberg/agent-tools/commit/eb66afd3afca5e32b38e023b0d1c7ae095fa990b))
* generalize dispatch-agnostic language across skills (closes [#1](https://github.com/joshrotenberg/agent-tools/issues/1)) ([#3](https://github.com/joshrotenberg/agent-tools/issues/3)) ([eaf7b81](https://github.com/joshrotenberg/agent-tools/commit/eaf7b81de1f274be1cea2d60538dfbb391b13ade))
* improve agent metadata for auto-delegation and model routing (closes [#7](https://github.com/joshrotenberg/agent-tools/issues/7)) ([#24](https://github.com/joshrotenberg/agent-tools/issues/24)) ([044c8f5](https://github.com/joshrotenberg/agent-tools/commit/044c8f5a47c856e6cc2262a5195dc07b3333f201))
* lift claude-server-worker discipline into runner agent (closes [#18](https://github.com/joshrotenberg/agent-tools/issues/18)) ([#25](https://github.com/joshrotenberg/agent-tools/issues/25)) ([575c9bd](https://github.com/joshrotenberg/agent-tools/commit/575c9bd8f58aaff3664aac79d6537bc1e324f98a))
* re-invoke key skills after /compact in dispatcher step 1 (closes [#81](https://github.com/joshrotenberg/agent-tools/issues/81)) ([#88](https://github.com/joshrotenberg/agent-tools/issues/88)) ([d68d941](https://github.com/joshrotenberg/agent-tools/commit/d68d9418d926018937b33720fc29bbdfcc186eeb))
* remove invalid release-please v4 params (closes [#116](https://github.com/joshrotenberg/agent-tools/issues/116)) ([#118](https://github.com/joshrotenberg/agent-tools/issues/118)) ([fd1e2c1](https://github.com/joshrotenberg/agent-tools/commit/fd1e2c132bc384583afde329b866a4309d865191))
* remove live !command syntax from runner-issue-authority -- breaks preloaded runner dispatches ([#84](https://github.com/joshrotenberg/agent-tools/issues/84)) ([98add0c](https://github.com/joshrotenberg/agent-tools/commit/98add0c65287b298103a8525aa07f46aa2ee6be5))
* remove roba as named dispatch option; Claude built-ins cover all use cases (closes [#49](https://github.com/joshrotenberg/agent-tools/issues/49)) ([#52](https://github.com/joshrotenberg/agent-tools/issues/52)) ([412834e](https://github.com/joshrotenberg/agent-tools/commit/412834ed3225e9f485bad66b5982aac346032f4c))
* remove work-type shape skill references from runner (closes [#2](https://github.com/joshrotenberg/agent-tools/issues/2)) ([#4](https://github.com/joshrotenberg/agent-tools/issues/4)) ([c729385](https://github.com/joshrotenberg/agent-tools/commit/c729385529b7a952bb2fca03d1e1630a711f8c69))
* scope markdownlint to skills/ and agents/ only; use markdownlint-cli2.yaml config ([#120](https://github.com/joshrotenberg/agent-tools/issues/120)) ([f5cf522](https://github.com/joshrotenberg/agent-tools/commit/f5cf522dc750297725569ef67364d416cbbc9a2a))
* show actual API error body when count_tokens call fails ([#99](https://github.com/joshrotenberg/agent-tools/issues/99)) ([0a3f662](https://github.com/joshrotenberg/agent-tools/commit/0a3f662dddf2ea5c389c71c4e240080a01715478))
* suppress repeated API fallback warnings (show once then silent) ([#104](https://github.com/joshrotenberg/agent-tools/issues/104)) ([a3187c3](https://github.com/joshrotenberg/agent-tools/commit/a3187c3f1ce91f6a47c05fa983072d68b2e070dd))
* try sonnet model + add token-counting beta header ([#102](https://github.com/joshrotenberg/agent-tools/issues/102)) ([c0ab3e7](https://github.com/joshrotenberg/agent-tools/commit/c0ab3e732566b6fb3540c65278af8d9cc28edde8))
* use claude-3-haiku-20240307 for token counting -- 3-5-haiku not available on all plans ([#101](https://github.com/joshrotenberg/agent-tools/issues/101)) ([14e851e](https://github.com/joshrotenberg/agent-tools/commit/14e851e3cafc1c86bc20db9e321612316366e6d4))
* worker should ask about CLAUDE.md update before committing (closes [#75](https://github.com/joshrotenberg/agent-tools/issues/75)) ([#79](https://github.com/joshrotenberg/agent-tools/issues/79)) ([2125704](https://github.com/joshrotenberg/agent-tools/commit/2125704d84356b6010a98bcbcf293fb84a41e47a))


### Performance Improvements

* reduce runner/dispatcher startup context load (closes [#48](https://github.com/joshrotenberg/agent-tools/issues/48)) ([#63](https://github.com/joshrotenberg/agent-tools/issues/63)) ([6105b32](https://github.com/joshrotenberg/agent-tools/commit/6105b32f9e15d99fb87454de106590a5a66bf143))

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
