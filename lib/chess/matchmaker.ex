defmodule Chess.Matchmaker do
  use GenServer

  @doc """
  Starts the Matchmaker process.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Adds a player to the waiting queue.
  """
  def join_queue(player_id) do
    GenServer.call(__MODULE__, {:join_queue, player_id})
  end

  @doc """
  Removes a player from the queue (e.g., if they disconnect).
  """
  def leave_queue(player_id) do
    GenServer.call(__MODULE__, {:leave_queue, player_id})
  end

  @impl true
  def init(state) do
    {:ok, Map.put(state, :waiting_players, [])}
  end

  @impl true
  def handle_call({:join_queue, player_id}, _from, state) do
    case state.waiting_players do
      [] ->
        # No players waiting, add this player to the queue
        new_state = Map.update!(state, :waiting_players, &([player_id | &1]))
        {:reply, :waiting, new_state}

      [opponent_id | rest] ->
        # Pair with the first waiting player
        new_state = Map.put(state, :waiting_players, rest)
        game_id = UUID.uuid4() # Generate a unique game ID
        {:reply, {:matched, opponent_id, game_id}, new_state}
    end
  end

  @impl true
  def handle_call({:leave_queue, player_id}, _from, state) do
    new_state = Map.update!(state, :waiting_players, fn players ->
      List.delete(players, player_id)
    end)
    {:reply, :ok, new_state}
  end
end
