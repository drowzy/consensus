defmodule Consensus do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Consensus.Server, [10000])
    ]

    opts = [strategy: :one_for_one]

    Supervisor.start_link(children, opts)
  end
end
