import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:allpass/params/params.dart';
import 'package:allpass/params/allpass_type.dart';
import 'package:allpass/pages/password/edit_password_page.dart';
import 'package:allpass/pages/password/view_password_page.dart';
import 'package:allpass/pages/search/search_page.dart';
import 'package:allpass/utils/allpass_ui.dart';
import 'package:allpass/utils/encrypt_util.dart';
import 'package:allpass/utils/screen_util.dart';
import 'package:allpass/widgets/search_button_widget.dart';
import 'package:allpass/widgets/confirm_dialog.dart';
import 'package:allpass/provider/password_list.dart';

/// 密码页面
class PasswordPage extends StatefulWidget {
  @override
  _PasswordPageState createState() {
    return _PasswordPageState();
  }
}

class _PasswordPageState extends State<PasswordPage> with AutomaticKeepAliveClientMixin{

  ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<Null> _query() async {
    await Provider.of<PasswordList>(context).init();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: AllpassEdgeInsets.smallLPadding,
          child: InkWell(
            splashColor: Colors.transparent,
            child: Text(
              "密码",
              style: AllpassTextUI.titleBarStyle,
            ),
            onTap: () {
              _controller.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.linear);
            },
          ),
        ),
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: AllpassColorUI.mainBackgroundColor,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          Params.multiSelected
          ? InkWell(
              splashColor: Colors.transparent,
              child: Icon(Icons.delete_outline),
              onTap: () {
                showDialog<bool>(
                    context: context,
                  builder: (context) => ConfirmDialog(
                    "确认删除",
                    "您将删除${Params.multiPasswordList.length}项密码，确认吗？"
                  )
                ).then((confirm) {
                  if (confirm) {
                    for (var item in Params.multiPasswordList) {
                      Provider.of<PasswordList>(context).deletePassword(item);
                    }
                    Params.multiPasswordList.clear();
                  }
                });
              },
          ) : Container(),
          FlatButton(
            splashColor: Colors.transparent,
            child: Params.multiSelected ? Text("取消") : Text("多选"),
            onPressed: () {
              setState(() {
                Params.multiPasswordList.clear();
                Params.multiSelected = !Params.multiSelected;
              });
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          // 搜索框 按钮
          SearchButtonWidget(_searchPress, "密码"),
          // 密码列表
          Expanded(
            child: RefreshIndicator(
               onRefresh: _query,
               child: Scrollbar(
                 child: Consumer<PasswordList>(
                   builder: (context, model, child) {
                     if (model.passwordList.length >= 1) {
                       return Params.multiSelected
                         ? ListView.builder(
                            controller: _controller,
                            itemBuilder: (context, index) =>
                                MultiPasswordWidgetItem(index),
                            itemCount: model.passwordList.length,
                       )
                       : ListView.builder(
                          controller: _controller,
                          itemBuilder: (context, index) =>
                              PasswordWidgetItem(index),
                          itemCount: model.passwordList.length,
                       );
                     } else {
                       return ListView(
                         children: <Widget>[
                           Padding(
                             padding: EdgeInsets.only(top: AllpassScreenUtil.setHeight(400)),
                           ),
                           Padding(
                             child: Center(
                               child: Text("什么也没有，赶快添加吧"),
                             ),
                             padding: AllpassEdgeInsets.forCardInset,
                           ),
                           Padding(
                             padding: AllpassEdgeInsets.smallTBPadding,
                           ),
                           Padding(
                             child: Center(
                               child: Text("这里存储你的密码信息，例如\n微博账号、知乎账号等", textAlign: TextAlign.center,),
                             ),
                             padding: AllpassEdgeInsets.forCardInset,
                           )
                         ],
                       );
                     }
                   },
                 )
               )
            ),
          )
        ],
      ),
      backgroundColor: AllpassColorUI.mainBackgroundColor,
      // 添加 按钮
      floatingActionButton: Consumer<PasswordList>(
        builder: (context, model, _) => FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditPasswordPage(null, "添加密码")))
            .then((resData) {
              if (resData != null) {
                model.insertPassword(resData);
              }
            });
          },
          heroTag: "password",
        ),
      )
    );
  }

  _searchPress () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage(AllpassType.PASSWORD)));
  }
}

class PasswordWidgetItem extends StatelessWidget {
  final int index;

  PasswordWidgetItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Consumer<PasswordList>(
      builder: (context, model, child) {
        return Container(
          margin: AllpassEdgeInsets.listInset,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getRandomColor(model.passwordList[index].uniqueKey),
              child: Text(
                model.passwordList[index].name.substring(0, 1),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(model.passwordList[index].name, overflow: TextOverflow.ellipsis,),
            subtitle: Text(model.passwordList[index].username, overflow: TextOverflow.ellipsis,),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ViewPasswordPage(model.passwordList[index])
              )).then((bean) {
                if (bean != null) {
                  if (bean.isChanged) {
                    model.updatePassword(bean);
                  } else {
                    model.deletePassword(model.passwordList[index]);
                  }
                }
              });
            },
            onLongPress: () {
              if (Params.longPressCopy) {
                Clipboard.setData(ClipboardData(
                    text: EncryptUtil.decrypt(model.passwordList[index].password)
                ));
                Fluttertoast.showToast(msg: "已复制密码");
              }
            },
          ),
        );
      },
    );
  }
}

class MultiPasswordWidgetItem extends StatefulWidget {

  final int index;
  MultiPasswordWidgetItem(this.index);

  @override
  State<StatefulWidget> createState() {
    return _MultiPasswordWidgetItem(this.index);
  }

}

class _MultiPasswordWidgetItem extends State<StatefulWidget> {
  final int index;

  _MultiPasswordWidgetItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Consumer<PasswordList>(
      builder: (context, model, child) {
        return Container(
          margin: AllpassEdgeInsets.listInset,
          child: CheckboxListTile(
            value: Params.multiPasswordList.contains(model.passwordList[index]),
            onChanged: (value) {
              setState(() {
                if (value) {
                  Params.multiPasswordList.add(model.passwordList[index]);
                } else {
                  Params.multiPasswordList.remove(model.passwordList[index]);
                }
              });
            },
            secondary: CircleAvatar(
              backgroundColor: getRandomColor(model.passwordList[index].uniqueKey),
              child: Text(
                model.passwordList[index].name.substring(0, 1),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(model.passwordList[index].name, overflow: TextOverflow.ellipsis,),
            subtitle: Text(model.passwordList[index].username, overflow: TextOverflow.ellipsis,),
          ),
        );
      },
    );
  }
}