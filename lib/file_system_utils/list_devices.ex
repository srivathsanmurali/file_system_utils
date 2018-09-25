defmodule FileSystemUtils.ListDevices do
  @moduledoc """
    Provides functions to get information about devices available in the system.
  """

  @spec lsblk(devices :: binary | [binary]) :: map
  @doc """
    lsblk - list block devices
    
    returns the output of the lsblk command line utilty as json object.

    ## Arguments
    + devices (default = "")
      If device(s) is passed as argument, information is only retrieved for those.
  """
  def lsblk(devices \\ "", command_opts \\ []), do: do_lsblk(parse_device_to_list(devices), command_opts)

  @spec lsblk_only_scsi(devices :: binary | [binary]) :: map
  @doc """
    Gives json objects that provides information on only the scsi devices
    
    ## Arguments
    + devices (default = "")
      If device(s) is passed as argument, information is only retrieved for those.
  """
  def lsblk_only_scsi(devices \\ "", command_opts \\ []), do: do_lsblk(["--scsi"] ++ parse_device_to_list(devices), command_opts)

  @spec list_devices_with_label(Boolean) :: [binary]
  @doc """
    Lists all devices that have a label

    ## Arguments
    - full_path (default = false)
      + false: Return list of device names.
      + true : Returns list of paths to device.
  """
  def list_devices_with_label(full_path \\ false)
  def list_devices_with_label(false), do: File.ls("/dev/disk/by-label")
  def list_devices_with_label(true), do: Path.wildcard("/dev/disk/by-label/*")

  @spec list_devices(Boolean) :: [binary]
  @doc """
    List all the mountable devices in the system.

    ## Arguments
    - full_path (default = false)
      + false: Return list of device names.
      + true : Returns list of paths to device.
  """
  def list_devices(full_path \\ false, opts \\ [])

  def list_devices(true, command_opts) do
    with {:ok, devices} <- list_devices(false, command_opts),
         devices <- Enum.map(devices, &Path.wildcard("/dev/**/#{&1}")) |> List.flatten() do
      {:ok, devices}
    else
      err -> err
    end
  end

  def list_devices(false, command_opts) do
    with {:ok, json} <- do_lsblk([], command_opts),
         names <- get_names(json["blockdevices"]) do
      {:ok, names}
    else
      err -> err
    end
  end

  defp get_names(list_devices) when is_list(list_devices) do
    list_devices
    |> Enum.map(&get_names/1)
    |> List.flatten()
  end

  defp get_names(device) when is_map(device) do
    case Map.has_key?(device, "children") do
      true -> get_names(device["children"])
      false -> device["name"]
    end
  end
  
  defp base_lsblk_command(actual_cmd, opts) do
    if Keyword.get(opts, :sudo, false) do
      {"sudo", ["-n", actual_cmd]}
    else
      {actual_cmd, []}
    end
  end

  defp parse_device_to_list(""), do: []
  defp parse_device_to_list(device) when not is_list(device), do: [device]
  defp parse_device_to_list(devices) when is_list(devices), do: devices

  defp do_lsblk(options, command_opts) do
    with {cmd, args} <- base_lsblk_command("lsblk", command_opts),
        {json, err_code} <-
           System.cmd(
             cmd,
             args ++ ["--json", "--fs"] ++ options,
             stderr_to_stdout: true
           ),
         :ok <- parse_error_code(err_code),
         {:ok, json} <- Jason.decode(json) do
      {:ok, json}
    else
      err -> err
    end
  end

  defp parse_error_code(0), do: :ok
  defp parse_error_code(1), do: {:error, "failure"}
  defp parse_error_code(32), do: {:error, "none of specified devices found"}
  defp parse_error_code(64), do: {:error, "some specified devices found, some not found"}
  defp parse_error_code(_), do: {:error, "Unknown return code"}
end
