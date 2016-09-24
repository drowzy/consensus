defmodule Consensus.Server do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__,  opts, [])
  end

  def init([port]) do
    Logger.debug("Calling init with #{port}")

    opts = [:binary, packet: :line, active: false, reuseaddr: true]
    case :gen_tcp.listen(port, opts) do
      {:ok, socket} ->
        Logger.debug("TCP server active")

        GenServer.cast(self(), :accept)

        {:ok, %{ socket: socket, clients: [] }}
      {:error, reason} ->
        Logger.debug("TCP server active")
        {:error, reason}
    end
  end

  def handle_cast(:accept,  %{ socket: socket, clients: clients }) do
    Logger.debug("Accepting connection")

    {:ok, client} = :gen_tcp.accept(socket)
    serve(client)
    {:noreply, %{ socket: socket, clients: clients ++ [client] }}
  end

  defp serve(socket) do
    msg = read_line(socket)

    Logger.debug("Got message: #{msg}")

    write_line(socket, msg)

    serve(socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, msg) do
    :gen_tcp.send(socket, msg)
  end
end
