# Core mutations

Stabilization rolls a base core and one independent mutation on the server when the job starts. The saved job holds both outcomes; opening the station, leaving, waiting or claiming cannot reroll them. Claim transfers the mutation into the core's saved inventory record before the reveal. Existing timed jobs and older inventory records without a mutation are normal.

Tune `Shared.MutationDefinitions`: normal weight 85, Charged 10, Radiant 4, Overloaded 1. Charged gives 1.25x, Radiant 1.5x and Overloaded 2x base reactor income and base sell value. The existing odds panel stays unchanged. These are provisional content/balance values.

`StabilizerDefinitions.DisplayName`, `Income`, `IncomeText`, `SaleValue`, `MutationKey` and `RarityText` accept saved records; income/name helpers also accept a base core key with an optional mutation argument. Future reactor installation should use `Income(coreRecord)` rather than the base definition rate. Mutations do not generate cash while held. Core sale payouts combine the mutation's sell-value bonus with the player's Overcharge cash multiplier, rounding only the final payout to whole dollars. Single and bulk quotes validate the mutation as well as core identity/type.

Reveal and held billboard labels show the base core name, an optional mutation line such as OVERLOADED (2x), and boosted earnings. Normal cores hide the middle line. The existing RarityLabel child is reused for mutations to preserve authored layouts. They use the existing editable `ReplicatedStorage.UITemplates.CoreBillboard`. Geometry stays the same. Shared CoreVisuals adds blue, gold or pink tint, low-rate sparks, outline/glow and arcs. Effects attach to visual BaseParts so they remain intact when those parts move into a Tool. Silhouette cycling omits mutation effects and stays black. Index cards remain base-core discoveries.

Overcharge retains mutation records with the core inventory and stabilization job. Unknown Cores stay unchanged. Normal records fall back to a multiplier of one, including unknown mutation keys. The current save pipeline serializes the mutation field; production leave/rejoin round-trip is not yet verified.

Validation: Rojo build and whitespace checks passed. Studio server tests covered exact mutation-roll boundaries, normal legacy jobs, single roll at placement, repeated publish, saved job serialization, one-time claiming, mutated Tool labels/visuals/income, mutation plus Overcharge single/bulk payouts, invalidated mutation quotes and Overcharge retention. Client reveal checks passed for Overloaded Reactor name, 2x multiplier, $2k/sec income, arc effects and cleanup. The held Overloaded Storm display showed $200/sec and pink effects.

Run `tests/mutations.server.lua` inside a temporary server Script during Studio Play with persistence disabled; stop afterward to clear fixtures. Do not add the fixture to the authored place.
