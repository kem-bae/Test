

https://github.com/kem-bae/Test.git



//===============UI=====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().initState(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SpacingApp.spacingVertical(PaddingApp.p24),
                _renderAddUser(),
                _renderInfomation(),
                SizedBox(
                  height: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: SizeApp.s16,
                          onPressed: () {},
                          icon: Icon(
                            Icons.settings_applications_sharp,
                            color: ColorApp.greyPrimary,
                          )),
                      SpacingApp.spacingHorizontal(MarginApp.m8),
                      IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: SizeApp.s16,
                          onPressed: () => context.read<HomeCubit>().removeUser(context),
                          icon: Icon(
                            Icons.delete_forever,
                            color: ColorApp.redHeartRate,
                          )),
                      SpacingApp.spacingHorizontal(MarginApp.m16),
                    ],
                  ),
                ),
                _renderBodyAndData(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderAddUser() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: PaddingApp.p24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AddUserButton(
            onTap: () => _blocProvider(_addUserDialog()),
          ),
          Expanded(
              child: StreamBuilder(
            stream: instance.get<UserDriftRepo>().selectTable().watch(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return BlocSelector<HomeCubit, HomeState, int>(
                  selector: (state) {
                    return state.index ?? 0;
                  },
                  builder: (context, indexCurrent) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: PaddingApp.p5),
                        child: UserAvatar(
                          isSelected: index == indexCurrent,
                          onTap: () =>
                              context.read<HomeCubit>().changeUser(index),
                          isMan: (snapshot.data?[index] as UserAllDataData)
                                  .gender ==
                              'male',
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ))
        ],
      ),
    );
  }

  Widget _renderInfomation() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: PaddingApp.p24, vertical: PaddingApp.p12),
      padding: const EdgeInsets.all(PaddingApp.p16),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          ColorApp.startGradientContainer,
          ColorApp.endGradientContainer
        ],
        stops: const [0, 0.961],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      )),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            ImageApp.map,
            width: SizeApp.s100,
            height: SizeApp.s100,
          ),
          SpacingApp.spacingHorizontal(PaddingApp.p12),
          Expanded(
            child: SizedBox(
              height: SizeApp.s100,
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextWithIcon(
                          icon: ImageApp.icName,
                          title: StringsApp.name,
                          content: state.name ?? '--'),
                      TextWithIcon(
                          icon: state.gender == Gender.male
                              ? ImageApp.icOlderMan
                              : ImageApp.icOlderWoman,
                          title: StringsApp.old,
                          content: state.old ?? '--'),
                      TextWithIcon(
                          icon: ImageApp.icDevice,
                          title: StringsApp.id,
                          content: state.id ?? '--'),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _renderBodyAndData() {
    return Expanded(
        child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.asset(
          ImageApp.bodyMan,
          fit: BoxFit.contain,
        ),
        Positioned(
            top: SizeApp.s30,
            right: SizeApp.s30,
            child: _renderDataContainer(isHeartRate: true)),
        Positioned(
            top: SizeApp.s30,
            left: SizeApp.s30,
            child: _renderDataContainer(isHeartRate: false)),
      ],
    ));
  }

  Widget _renderDataContainer({bool isHeartRate = false}) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadiusApp.r50),
          color: ColorApp.white,
          border: Border.all(
              width: SizeApp.s3,
              color: isHeartRate ? ColorApp.redHeartRate : ColorApp.blueSPO2)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                  isHeartRate ? ImageApp.heartRateLottie : ImageApp.spO2Lottie,
                  width: SizeApp.s30),
              Text(isHeartRate ? UnitsApp.bpm : UnitsApp.percent,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: FontSizeApp.s20)),
            ],
          ),
          SpacingApp.spacingVertical(SizeApp.s10),
          BlocSelector<HomeCubit, HomeState, double>(
            selector: (state) {
              return isHeartRate ? state.heartRate ?? 0.0 : state.spO2 ?? 0.1;
            },
            builder: (context, state) {
              return Text(state.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Alegreya',
                      color: isHeartRate
                          ? Colors.redAccent[200]
                          : Colors.lightBlue,
                      fontSize: FontSizeApp.s25));
            },
          ),
        ],
      ),
    );
  }

  void _blocProvider(Widget widget) {
    showDialog(
        context: context,
        builder: (_) {
          return BlocProvider(
            create: (context) => HomeCubit(),
            child: widget,
          );
        });
  }

  Widget _addUserDialog() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: MarginApp.m16),
        padding: const EdgeInsets.all(PaddingApp.p24),
        height: SizeApp.s400,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadiusApp.r16),
          color: ColorApp.white,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: ColorApp.white,
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    StringsApp.signIn,
                    style: TextStyle(
                        fontSize: FontSizeApp.s30,
                        fontWeight: FontWeight.bold,
                        color: ColorApp.blueSPO2),
                  ),
                  SpacingApp.spacingVertical(MarginApp.m24),
                  BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (previous, current) =>
                        previous.id != current.id ||
                        previous.idError != current.idError,
                    builder: (context, state) {
                      return InputTextFieldApp(
                        hint: StringsApp.accountHint,
                        label: StringsApp.account,
                        isRequired: true,
                        labelSize: FontSizeApp.s14,
                        errorText: state.idError,
                        onChanged: (id) =>
                            context.read<HomeCubit>().setId(id ?? ''),
                      );
                    },
                  ),
                  SpacingApp.spacingVertical(MarginApp.m16),
                  BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (previous, current) =>
                        previous.pass != current.pass ||
                        previous.passError != current.passError,
                    builder: (context, state) {
                      return InputTextFieldApp(
                        hint: StringsApp.passHint,
                        label: StringsApp.password,
                        labelSize: FontSizeApp.s14,
                        isRequired: true,
                        errorText: state.passError,
                        onChanged: (pass) =>
                            context.read<HomeCubit>().setPass(pass ?? ''),
                      );
                    },
                  ),
                  SpacingApp.spacingVertical(MarginApp.m24),
                  Row(
                    children: [
                      Expanded(
                          child: BlocConsumer<HomeCubit, HomeState>(
                        listener: (context, state) {
                          switch (state.status) {
                            case HomeScreenStatus.success:
                              Navigator.of(context).pop();
                              _blocProvider(
                                  _addInformationUserDialog(state.id ?? ''));
                              break;
                            default:
                              break;
                          }
                        },
                        buildWhen: (previous, current) =>
                            previous.status != current.status,
                        builder: (context, state) {
                          return FilledButtonApp(
                            label: StringsApp.done,
                            isLoading: state.status == HomeScreenStatus.loading,
                            onPressed: () =>
                                context.read<HomeCubit>().addUserId(),
                          );
                        },
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addInformationUserDialog(String id) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: MarginApp.m16),
        padding: const EdgeInsets.all(PaddingApp.p24),
        height: SizeApp.s530,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadiusApp.r16),
          color: ColorApp.white,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: ColorApp.white,
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpacingApp.spacingVertical(MarginApp.m16),
                  Text(
                    StringsApp.signIn,
                    style: TextStyle(
                        fontSize: FontSizeApp.s30,
                        fontWeight: FontWeight.bold,
                        color: ColorApp.blueSPO2),
                  ),
                  SpacingApp.spacingVertical(MarginApp.m24),
                  BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (previous, current) =>
                        previous.name != current.name ||
                        previous.nameError != current.nameError,
                    builder: (context, state) {
                      return InputTextFieldApp(
                        hint: StringsApp.nameHint,
                        label: StringsApp.name,
                        labelSize: FontSizeApp.s14,
                        errorText: state.nameError,
                        onChanged: (name) =>
                            context.read<HomeCubit>().setName(name ?? ''),
                      );
                    },
                  ),
                  SpacingApp.spacingVertical(MarginApp.m16),
                  BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (previous, current) =>
                        previous.old != current.old ||
                        previous.oldError != current.oldError,
                    builder: (context, state) {
                      return InputTextFieldApp(
                        hint: StringsApp.oldHint,
                        label: StringsApp.old,
                        labelSize: FontSizeApp.s14,
                        errorText: state.oldError,
                        onChanged: (old) =>
                            context.read<HomeCubit>().setOld(old ?? ''),
                      );
                    },
                  ),
                  SpacingApp.spacingVertical(MarginApp.m16),
                  _renderGenderContainer(context),
                  SpacingApp.spacingVertical(MarginApp.m24),
                  Row(
                    children: [
                      Expanded(
                          child: BlocConsumer<HomeCubit, HomeState>(
                        listener: (context, state) {
                          switch (state.status) {
                            case HomeScreenStatus.success:
                              Navigator.of(context).pop();
                              break;
                            default:
                              break;
                          }
                        },
                        buildWhen: (previous, current) =>
                            previous.status != current.status,
                        builder: (context, state) {
                          return FilledButtonApp(
                            label: StringsApp.done,
                            isLoading: state.status == HomeScreenStatus.loading,
                            onPressed: () => context
                                .read<HomeCubit>()
                                .verifyUserInfomation(id),
                          );
                        },
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderGenderContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: SizeApp.s24),
          child: Text(
            StringsApp.gender,
            style: TextStyle(
                fontSize: FontSizeApp.s20,
                fontWeight: FontWeight.bold,
                color: ColorApp.greenButton),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _renderGenderButton(context, Gender.female),
            const SizedBox(width: SizeApp.s36),
            _renderGenderButton(context, Gender.male),
          ],
        ),
      ],
    );
  }

  Widget _renderGenderButton(BuildContext context, Gender genderType) {
    return BlocSelector<HomeCubit, HomeState, Gender>(
      selector: (state) => state.gender,
      builder: (context, gender) {
        return Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<HomeCubit>().setGender(
                    genderType == Gender.female ? Gender.female : Gender.male);
              },
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(0),
                backgroundColor: MaterialStateProperty.all(
                  genderType == gender
                      ? genderType == Gender.female
                          ? ColorApp.redHeartRate.withRed(245)
                          : ColorApp.startGradient
                      : ColorApp.greyPrimary.withOpacity(0.5),
                ),
                shape: MaterialStateProperty.all(const CircleBorder()),
                fixedSize: MaterialStateProperty.all(
                  const Size(
                    SizeApp.s100,
                    SizeApp.s100,
                  ),
                ),
              ),
              child: SvgPicture.asset(
                genderType == Gender.female
                    ? ImageApp.icFemale
                    : ImageApp.icMale,
                width: SizeApp.s36,
              ),
            ),
            const SizedBox(height: SizeApp.s16),
            Text(
              genderType == Gender.female ? StringsApp.female : StringsApp.male,
              style: genderType == gender
                  ? TextStyle(
                      color: ColorApp.greyPrimary,
                      fontSize: FontSizeApp.s16,
                    )
                  : TextStyle(
                      color: ColorApp.greyPrimary,
                      fontSize: FontSizeApp.s16,
                    ),
            ),
          ],
        );
      },
    );
  }
}

