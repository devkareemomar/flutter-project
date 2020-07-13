import 'package:fluttermultistoreflutter/api/common/ps_resource.dart';
import 'package:fluttermultistoreflutter/api/common/ps_status.dart';
import 'package:fluttermultistoreflutter/provider/common/ps_provider.dart';
import 'package:fluttermultistoreflutter/repository/Common/notification_repository.dart';
import 'package:fluttermultistoreflutter/utils/utils.dart';
import 'package:fluttermultistoreflutter/viewobject/api_status.dart';
import 'package:fluttermultistoreflutter/viewobject/common/ps_value_holder.dart';
import 'package:flutter/cupertino.dart';

class NotificationProvider extends PsProvider {
  NotificationProvider(
      {@required NotificationRepository repo,
      @required this.psValueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    //isDispose = false;
    print('Notification Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
  }
  NotificationRepository _repo;
  PsValueHolder psValueHolder;

  PsResource<ApiStatus> _notification =
      PsResource<ApiStatus>(PsStatus.NOACTION, '', null);
  PsResource<ApiStatus> get user => _notification;

  Future<dynamic> rawRegisterNotiToken(Map<dynamic, dynamic> jsonMap) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _notification = await _repo.rawRegisterNotiToken(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _notification;
  }

  Future<dynamic> rawUnRegisterNotiToken(Map<dynamic, dynamic> jsonMap) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _notification = await _repo.rawUnRegisterNotiToken(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _notification;
  }

  @override
  void dispose() {
    isDispose = true;
    print('Notification Provider Dispose: $hashCode');
    super.dispose();
  }
}
