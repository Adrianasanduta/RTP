defmodule Registry do
  use Agent

  def init() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, fn registry -> Map.get(registry, key, []) end)
  end

  def add(key, values) do
    Agent.update(__MODULE__, fn registry -> Map.put(registry, key, [values | Map.get(registry, key, [])]) end)
  end

  def delete(key, value) do
    Agent.update(
      __MODULE__,
      fn registry ->
        values = Registry.get(key)
        new_values = List.delete(values, value)
        Map.put(registry, key, new_values)
      end
    )
  end
end
