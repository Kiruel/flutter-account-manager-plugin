import 'dart:async';

import 'package:flutter/services.dart';

class Account {
  String name;
  String accountType;

  Account({
    required this.name,
    required this.accountType
  });
}

class AccessToken {
  String tokenType;
  String token;

  AccessToken({
    required this.tokenType,
    required this.token
  });
}

/// Represents some APIs from Android account manager and emulates it on iOS
/// platform
class AccountManager {
  static const MethodChannel _channel = const MethodChannel('accountManager');

  static const String _KeyAccountName = 'account_name';
  static const String _KeyAccountType = 'account_type';
  static const String _KeyAuthTokenType = 'auth_token_type';
  static const String _KeyAccessToken = 'access_token';
  static const String _KeyUserDataKey = "user_data_key";
  static const String _KeyUserData = "user_data";

  /// Adds the [account] to the account manager on Android and user preferences
  /// on iOS
  static Future<bool> addAccount(Account account) async {
    return await _channel.invokeMethod('addAccount', {
      _KeyAccountName: account.name,
      _KeyAccountType: account.accountType
    });
  }

  /// Get the userData from account manager on Android, not implemented on iOS
  /// 
  /// On android: https://developer.android.com/reference/android/accounts/AccountManager#getUserData(android.accounts.Account,%20java.lang.String)
  static Future<String?> getUserData(Account account, String key) async{
    return await _channel.invokeMethod("getUserData", {
      _KeyAccountName: account.name,
      _KeyAccountType: account.accountType,
      _KeyUserDataKey: key,
    });
  }

  /// Set the userData to a account on Android, not implemented on iOS
  /// 
  /// On android: https://developer.android.com/reference/android/accounts/AccountManager#setUserData(android.accounts.Account,%20java.lang.String,%20java.lang.String)
  static Future<void> setUserData(Account account, String key, String data) async {
    await _channel.invokeMethod("setUserData", {
      _KeyAccountName: account.name,
      _KeyAccountType: account.accountType,
      _KeyUserDataKey: key,
      _KeyUserData: data,
    });
  }

  /// Returns an access token by [account] and [authTokenType]
  static Future<AccessToken?> getAccessToken(Account account,
      String authTokenType) async {
    AccessToken? accessToken;
    final res = await _channel.invokeMethod('getAccessToken', {
      _KeyAccountName: account.name,
      _KeyAccountType: account.accountType,
      _KeyAuthTokenType: authTokenType
    });
    if (res != null) {
      accessToken = AccessToken(
        tokenType: res[_KeyAuthTokenType],
        token: res[_KeyAccessToken],
      );
    }
    return accessToken;
  }

  /// Returns a list of accounts
  static Future<List<Account>> getAccounts() async {
    List<Account> accounts = [];
    final result = await _channel.invokeMethod('getAccounts');
    for (var item in result) {
      accounts.add(
          new Account(
              name: item[_KeyAccountName],
              accountType: item[_KeyAccountType]
          )
      );
    }
    return accounts;
  }

  /// Deletes the [account]
  static Future<bool> removeAccount(Account account) async {
    return await _channel.invokeMethod('removeAccount', {
      _KeyAccountName: account.name,
      _KeyAccountType: account.accountType
    });
  }

  /// Saves the access [token] for the passed [account]
  static Future<bool> setAccessToken(Account account, AccessToken? token
      ) async {
    final data = {
      _KeyAccountName: account.name,
      _KeyAccountType: account.accountType
    };
    if (token != null) {
      data[_KeyAuthTokenType] = token.tokenType;
      data[_KeyAccessToken] = token.token;
    }
    return await _channel.invokeMethod('setAccessToken', data);
  }
}
