import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sindcelma_app/model/entities/User.dart';
import 'package:sindcelma_app/model/services/UserManagerService.dart';
import 'package:sindcelma_app/pages/app/carteirinha/CarteirinhaSocio.dart';
import 'package:sindcelma_app/pages/app/ccts/CCTList.dart';
import 'package:sindcelma_app/pages/app/home.dart';
import 'package:sindcelma_app/pages/app/notifications/notification.dart';
import 'package:sindcelma_app/pages/app/sorteios/SorteioList.dart';

import 'user/SocioArea.dart';

class App extends StatefulWidget {

  final Function close;

  const App(this.close, {Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  void onClose() async {
    User().status = 0;
    await UserManagerService().updateUser();
    widget.close();
  }

  @override
  Widget build(BuildContext context) {

    print(User().status);

    if(User().status > 1){

    }

    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      routes: {
        '/': (context) => Home(() => onClose()),
        '/notifications': (context) => Notifications(),
        '/user': (context) => const SocioArea(),
        //'/noticias': (context) => {},
        '/carteirinha': (context) => const CarteirinhaSocio(),
        '/sorteios': (context) => const SorteioList(),
        '/ccts': (context) => const CCTList()
      },
    );
  }
}
