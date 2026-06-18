# Changelog

## [0.4.0](https://github.com/joshrotenberg/agent-tools/compare/v0.3.2...v0.4.0) (2026-06-18)


### Features

* add audit-remediate-handoff skill (closes [#159](https://github.com/joshrotenberg/agent-tools/issues/159)) ([#176](https://github.com/joshrotenberg/agent-tools/issues/176)) ([6b31e5b](https://github.com/joshrotenberg/agent-tools/commit/6b31e5b8c5b0e460d353f0430ddc7a13b0031147))
* add auditor agent type (closes [#149](https://github.com/joshrotenberg/agent-tools/issues/149)) ([#150](https://github.com/joshrotenberg/agent-tools/issues/150)) ([06ed23e](https://github.com/joshrotenberg/agent-tools/commit/06ed23e88ad4acddd72682ba2cd74142d9a6dc9e))
* add install-cadence skill (closes [#160](https://github.com/joshrotenberg/agent-tools/issues/160)) ([#175](https://github.com/joshrotenberg/agent-tools/issues/175)) ([3e35691](https://github.com/joshrotenberg/agent-tools/commit/3e356915d2d46dcdef62c1a4b5265218b52a850e))
* add maintenance-sweep skill ([#225](https://github.com/joshrotenberg/agent-tools/issues/225)) ([0585667](https://github.com/joshrotenberg/agent-tools/commit/05856671f6f7fddbb2af478b35ecedf1c4ac6884)), closes [#124](https://github.com/joshrotenberg/agent-tools/issues/124)
* add pre-merge diff validation and PR number discipline to runner (closes [#198](https://github.com/joshrotenberg/agent-tools/issues/198)) ([#199](https://github.com/joshrotenberg/agent-tools/issues/199)) ([90c6221](https://github.com/joshrotenberg/agent-tools/commit/90c6221382c74f657e1a32e27d55e311c248df21))
* add runner-vs-worker skill (closes [#158](https://github.com/joshrotenberg/agent-tools/issues/158)) ([#183](https://github.com/joshrotenberg/agent-tools/issues/183)) ([363b966](https://github.com/joshrotenberg/agent-tools/commit/363b96649542140b1c4d76cf4b2760cfae661f5a))
* package agent-tools as a Claude Code plugin (closes [#202](https://github.com/joshrotenberg/agent-tools/issues/202)) ([#203](https://github.com/joshrotenberg/agent-tools/issues/203)) ([6e41986](https://github.com/joshrotenberg/agent-tools/commit/6e41986463defd94fd003310debc9f065626b61d))


### Bug Fixes

* add Anti-patterns and Related sections to dispatch-options skill (closes [#166](https://github.com/joshrotenberg/agent-tools/issues/166)) ([#171](https://github.com/joshrotenberg/agent-tools/issues/171)) ([5a2c404](https://github.com/joshrotenberg/agent-tools/commit/5a2c4044d4b82249e738cba1ce6c5cb693967453))
* add missing Anti-patterns and When to apply sections to 12 skills (closes [#167](https://github.com/joshrotenberg/agent-tools/issues/167)) ([#182](https://github.com/joshrotenberg/agent-tools/issues/182)) ([05f3bb2](https://github.com/joshrotenberg/agent-tools/commit/05f3bb2c08ad5d2edf6087672e43f7ed1353359f))
* add pre-commit scope check to worker lifecycle (closes [#142](https://github.com/joshrotenberg/agent-tools/issues/142)) ([#144](https://github.com/joshrotenberg/agent-tools/issues/144)) ([d5fb388](https://github.com/joshrotenberg/agent-tools/commit/d5fb388c65d59b5f62d1f4b73bf361e24c1cca64))
* add runner-vs-worker cross-link to runner Related section ([#190](https://github.com/joshrotenberg/agent-tools/issues/190)) ([ba0d509](https://github.com/joshrotenberg/agent-tools/commit/ba0d5090b79112cb71c4f4d86d382db184df15e2))
* add structural sections to workspace-survey and fix synchronous-lifecycle description (closes [#165](https://github.com/joshrotenberg/agent-tools/issues/165), closes [#185](https://github.com/joshrotenberg/agent-tools/issues/185)) ([#188](https://github.com/joshrotenberg/agent-tools/issues/188)) ([12c5a72](https://github.com/joshrotenberg/agent-tools/commit/12c5a720ce451eeeecc75470a6b6b450db6dd57c))
* add style-reference copy anti-pattern to prompt discipline (closes [#184](https://github.com/joshrotenberg/agent-tools/issues/184)) ([#189](https://github.com/joshrotenberg/agent-tools/issues/189)) ([851490e](https://github.com/joshrotenberg/agent-tools/commit/851490eebb4c4b20f7a542e82b2dec63fe28e12e))
* add worker to runner Related agents section (closes [#164](https://github.com/joshrotenberg/agent-tools/issues/164)) ([#178](https://github.com/joshrotenberg/agent-tools/issues/178)) ([4497d16](https://github.com/joshrotenberg/agent-tools/commit/4497d164ddc0ce1a071bd0d94d9f2cedadca8007))
* compress reviewer AGENT.md lifecycle section (closes [#156](https://github.com/joshrotenberg/agent-tools/issues/156)) ([#187](https://github.com/joshrotenberg/agent-tools/issues/187)) ([bd3efca](https://github.com/joshrotenberg/agent-tools/commit/bd3efca05c443da85327c074b9243dfbbc96115c))
* dispatch-hygiene -- git stash prohibition, write-gate probe, prompt-template hygiene ([#226](https://github.com/joshrotenberg/agent-tools/issues/226)) ([8c5cb29](https://github.com/joshrotenberg/agent-tools/commit/8c5cb296954e841e4ae96fd8391f8a37a1b3e00e))
* dispatcher preload trim, Related section, description language ([#177](https://github.com/joshrotenberg/agent-tools/issues/177)) ([54fe41d](https://github.com/joshrotenberg/agent-tools/commit/54fe41d7efdd3ab72e35b02d1a95658282d70303))
* document -C $(pwd) for Bash worker dispatch from worktree (closes [#180](https://github.com/joshrotenberg/agent-tools/issues/180)) ([#191](https://github.com/joshrotenberg/agent-tools/issues/191)) ([67362d7](https://github.com/joshrotenberg/agent-tools/commit/67362d72f8859573c5d415ceb9ccea8916856a49))
* establish owner-prefixed workspace layout as canonical ([#223](https://github.com/joshrotenberg/agent-tools/issues/223)) ([e1c7c51](https://github.com/joshrotenberg/agent-tools/commit/e1c7c512999f30746dccbc39bd2309bce0819a1c))
* extract audit-protocol skill from auditor body (closes [#155](https://github.com/joshrotenberg/agent-tools/issues/155)) ([#170](https://github.com/joshrotenberg/agent-tools/issues/170)) ([4db21c4](https://github.com/joshrotenberg/agent-tools/commit/4db21c410e6f64e1871017eb5c1898cf22cedc6f))
* field-feedback -- generalize routing and examples to be dispatch-agnostic (closes [#193](https://github.com/joshrotenberg/agent-tools/issues/193)) ([#195](https://github.com/joshrotenberg/agent-tools/issues/195)) ([ca43d4b](https://github.com/joshrotenberg/agent-tools/commit/ca43d4b65b9cb5ca8c9d69f8f9592d86458da712))
* flatten ripples + /plugin docs (closes [#211](https://github.com/joshrotenberg/agent-tools/issues/211)) ([#214](https://github.com/joshrotenberg/agent-tools/issues/214)) ([dbfb455](https://github.com/joshrotenberg/agent-tools/commit/dbfb45555bd101857caae0944820b497b87211a6))
* move long inline commands into fenced code blocks (closes [#162](https://github.com/joshrotenberg/agent-tools/issues/162)) ([#179](https://github.com/joshrotenberg/agent-tools/issues/179)) ([17df1a0](https://github.com/joshrotenberg/agent-tools/commit/17df1a098486fc9f4a111d90a27085e09626da59))
* plugin validate-clean + document the plugin install path ([#204](https://github.com/joshrotenberg/agent-tools/issues/204)) ([ad0b331](https://github.com/joshrotenberg/agent-tools/commit/ad0b331749d8bf0b17b14f1ef19aa806a25e0eec))
* pr-review -- replace broken placeholder cross-link with inline code (closes [#152](https://github.com/joshrotenberg/agent-tools/issues/152)) ([#172](https://github.com/joshrotenberg/agent-tools/issues/172)) ([1446464](https://github.com/joshrotenberg/agent-tools/commit/1446464957d56b86e6a93f8d431c78f39482b53b))
* remove roba-only qualifier from spiral-diagnosis reference in dispatch-wait-react (closes [#192](https://github.com/joshrotenberg/agent-tools/issues/192)) ([#194](https://github.com/joshrotenberg/agent-tools/issues/194)) ([10bd919](https://github.com/joshrotenberg/agent-tools/commit/10bd919962befb892f77a097a00519f9fce86e46))
* replace claude -p -C with cd for worktree cwd anchoring (closes [#196](https://github.com/joshrotenberg/agent-tools/issues/196)) ([#197](https://github.com/joshrotenberg/agent-tools/issues/197)) ([51ec8ca](https://github.com/joshrotenberg/agent-tools/commit/51ec8ca86c813a63c8bf541e20f1fd8489ad2b1b))
* runner worker dispatch must use runner's worktree, not main checkout (closes [#147](https://github.com/joshrotenberg/agent-tools/issues/147)) ([#148](https://github.com/joshrotenberg/agent-tools/issues/148)) ([bfaf50f](https://github.com/joshrotenberg/agent-tools/commit/bfaf50f2d7e384be081b6549daa0f0c3daa656df))
* trim runner AGENT.md body to safe range (closes [#154](https://github.com/joshrotenberg/agent-tools/issues/154)) ([#169](https://github.com/joshrotenberg/agent-tools/issues/169)) ([66616b7](https://github.com/joshrotenberg/agent-tools/commit/66616b771479a623a9c6769c77ad3e14b0d2e517))
* validate frontmatter with a real YAML parse (closes [#205](https://github.com/joshrotenberg/agent-tools/issues/205)) ([#207](https://github.com/joshrotenberg/agent-tools/issues/207)) ([e077e77](https://github.com/joshrotenberg/agent-tools/commit/e077e77496c440829ffa9920c6c02a96f66dd052))

## [0.3.2](https://github.com/joshrotenberg/agent-tools/compare/v0.3.1...v0.3.2) (2026-06-03)


### Bug Fixes

* **dispatcher:** default single-issue runner dispatches to background (closes [#136](https://github.com/joshrotenberg/agent-tools/issues/136)) ([#138](https://github.com/joshrotenberg/agent-tools/issues/138)) ([e093491](https://github.com/joshrotenberg/agent-tools/commit/e093491d8eca7f738e6d905ff549c919d5e6fe8a))

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
