defmodule Lab1.Orchestrator do
  use GenServer
  alias EventsourceEx.Message

  # This is a ghetto implementation of how Broadway elixir works, without batching:
  #         [producer_1]
  #             / \
  #            /   \
  #           /     \
  #          /       \
  #  [processor_1] [processor_2]   <- process each message

  # In our case we allow multiple producers, but this is only because we know that message types are the same and come from same source

  # Base url that will change depending on environment
  @base_url Application.fetch_env!(:lab1, :base_url)

  # Dynamic scaling of workers makes no sense, as this can be achieved without using this system, instead using a topology defined at the start of the work is the way to go
  @processor_concurrency 5

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_opts) do
    # Start the system and get state information
    state = start_system()

    {:ok, state}
  end

  # Start the dynamic supervisor, producers and workers
  defp start_system() do
    # Not started as named supervisor, so that the lifecycle is handled by parent process
    {:ok, pid} = DynamicSupervisor.start_link(strategy: :one_for_one)
    # Starting the producers
    start_producers(pid)
    # Starting the workers
    workers = start_workers(pid)

    %{workers: workers, latest_worker: 0, total_workers: @processor_concurrency}
  end

  # Messages received from our producers, currently we don't care from what producer it comes from
  def handle_info(
        %Message{} = message,
        %{workers: workers, latest_worker: latest_worker, total_workers: total_workers} = state
      ) do
    next_worker = send_work_round_robbin(message, latest_worker, workers, total_workers)
    {:noreply, Map.put(state, :latest_worker, next_worker)}
  end

  # Message received on successful processing of the message
  def handle_info({:work_success, data, worker_pid}, state) do
    IO.inspect(
      "Work done from worker: #{inspect(worker_pid)}, result: #{inspect(data, limit: 2)}"
    )

    {:noreply, state}
  end

  # Message received on failure of message processing, in our case we get JSONs that are not valid
  def handle_info({:work_error, data, reason, worker_pid}, state) do
    IO.inspect(
      "Worker #{inspect(worker_pid)} failed with: #{inspect(data)} ,with error: #{inspect(reason)}"
    )

    {:noreply, state}
  end

  # It is supposed that both producers produce same type of data
  defp start_producers(sup_pid) do
    endpoint1 = "#{@base_url}/tweets/1"
    endpoint2 = "#{@base_url}/tweets/2"

    DynamicSupervisor.start_child(
      sup_pid,
      {Lab1.Producer, %{parent_pid: self(), endpoint: endpoint1}}
    )

    DynamicSupervisor.start_child(
      sup_pid,
      {Lab1.Producer, %{parent_pid: self(), endpoint: endpoint2}}
    )
  end

  defp start_workers(sup_pid) do
    Enum.map(0..(@processor_concurrency - 1), fn _worker_id ->
      {:ok, worker_pid} = DynamicSupervisor.start_child(sup_pid, {Lab1.Processor, []})
      worker_pid
    end)
  end

  # This implementation doesn't care about balancing on processors based on jobs numbers
  defp send_work_round_robbin(message, latest_worker_id, workers, total_workers)
       when is_list(workers) and is_number(latest_worker_id) do
    # Rotate the counter to the next processor
    next_worker = rem(latest_worker_id + 1, total_workers)
    send(Enum.at(workers, next_worker), {:handle_work, message, self()})
    next_worker
  end
end
