defmodule FileSystemUtils.MountFS do
  @moduledoc """
    Provides functions to mount and unmount filesystems.

    **Requires root user permission to run mount/umount.**

    > **Declaimer**
    >
    > Use at own risk.
    > Make sure you know what you are doing.
  """

  @doc """
  mount - mount a filesystem

  **Requires root permission**

  ## Arguments
  + device_path:
    Path to the device.

  + mount_point_path:
    Path to the mount point.

  + fs_types:
    - ext2
    - ext3
    - ext4
    - btrfs
    - xfs
    - exfat
    - etc
  """
  @spec mount(String.t(), String.t(), [fs_type: String.t(), sudo: boolean] | String.t()) :: :ok | {:error, String.t()}
  def mount(device_path, mount_point_path, opts \\ [fs_type: "ext4"])

  def mount(device_path, mount_point_path, fs_type) when is_bitstring(fs_type) do
    mount(device_path, mount_point_path, fs_type: fs_type)
  end

  def mount(device_path, mount_point_path, opts) do
    with true <- File.exists?(device_path),
         true <- File.dir?(mount_point_path),
         {cmd, args} <- base_mount_command("mount", opts),
         args <- add_fstype_to_mount(args, opts),
         {result, err_code} <- System.cmd(cmd,
                                          args ++ [device_path, mount_point_path],
                                          stderr_to_stdout: true) do
      parse_error_code(err_code)
    else
      false -> {:error, "Device path or mount point path not valid"}
      err -> err
    end
  end

  @doc """
  umount - unmount file systems

  **Requires root permission**

  ## Arguments
  + device_path:
    Path to the device
  """
  @spec umount(String.t(), [sudo: boolean]) :: :ok | {:error, String.t()}
  def umount(device_path, opts \\ []) do
    with true <- File.exists?(device_path),
         {cmd, args} <- base_mount_command("umount", opts),
         {_result, err_code} <- System.cmd(cmd, args ++ [device_path], stderr_to_stdout: true) do
      parse_error_code(err_code)
    else
      false -> {:error, "Device path doesn't exist"}
    end
  end

  defp base_mount_command(actual_cmd, opts) do
    if Keyword.get(opts, :sudo, false) do
      {"sudo", ["-n", actual_cmd]}
    else
      {actual_cmd, []}
    end
  end

  defp add_fstype_to_mount(args, opts) do
    case Keyword.get(opts, :fstype) do
      type when is_bitstring(type) -> args ++ ["-t", type]
      _ -> args
    end
  end

  defp parse_error_code(0), do: :ok
  defp parse_error_code(1), do: {:error, "incorrect invocation or permissions"}
  defp parse_error_code(2), do: {:error, "system error"}
  defp parse_error_code(4), do: {:error, "internal mount bug"}
  defp parse_error_code(8), do: {:error, "user iterupt"}
  defp parse_error_code(16), do: {:error, "problems writing or locking /etc/mtab"}
  defp parse_error_code(32), do: {:error, "mount failure"}
  defp parse_error_code(64), do: {:error, "some mount success"}
  defp parse_error_code(_), do: {:error, "unknown error code"}
end
