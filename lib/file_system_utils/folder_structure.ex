defmodule FileSystemUtils.FolderStructure do
  @moduledoc """
  FolderStructure module is used to create a folder structure based on a map.
  """

  @doc "Ensure folder is available"
  def ensure_folder(path) do
    path
    |> Path.expand()
    |> File.mkdir_p()
  end

  @doc """
  Ensure folder structure is used to create a folder structure either as a map 
  or a nested lists.
  The nested lists approach is preferred, but the map version is easier to store
  as part of a database entry or json file.

  Example:
  ensure_folder_structure("/path/to/root", [
    "dirA",
    {"dirB", ["B1", "B2", {"B3", ["C1", "C2"]}]},
    {"dirC", {"D1", "D2"}}
  ])
  """
  def ensure_folder_structure(rootpath, folder_structure) when is_map(folder_structure) do
    Enum.map(folder_structure, fn {folder, children} ->
      ensure_folder_structure(rootpath, folder)

      Path.join(rootpath, folder)
      |> ensure_folder_structure(children)
    end)
  end

  def ensure_folder_structure(rootpath, folder_list) when is_list(folder_list) do
    Enum.map(folder_list, &ensure_folder_structure(rootpath, &1))
  end

  def ensure_folder_structure(rootpath, {folder_path, children}) when is_bitstring(folder_path) do
    ensure_folder_structure(rootpath, folder_path)

    Path.join(rootpath, [folder_path, "/"])
    |> ensure_folder_structure(children)
  end

  def ensure_folder_structure(rootpath, folder_path) when is_bitstring(folder_path) do
    Path.join(rootpath, folder_path)
    |> ensure_folder()
  end

  def ensure_folder_structure(_, nil) do
    :ok
  end

  def ensure_folder_structure(_, _) do
    {:error, "Invalid Folder Structure"}
  end
end