//==================State=====================
class HomeState {
  HomeScreenStatus? status;
  int? index;
  String? name;
  String? nameError;
  String? old;
  String? oldError;
  String? id;
  String? idError;
  String? pass;
  String? passError;
  double? spO2;
  double? heartRate;
  Gender gender;

  HomeState(
      {this.status = HomeScreenStatus.init,
      this.gender = Gender.female,
      this.index,
      this.name,
      this.nameError,
      this.id,
      this.idError,
      this.pass,
      this.passError,
      this.oldError,
      this.spO2,
      this.heartRate,
      this.old});

  HomeState copyWith({
    HomeScreenStatus? status,
    String? name,
    int? index,
    String? nameError,
    String? old,
    String? oldError,
    String? id,
    String? idError,
    String? pass,
    String? passError,
    double? spO2,
    double? heartRate,
    Gender? gender,
  }) {
    return HomeState(
      status: status ?? this.status,
      index: index ?? this.index,
      name: name ?? this.name,
      nameError: nameError ?? this.nameError,
      old: old ?? this.old,
      oldError: oldError ?? this.oldError,
      id: id ?? this.id,
      idError: idError ?? this.idError,
      pass: pass ?? this.pass,
      passError: passError ?? this.passError,
      gender: gender ?? this.gender,
      heartRate: heartRate ?? this.heartRate,
      spO2: spO2 ?? this.spO2,
    );
  }
}



