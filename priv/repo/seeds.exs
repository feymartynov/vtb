# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Vtb.Repo.insert!(%Vtb.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Vtb.Repo.insert!(%Vtb.Position{title: "Председатель правления", weight: 1.1})
Vtb.Repo.insert!(%Vtb.Position{title: "Директор департамента", weight: 1.0})
Vtb.Repo.insert!(%Vtb.Position{title: "Начальник управления", weight: 1.0})
Vtb.Repo.insert!(%Vtb.Position{title: "Главный эксперт", weight: 1.0})
