// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on _HomeControllerBase, Store {
  Computed<bool>? _$hasLastAddressComputed;

  @override
  bool get hasLastAddress =>
      (_$hasLastAddressComputed ??= Computed<bool>(() => super.hasLastAddress,
              name: '_HomeControllerBase.hasLastAddress'))
          .value;
  Computed<bool>? _$showEmptySearchComputed;

  @override
  bool get showEmptySearch =>
      (_$showEmptySearchComputed ??= Computed<bool>(() => super.showEmptySearch,
              name: '_HomeControllerBase.showEmptySearch'))
          .value;
  Computed<List<AddressModel>>? _$recentAddressesComputed;

  @override
  List<AddressModel> get recentAddresses => (_$recentAddressesComputed ??=
          Computed<List<AddressModel>>(() => super.recentAddresses,
              name: '_HomeControllerBase.recentAddresses'))
      .value;
  Computed<bool>? _$hasRecentAddressesComputed;

  @override
  bool get hasRecentAddresses => (_$hasRecentAddressesComputed ??=
          Computed<bool>(() => super.hasRecentAddresses,
              name: '_HomeControllerBase.hasRecentAddresses'))
      .value;

  late final _$isLoadingAtom =
      Atom(name: '_HomeControllerBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$loadingMessageAtom =
      Atom(name: '_HomeControllerBase.loadingMessage', context: context);

  @override
  String get loadingMessage {
    _$loadingMessageAtom.reportRead();
    return super.loadingMessage;
  }

  @override
  set loadingMessage(String value) {
    _$loadingMessageAtom.reportWrite(value, super.loadingMessage, () {
      super.loadingMessage = value;
    });
  }

  late final _$lastAddressAtom =
      Atom(name: '_HomeControllerBase.lastAddress', context: context);

  @override
  AddressModel? get lastAddress {
    _$lastAddressAtom.reportRead();
    return super.lastAddress;
  }

  @override
  set lastAddress(AddressModel? value) {
    _$lastAddressAtom.reportWrite(value, super.lastAddress, () {
      super.lastAddress = value;
    });
  }

  late final _$historyAtom =
      Atom(name: '_HomeControllerBase.history', context: context);

  @override
  ObservableList<AddressModel> get history {
    _$historyAtom.reportRead();
    return super.history;
  }

  @override
  set history(ObservableList<AddressModel> value) {
    _$historyAtom.reportWrite(value, super.history, () {
      super.history = value;
    });
  }

  late final _$searchResultsAtom =
      Atom(name: '_HomeControllerBase.searchResults', context: context);

  @override
  List<AddressModel>? get searchResults {
    _$searchResultsAtom.reportRead();
    return super.searchResults;
  }

  @override
  set searchResults(List<AddressModel>? value) {
    _$searchResultsAtom.reportWrite(value, super.searchResults, () {
      super.searchResults = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_HomeControllerBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$notFoundMessageAtom =
      Atom(name: '_HomeControllerBase.notFoundMessage', context: context);

  @override
  String? get notFoundMessage {
    _$notFoundMessageAtom.reportRead();
    return super.notFoundMessage;
  }

  @override
  set notFoundMessage(String? value) {
    _$notFoundMessageAtom.reportWrite(value, super.notFoundMessage, () {
      super.notFoundMessage = value;
    });
  }

  late final _$loadDataAsyncAction =
      AsyncAction('_HomeControllerBase.loadData', context: context);

  @override
  Future<void> loadData() {
    return _$loadDataAsyncAction.run(() => super.loadData());
  }

  late final _$searchByCepAsyncAction =
      AsyncAction('_HomeControllerBase.searchByCep', context: context);

  @override
  Future<void> searchByCep(String cep) {
    return _$searchByCepAsyncAction.run(() => super.searchByCep(cep));
  }

  late final _$searchByAddressAsyncAction =
      AsyncAction('_HomeControllerBase.searchByAddress', context: context);

  @override
  Future<void> searchByAddress(
      {required String uf, required String city, required String street}) {
    return _$searchByAddressAsyncAction
        .run(() => super.searchByAddress(uf: uf, city: city, street: street));
  }

  late final _$selectAddressAsyncAction =
      AsyncAction('_HomeControllerBase.selectAddress', context: context);

  @override
  Future<void> selectAddress(AddressModel address) {
    return _$selectAddressAsyncAction.run(() => super.selectAddress(address));
  }

  late final _$getLastAddressLocationAsyncAction = AsyncAction(
      '_HomeControllerBase.getLastAddressLocation',
      context: context);

  @override
  Future<Location?> getLastAddressLocation() {
    return _$getLastAddressLocationAsyncAction
        .run(() => super.getLastAddressLocation());
  }

  late final _$_HomeControllerBaseActionController =
      ActionController(name: '_HomeControllerBase', context: context);

  @override
  void clearSearchResults() {
    final _$actionInfo = _$_HomeControllerBaseActionController.startAction(
        name: '_HomeControllerBase.clearSearchResults');
    try {
      return super.clearSearchResults();
    } finally {
      _$_HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearNotFound() {
    final _$actionInfo = _$_HomeControllerBaseActionController.startAction(
        name: '_HomeControllerBase.clearNotFound');
    try {
      return super.clearNotFound();
    } finally {
      _$_HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void showError(String message) {
    final _$actionInfo = _$_HomeControllerBaseActionController.startAction(
        name: '_HomeControllerBase.showError');
    try {
      return super.showError(message);
    } finally {
      _$_HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_HomeControllerBaseActionController.startAction(
        name: '_HomeControllerBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$_HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
loadingMessage: ${loadingMessage},
lastAddress: ${lastAddress},
history: ${history},
searchResults: ${searchResults},
errorMessage: ${errorMessage},
notFoundMessage: ${notFoundMessage},
hasLastAddress: ${hasLastAddress},
showEmptySearch: ${showEmptySearch},
recentAddresses: ${recentAddresses},
hasRecentAddresses: ${hasRecentAddresses}
    ''';
  }
}
