defmodule FileSystemUtils.MountFS do
  @doc """
  mount - mount a filesystem

  ## arguments
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
  def mount(device_path, mount_point_path, fs_type \\ "ext4") do
    {_result, err_code} =
      System.cmd("mount", ["-t", fs_type, device_path, mount_point_path], stderr_to_stdout: true)

    parse_error_code(err_code)
  end

  @doc """
  umount - unmount file systems

  ## arguments
  + device_path:
    Path to the device
  """
  def umount(device_path) do
    {_result, err_code} = System.cmd("umount", [device_path], stderr_to_stdout: true)
    parse_error_code(err_code)
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