//===================Logic===================
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());
  StreamSubscription? _spO2Subscription;
  StreamSubscription? _heartSubscription;
  StreamSubscription? _teNgaSubscription;
  StreamSubscription? _locationSubscription;

  String _token =
      'AAAAuvq0JyY:APA91bEfQrHTg5spZa0dBj9xa13GIBbWXLsJeMxbQFtiAFD9wdAwEDA82mAS4VqOqIQuiSzOYkD6W4Ls9d0QLPAWkp8PCKmtF0W5NAOMUbw0rCw_GeBhheTLK3GZn8JXd-OHlmtO4IT9';
  String? initialMessage;
  bool _resolved = false;

  Future<void> initState(BuildContext context) async {
    changeUser(0);
    listenTeNga(context);
    // handlerNotification();
  }

  @override
  Future<void> close() {
    _heartSubscription?.cancel();
    _spO2Subscription?.cancel();
    _teNgaSubscription?.cancel();
    _locationSubscription?.cancel();

    return super.close();
  }

  void StreamToken() async {
    late Stream<String> _tokenStream;

    void setToken(String? token) {
      print('FCM Token: $token');
      _token = token ?? '';
    }

    FirebaseMessaging.instance
        .getToken(
            vapidKey:
                'AAAAuvq0JyY:APA91bEfQrHTg5spZa0dBj9xa13GIBbWXLsJeMxbQFtiAFD9wdAwEDA82mAS4VqOqIQuiSzOYkD6W4Ls9d0QLPAWkp8PCKmtF0W5NAOMUbw0rCw_GeBhheTLK3GZn8JXd-OHlmtO4IT9')
        .then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }

  void listenFirebase() {
    _spO2Subscription?.cancel();
    _heartSubscription?.cancel();
    final spO2 = FirebaseDatabase.instance.ref('${state.id}/spO2');
    final heartRate = FirebaseDatabase.instance.ref('${state.id}/heartRate');
    _spO2Subscription = spO2.onValue.listen((event) {
      final data = event.snapshot.value;
      setSpO2(double.parse(data.toString()));
    });
    _heartSubscription = heartRate.onValue.listen((event) {
      final data = event.snapshot.value;
      setHeartRate(double.parse(data.toString()));
    });
  }

  Future<void> listenTeNga(BuildContext context) async {
    final data = await instance.get<UserDriftRepo>().getAllDataUser();
    for (int index = 0; index < ((data as List).length); index++) {
      StreamSubscription _stream = FirebaseDatabase.instance
          .ref('${(data[index] as UserAllDataData).id}/isTeNga')
          .onValue
          .listen((event) async {
        if (event.snapshot.value as bool? ?? false) {
          final long = await FirebaseDatabase.instance
              .ref('${(data[index] as UserAllDataData).id}/location/longitude')
              .get();
          final lat = await FirebaseDatabase.instance
              .ref('${(data[index] as UserAllDataData).id}/location/latitude')
              .get();
          // pushNotiHandler();
          _renderPopUpTeNga(context,
              name: (data[index] as UserAllDataData).name ?? '',
              long: double.parse(long.value.toString()),
              lat: double.parse(lat.value.toString()));
        } else {
          // Navigator.of(context).pop();
        }
      });
    }
  }

  void pushNotiHandler() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken(
        vapidKey:
            "AAAAuvq0JyY:APA91bEfQrHTg5spZa0dBj9xa13GIBbWXLsJeMxbQFtiAFD9wdAwEDA82mAS4VqOqIQuiSzOYkD6W4Ls9d0QLPAWkp8PCKmtF0W5NAOMUbw0rCw_GeBhheTLK3GZn8JXd-OHlmtO4IT9");
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      logger.e(fcmToken);
    }).onError((err) {
      logger.e(err);
      // Error getting token.
    });
    _token = token ?? '';
    logger.e(_token);
    // if (_token.isNotEmpty) {
    //   await firebaseMessaging.sendMessage(to: _token, data: {
    //     'title': 'Thông báo',
    //     'body': 'message',
    //     'Authorization':
    //         'key=AAAAuvq0JyY:APA91bEfQrHTg5spZa0dBj9xa13GIBbWXLsJeMxbQFtiAFD9wdAwEDA82mAS4VqOqIQuiSzOYkD6W4Ls9d0QLPAWkp8PCKmtF0W5NAOMUbw0rCw_GeBhheTLK3GZn8JXd-OHlmtO4IT9'
    //   });
    // }

    // sendPushMessage();
  }

  void handlerNotification() async {
    FirebaseMessaging.onMessage
        .listen(PushNotificationHandler.showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.e('A new onMessageOpenedApp event was published!');
    });
  }

  void _resetError() {
    emit(state.copyWith(
      idError: '',
      passError: '',
      nameError: '',
      oldError: '',
    ));
  }

  void setName(String name) {
    _resetError();
    emit(state.copyWith(name: name));
  }

  void setId(String id) {
    _resetError();
    emit(state.copyWith(id: id));
  }

  void setPass(String pass) {
    _resetError();
    emit(state.copyWith(pass: pass));
  }

  void setOld(String old) {
    _resetError();
    emit(state.copyWith(old: old));
  }

  void setGender(Gender gender) {
    _resetError();
    emit(state.copyWith(gender: gender));
  }

  Future<void> addUserId() async {
    if (!checkValidData()) return;
    emit(state.copyWith(status: HomeScreenStatus.loading));
    try {
      final ref = FirebaseDatabase.instance.ref(state.id);
      final event = await ref.once();
      if (event.snapshot.value == null) {
        emit(state.copyWith(
            idError: StringsApp.isNotReconize, status: HomeScreenStatus.init));
      } else {
        final pass = event.snapshot.child("pass").value;
        if (pass == state.pass) {
          emit(state.copyWith(status: HomeScreenStatus.success));
        } else {
          emit(state.copyWith(status: HomeScreenStatus.init));
          emit(state.copyWith(passError: StringsApp.wrongPass));
        }
      }
    } catch (e) {
      emit(state.copyWith(status: HomeScreenStatus.fail));
    }
  }

  bool checkValidData() {
    bool isValid = true;
    if (StringHelper.isNullOrEmpty(state.id)) {
      emit(state.copyWith(idError: StringsApp.isEmpty));
      isValid = false;
    }
    if (StringHelper.isNullOrEmpty(state.pass)) {
      emit(state.copyWith(passError: StringsApp.isEmpty));
      isValid = false;
    }
    return isValid;
  }

  Future<void> verifyUserInfomation(String idUser) async {
    if (!checkValidInfor()) return;
    emit(state.copyWith(status: HomeScreenStatus.loading));
    try {
      await instance<UserDriftRepo>().insertDataUser(UserAllDataCompanion(
          id: Value(idUser),
          name: Value(state.name),
          old: Value(state.old),
          gender: Value(state.gender == Gender.female ? 'female' : 'male')));
      idGlobal = idUser;
      emit(state.copyWith(status: HomeScreenStatus.success));
    } catch (e) {
      return;
    }
  }

  bool checkValidInfor() {
    bool isValid = true;
    if (StringHelper.isNullOrEmpty(state.name)) {
      emit(state.copyWith(nameError: StringsApp.isEmpty));
      isValid = false;
    }
    if (StringHelper.isNullOrEmpty(state.old)) {
      emit(state.copyWith(oldError: StringsApp.isEmpty));
      isValid = false;
    }
    return isValid;
  }

  void setSpO2(double data) {
    emit(state.copyWith(spO2: data));
  }

  void setHeartRate(double d) {
    emit(state.copyWith(heartRate: d));
  }

  void changeUser(int index) {
    setUserInformation(index).then((value) => listenFirebase());

    emit(state.copyWith(index: index));
  }

  Future<void> removeUser(BuildContext context) async {
    if (state.id != null) {
      await instance.get<UserDriftRepo>().removeUser(state.id ?? '');
      changeUser(0);
      listenTeNga(context);
    }
  }

  Future<void> setUserInformation(int index) async {
    try {
      final data = await instance.get<UserDriftRepo>().getAllDataUser();
      final userInfor = data[index] as UserAllDataData;
      emit(state.copyWith(
        name: userInfor.name,
        gender: (userInfor.gender == 'female' ? Gender.female : Gender.male),
        id: userInfor.id,
        old: (DateTime.now().year -
                DateFormat('yyyy').parse(userInfor.old ?? "1973").year)
            .toString(),
      ));
    } catch (e) {
      Logger().e('setUserInformation: $e');
    }
  }

  void _renderPopUpTeNga(BuildContext context,
      {required String name, required double long, required double lat}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Center(
              child: Container(
            width: MediaQuery.of(context).size.width,
            height: SizeApp.s400,
            margin: const EdgeInsets.symmetric(horizontal: MarginApp.m16),
            padding: const EdgeInsets.all(PaddingApp.p16),
            decoration: BoxDecoration(
              color: ColorApp.white,
              borderRadius: BorderRadius.circular(RadiusApp.r16),
            ),
            child: Scaffold(
              backgroundColor: ColorApp.white,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpacingApp.spacingVertical(MarginApp.m16),
                  SvgPicture.asset(ImageApp.warning),
                  SpacingApp.spacingVertical(MarginApp.m24),
                  Text(
                    StringsApp.warning,
                    style: TextStyle(
                        fontFamily: "Alegreya",
                        color: ColorApp.redHeartRate,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSizeApp.s30),
                  ),
                  SpacingApp.spacingVertical(MarginApp.m8),
                  WidgetUtil.createRichText(
                      textAlign: TextAlign.left,
                      value:
                          "${StringsApp.yourFamily} $name ${StringsApp.haveIssue}",
                      boldStrings: [name],
                      normalTextStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: "Mulish",
                          fontSize: FontSizeApp.s14),
                      boldTextStyle: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: ColorApp.bluePrimary,
                          fontSize: FontSizeApp.s14)),
                  SpacingApp.spacingVertical(MarginApp.m16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          StringsApp.pleaseCheck,
                          textScaleFactor: 1.0,
                          style: const TextStyle(
                              color: Colors.black,
                              fontFamily: "Mulish",
                              fontSize: FontSizeApp.s14),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  SpacingApp.spacingVertical(MarginApp.m8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openGoogleMaps(
                              latitude: lat == 0 ? 10.852521 : lat,
                              longitude: long == 0 ? 106.771705 : long),
                          child: Text(
                            StringsApp.tapOpenGGMap,
                            textScaleFactor: 1.0,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: FontSizeApp.s11,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: ColorApp.bluePrimary,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                      child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButtonApp(
                            label: StringsApp.close,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ));
        });
  }

  void _openGoogleMaps(
      {required double longitude, required double latitude}) async {
    String url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      return;
    }
  }

  Future<void> sendPushMessage() async {
    if (_token == null) {
      logger.e('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      final result = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAuvq0JyY:APA91bEfQrHTg5spZa0dBj9xa13GIBbWXLsJeMxbQFtiAFD9wdAwEDA82mAS4VqOqIQuiSzOYkD6W4Ls9d0QLPAWkp8PCKmtF0W5NAOMUbw0rCw_GeBhheTLK3GZn8JXd-OHlmtO4IT9'
        },
        body: PushNotificationHandler.constructFCMPayload(_token),
      );
      logger.e('FCM request for device sent!');

      if (result.statusCode == 200) {
        logger.w('FCM request sent successfully!');
      } else {
        logger.w('FCM request failed with status code: ${result.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> onActionSelected(String value) async {
    switch (value) {
      case 'subscribe':
        {
          print(
            'FlutterFire Messaging Example: Subscribing to topic "fcm_test".',
          );
          await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
          print(
            'FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.',
          );
        }
        break;
      case 'unsubscribe':
        {
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test".',
          );
          await FirebaseMessaging.instance.unsubscribeFromTopic('fcm_test');
          print(
            'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test" successful.',
          );
        }
        break;
      case 'get_apns_token':
        {
          if (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS) {
            print('FlutterFire Messaging Example: Getting APNs token...');
            String? token = await FirebaseMessaging.instance.getAPNSToken();
            print('FlutterFire Messaging Example: Got APNs token: $token');
          } else {
            print(
              'FlutterFire Messaging Example: Getting an APNs token is only supported on iOS and macOS platforms.',
            );
          }
        }
        break;
      default:
        break;
    }
  }
}
