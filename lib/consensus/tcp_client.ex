defmodule Consensus.TCPClient do
  use GenServer

  def start_link(ip, port, opts) do
    GenServer.start_link(__MODULE__, [ip, port, opts])
  end

  def init([ip, port, opts]) do
    case :gen_tcp.connect(ip, port, opts) do
      {:ok, socket} -> {:ok, %{ socket: socket }}
      {error, Reason} -> {error, Reason}
    end
  end

  def close(pid) do
    GenServer.call(pid, :close)
  end

  def send_request(pid, text) do
    GenServer.cast(pid, {:send, text})
  end

  def handle_cast({:send, text}, state = %{socket: socket}) do
    :ok = :gen_tcp.send(socket, text)
    {:noreply, state}
  end

  def handle_call(:close, _from, state = %{socket: socket}) do
    status = :gen_tcp.close(socket)
    {:reply, status, state}
  end

end