import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:allpass/application.dart';
import 'package:allpass/params/config.dart';
import 'package:allpass/params/param.dart';
import 'package:allpass/utils/allpass_ui.dart';
import 'package:allpass/provider/theme_provider.dart';
import 'package:allpass/services/authentication_service.dart';
import 'package:allpass/pages/about_page.dart';
import 'package:allpass/pages/setting/feedback_page.dart';
import 'package:allpass/pages/setting/account_manager_page.dart';
import 'package:allpass/pages/setting/category_manager_page.dart';
import 'package:allpass/pages/setting/import/import_export_page.dart';
import 'package:allpass/widgets/setting/input_main_password_dialog.dart';
import 'package:allpass/widgets/setting/check_update_dialog.dart';


/// 设置页面
class SettingPage extends StatefulWidget {
  @override
  _SettingPage createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> with AutomaticKeepAliveClientMixin {

  AuthenticationService _localAuthService;

  ScrollController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _localAuthService = Application.getIt<AuthenticationService>();
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          splashColor: Colors.transparent,
          child: Text(
            "设置",
            style: AllpassTextUI.titleBarStyle,
          ),
          onTap: () {
            _controller.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.linear);
          },
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              controller: _controller,
              children: <Widget>[
                Container(
                  child: ListTile(
                    title: Text("主账号管理"),
                    leading: Icon(Icons.account_circle, color: AllpassColorUI.allColor[0],),
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => AccountManagerPage()));
                    },
                  ),
                  padding: AllpassEdgeInsets.listInset,
                ),
                Container(
                  child: ListTile(
                    title: Text("生物识别"),
                    leading: Icon(Icons.fingerprint, color: AllpassColorUI.allColor[1]),
                    trailing: Switch(
                      value: Config.enabledBiometrics,
                      onChanged: (sw) async {
                        if (await LocalAuthentication().canCheckBiometrics) {
                          showDialog(context: context,
                            builder: (context) => InputMainPasswordDialog(),
                          ).then((right) async {
                            if (right) {
                              var auth = await _localAuthService.authenticate();
                              if (auth) {
                                await _localAuthService.stopAuthenticate();
                                Application.sp.setBool("biometrics", sw);
                                Config.enabledBiometrics = sw;
                                setState(() {});
                              } else {
                                Fluttertoast.showToast(msg: "授权失败");
                              }
                            }
                          });
                        } else {
                          Application.sp.setBool("biometrics", false);
                          Config.enabledBiometrics = false;
                          Fluttertoast.showToast(msg: "您的设备似乎不支持生物识别");
                        }
                      },
                    ),
                  ),
                  padding: AllpassEdgeInsets.listInset
                ),
                Container(
                    child: ListTile(
                      title: Text("长按复制密码或卡号"),
                      leading: Icon(Icons.present_to_all, color: AllpassColorUI.allColor[2]),
                      // subtitle: Params.longPressCopy
                      //     ?Text("当前长按为复制密码或卡号")
                      //     :Text("当前长按为多选"),
                      trailing: Switch(
                        value: Config.longPressCopy,
                        onChanged: (sw) async {
                          Application.sp.setBool("longPressCopy", sw);
                          setState(() {
                            Config.longPressCopy = sw;
                          });
                        },
                      ),
                    ),
                    padding: AllpassEdgeInsets.listInset
                ),
                Container(
                    child: ListTile(
                      title: Text("主题颜色"),
                      leading: Icon(Icons.color_lens, color: AllpassColorUI.allColor[5]),
                      onTap: () {
                        showDialog(context: context, child: AlertDialog(
                          title: Text("修改主题"),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AllpassUI.smallBorderRadius)
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                    color: Colors.blue,
                                    child: Center(
                                      child: Text("蓝色", style: TextStyle(
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<ThemeProvider>(context).changeTheme("blue");
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                    color: Colors.red,
                                    child: Center(
                                      child: Text("红色", style: TextStyle(
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<ThemeProvider>(context).changeTheme("red");
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                    color: Colors.teal,
                                    child: Center(
                                      child: Text("青色", style: TextStyle(
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<ThemeProvider>(context).changeTheme("teal");
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                    color: Colors.deepPurple,
                                    child: Center(
                                      child: Text("深紫", style: TextStyle(
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<ThemeProvider>(context).changeTheme("deepPurple");
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                    color: Colors.orange,
                                    child: Center(
                                      child: Text("橙色", style: TextStyle(
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<ThemeProvider>(context).changeTheme("orange");
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                    color: Colors.pink,
                                    child: Center(
                                      child: Text("粉色", style: TextStyle(
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<ThemeProvider>(context).changeTheme("pink");
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                    color: Colors.blueGrey,
                                    child: Center(
                                      child: Text("蓝灰", style: TextStyle(
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<ThemeProvider>(context).changeTheme("blueGrey");
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                                    color: Colors.black,
                                    child: Center(
                                      child: Text("暗黑", style: TextStyle(
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<ThemeProvider>(context).changeTheme("dark");
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            )
                          ),
                        ));
                      },
                    ),
                    padding: AllpassEdgeInsets.listInset
                ),
                Container(
                  padding: AllpassEdgeInsets.dividerInset,
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Container(
                  child: ListTile(
                    title: Text("标签管理"),
                    leading: Icon(Icons.label_outline, color: AllpassColorUI.allColor[3]),
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => CategoryManagerPage("标签")));
                    },
                  ),
                  padding: AllpassEdgeInsets.listInset
                ),
                Container(
                  child: ListTile(
                    title: Text("文件夹管理"),
                    leading: Icon(Icons.folder_open, color: AllpassColorUI.allColor[4]),
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  CategoryManagerPage("文件夹")));
                    },
                  ),
                  padding: AllpassEdgeInsets.listInset
                ),
                Container(
                  padding: AllpassEdgeInsets.dividerInset,
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Container(
                  child: ListTile(
                    title: Text("导入/导出"),
                    leading: Icon(Icons.import_export, color: AllpassColorUI.allColor[5]),
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ImportExportPage(),
                          ));
                    },
                  ),
                  padding: AllpassEdgeInsets.listInset
                ),
                Container(
                  padding: AllpassEdgeInsets.dividerInset,
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Container(
                    child: ListTile(
                        title: Text("推荐给好友"),
                        leading: Icon(Icons.share, color: AllpassColorUI.allColor[2]),
                        onTap: () async => await _recommend()
                    ),
                    padding: AllpassEdgeInsets.listInset
                ),
                Container(
                    child: ListTile(
                        title: Text("意见反馈"),
                        leading: Icon(Icons.feedback, color: AllpassColorUI.allColor[1]),
                        onTap: () => Navigator.push(context, CupertinoPageRoute(
                          builder: (context) => FeedbackPage(),
                        ))
                    ),
                    padding: AllpassEdgeInsets.listInset
                ),
                Container(
                    child: ListTile(
                      title: Text("检查更新"),
                      leading: Icon(Icons.update, color: AllpassColorUI.allColor[6]),
                      onTap: () {
                        showDialog(
                          context: context,
                          child: CheckUpdateDialog()
                        );
                      }
                    ),
                    padding: AllpassEdgeInsets.listInset
                ),
                Container(
                  child: ListTile(
                    title: Text("关于"),
                    leading: Icon(Icons.details, color: AllpassColorUI.allColor[0]),
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => AboutPage(),
                          ));
                    },
                  ),
                  padding: AllpassEdgeInsets.listInset
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<Null> _recommend() async {
    try {
      Response<Map> response = await Dio(BaseOptions(connectTimeout: 10)).get(
          "$allpassUrl/update?version=1.0.0");
      if (response.data['have_update'] == "1") {
        Share.share(
            "【Allpass】我发现了一款应用，快来下载吧！下载地址：${response.data['download_url']}",
            subject: "软件推荐——Allpass");
      } else {
        Share.share(
            "【Allpass】我发现了一款应用，快来下载吧！下载地址：https://www.aengus.top/assets/app/Allpass_V${Application.version}_signed.apk");
      }
    } catch (e) {
      Share.share(
        "【Allpass】我发现了一款应用，快来下载吧！下载地址：https://www.aengus.top/assets/app/Allpass_V${Application.version}_signed.apk");
    }
  }
}
