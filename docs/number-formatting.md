# Number formatting

`Shared.NumberFormat.Compact` formats all displayed gameplay amounts: 1,500 → 1.5k, 10,000 → 10k, 1,500,000 → 1.5m, 2,500,000,000 → 2.5b and trillions → t. Larger tiers use qa/qi/sx/sp/oc/no/dc. Small amounts keep up to two decimals; abbreviated amounts round to one decimal and trim trailing zeros. Values at rounding boundaries promote to the next suffix, so 999,999 displays 1m rather than 1000k. Suffixes remain lowercase.

Used by cash/bag HUD, Power/XP/Level/depth, materials, block health, weapon/upgrade prices and previews, NPC core-sale quotes/results, sale/pickup feedback, Overcharge requirements/rewards and core income labels in the hotbar, Index and stabilization reveal. Stabilization clocks and exact odds retain their time/percentage formats. Only presentation changes; inventory counts, rewards, damage, requirements and saved data remain numbers at full precision.

Validation: Studio formatter checks passed for zero, fractional amounts, negative values, k/m/b/t tiers and rollover boundaries. Live UI checks passed for $1.5m cash, 1.5k / 10k bag capacity, 1.5k Power, 1.5k / 2.2k XP, Overcharge requirements, $25k weapon price and $1k/sec reactor-core labels. Rojo build and whitespace checks passed.
