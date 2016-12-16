defmodule ConduitAMQP.Conn do
  use Connection
  require Logger

  @reconnect_after_ms 5_000

  def start_link(opts \\ []) do
    Connection.start_link(__MODULE__, opts)
  end

  def init(opts) do
    Process.flag(:trap_exit, true)
    {:connect, :init, %{opts: opts, conn: nil}}
  end

  def handle_call(:conn, _from, %{conn: nil} = status) do
    {:reply, {:error, :disconnected}, status}
  end

  def handle_call(:conn, _from, %{conn: conn} = status) do
    {:reply, {:ok, conn}, status}
  end

  def connect(_, state) do
    connect_opts = Keyword.get(state.opts, :url, state.opts)

    case AMQP.Connection.open(connect_opts) do
      {:ok, conn} ->
        Logger.info("Connected via AMQP!")
        Process.monitor(conn.pid)
        {:ok, %{state | conn: conn}}
      {:error, _reason} ->
        Logger.error("Could not connect via AMQP!")
        {:backoff, @reconnect_after_ms, state}
    end
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason},
    %{conn: %{pid: conn_pid}} = state)
  when pid == conn_pid do
    Logger.error "Lost AMQP connection. Attempting to reconnect..."
    {:connect, :reconnect, %{state | conn: nil}}
  end

  def terminate(_reason, %{conn: nil}), do: :ok
  def terminate(_reason, %{conn: conn}) do
    Logger.info "AMQP connection terminating"

    AMQP.Connection.close(conn)
  catch _, _ ->
    :ok
  end
end
