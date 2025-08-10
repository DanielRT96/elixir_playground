# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirPlayground.Repo.insert!(%ElixirPlayground.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ElixirPlayground.Repo
alias ElixirPlayground.Locations.Location

locations = [
  "Budapest - Nyugati",
  "Budapest - Corvin",
  "Budapest - Allee",
  "Debrecen - Fórum",
  "Szeged - Árkád",
  "Pécs - Árkád"
]

for name <- locations do
  %Location{name: name}
  |> Repo.insert!(on_conflict: :nothing)
end
