import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(Permission permission) async{
  if(await permission.isGranted)
    return true;

  PermissionStatus status = await permission.request();
  if(status.isGranted)
    return true;

  //Tuy vao ung dung ma co the co tuy chon nay hay khong?
  if(status.isPermanentlyDenied)
    await openAppSettings();

  return false;
}

// Future<bool> requestMultiplePermission(List<Permission> permission) async{}