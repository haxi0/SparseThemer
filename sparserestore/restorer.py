import traceback
from pathlib import Path
import click
import requests
from packaging.version import parse as parse_version
from pymobiledevice3.cli.cli_common import Command
from pymobiledevice3.exceptions import NoDeviceConnectedError, PyMobileDevice3Exception
from pymobiledevice3.lockdown import LockdownClient, create_using_usbmux, create_using_tcp
from pymobiledevice3.services.installation_proxy import InstallationProxyService
from sparserestore import backup, perform_restore
import os

global lockdown
lockdown = create_using_usbmux(autopair=True)

def exit(code=0):
#    if platform.system() == "Windows" and g©etattr(sys, "frozen", False) and hasattr(sys, "_MEIPASS"):
#        input("Press Enter to exit...")
    return code

def cli(service_provider: LockdownClient) -> None:
    device_class = service_provider.get_value(key="DeviceClass")
    device_build = service_provider.get_value(key="BuildVersion")
    device_version = parse_version(service_provider.product_version)

    if not all([device_class, device_build, device_version]):
        click.secho("Failed to get device information!", fg="red")
        click.secho("Make sure your device is connected and try again.", fg="red")
        return
    app = "Discord.app"
    apps_json = InstallationProxyService(service_provider).get_apps(application_type="User", calculate_sizes=False)

    app_path = None
    for key, value in apps_json.items():
        if isinstance(value, dict) and "Path" in value:
            potential_path = Path(value["Path"])
            # print(potential_path)
            if potential_path.name.lower() == app.lower():
                app_path = potential_path
                app = app_path.name
                print(app_path)

    app_uuid = app_path.parent.name

    try:
        with open('/Users/ibarahime/dev/SparseThemer/sparserestore/Assets.car', "rb") as helper_contents: # TODO: use relative paths for this. but basically the swift app should add the assets file here
            click.secho(f"Replacing {app}. (UUID: {app_uuid})", fg="yellow")
            back = backup.Backup(
                files=[
                    backup.ConcreteFile(
                        "",
                        f"SysContainerDomain-../../../../../../../../var/containers/Bundle/Application/{app_uuid}/{app}/Assets.car",
                        owner=33,
                        group=33,
                        contents=helper_contents.read(),
                    ),
                    backup.ConcreteFile("", "SysContainerDomain-../../../../../../../.." + "/crash_on_purpose", contents=b""),
                ]
            )
    except Exception as e:
        click.secho(f"ERROR: {e}", fg="red")
        return
    try:
        perform_restore(back, reboot=False)
    except PyMobileDevice3Exception as e:
        if "Find My" in str(e):
            click.secho("Find My must be disabled in order to use this tool.", fg="red")
            click.secho("Disable Find My from Settings (Settings -> [Your Name] -> Find My) and then try again.", fg="red")
            exit(1)
        elif "crash_on_purpose" not in str(e):
            raise e

    click.secho("Make sure you turn Find My iPhone back on if you use it after rebooting.", fg="green")


def main():
    try:
        cli(lockdown)
    except NoDeviceConnectedError:
        click.secho("No device connected!", fg="red")
        click.secho("Please connect your device and try again.", fg="red")
        exit(1)
    except click.UsageError as e:
        click.secho(e.format_message(), fg="red")
        click.echo(cli.get_help(click.Context(cli)))
        exit(2)
    except Exception:
        click.secho("An error occurred!", fg="red")
        click.secho(traceback.format_exc(), fg="red")
        exit(1)

# @click.command(cls=Command)
def get_apps(service_provider: LockdownClient=lockdown):
    device_class = service_provider.get_value(key="DeviceClass")
    device_build = service_provider.get_value(key="BuildVersion")
    device_version = parse_version(service_provider.product_version)

    if not all([device_class, device_build, device_version]):
        click.secho("Failed to get device information!", fg="red")
        click.secho("Make sure your device is connected and try again.", fg="red")
        return
    apps_json = InstallationProxyService(service_provider).get_apps(application_type="User", calculate_sizes=False)

    apps = dict()
    for key, value in apps_json.items():
        if isinstance(value, dict) and "Path" in value:
            apps[value["CFBundleIdentifier"]] = value["Path"]
    return apps

if __name__ == "__main__":
    # main()
    print(get_apps(lockdown))
    # get_apps(lockdown)
